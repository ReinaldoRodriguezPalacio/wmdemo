//
//  BaseService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

let ERROR_SERIVCE_DOMAIN = "com.bcg.service.error"
let JSON_KEY_DESCRIPTION = "description"
let JSON_KEY_RESPONSEARRAY = "responseArray"
let JSON_KEY_RESPONSEOBJECT = "responseObject"

let JSON_KEY_TEXT = "pText"
let JSON_KEY_IDDEPARTMENT = "idDepartment"
let JSON_KEY_IDFAMILY = "idFamily"
let JSON_KEY_IDLINE = "idLine"
let JSON_KEY_SORT = "sort"
let JSON_KEY_STARTOFFSET = "startOffSet"
let JSON_KEY_MAXRESULTS = "maxResults"
let JSON_KEY_ISFACET = "isFacet"



enum FilterType : String {
    case none = ""
    case descriptionAsc = "descriptionASC"
    case descriptionDesc = "descriptionDESC"
    case priceAsc = "priceASC"
    case priceDesc = "priceDESC"
    case popularity = "popularity"
}

enum ResultObjectType : String {
    case Mg = "mg"
    case Groceries = "groceries"
}

class BaseService : NSObject {
    struct AFStatic {
        static var cookie : String!
        static var manager : AFHTTPSessionManager!
        static var managerGR : AFHTTPSessionManager!
        static var onceToken : dispatch_once_t = 0
    }
    
    override init() {
        super.init()
        dispatch_once(&AFStatic.onceToken) {
            AFStatic.manager = AFHTTPSessionManager()
            AFStatic.manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
//            AFStatic.manager.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.Certificate)
//            AFStatic.manager.securityPolicy.validatesCertificateChain = false
            AFStatic.manager.securityPolicy.allowInvalidCertificates = true
            
        
            AFStatic.managerGR = AFHTTPSessionManager()
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
//            AFStatic.managerGR.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.Certificate)
//            AFStatic.managerGR.securityPolicy.validatesCertificateChain = false
            AFStatic.managerGR.securityPolicy.allowInvalidCertificates = true
        }
        
    }
    
    // MARK: - Service url helpers
    func serviceUrl() -> (String){
        let stringOfClassType: String = nameOfClass(self.dynamicType)
        return serviceUrl(stringOfClassType)
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        var services = NSBundle.mainBundle().objectForInfoDictionaryKey(ConfigServices.ConfigIdMG) as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    func nameOfClass(classType: AnyClass) -> String {
        let stringOfClassType: String = NSStringFromClass(classType)
        return stringOfClassType
    }
    
    
    // MARK: - Request service
    
    
    
    func getManager() -> AFHTTPSessionManager {
        
        let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
        dispatch_sync(lockQueue) {
            if UserCurrentSession.sharedInstance().userSigned != nil && self.shouldIncludeHeaders() {
                let timeInterval = NSDate().timeIntervalSince1970
                let timeStamp  = String(NSNumber(double:(timeInterval * 1000)).integerValue)
                let uuid  = NSUUID().UUIDString
                let strUsr  = "ff24423eefbca345" + timeStamp + uuid
                AFStatic.manager.requestSerializer!.setValue(timeStamp, forHTTPHeaderField: "timestamp")
                AFStatic.manager.requestSerializer!.setValue(uuid, forHTTPHeaderField: "requestID")
                AFStatic.manager.requestSerializer!.setValue(strUsr.sha1(), forHTTPHeaderField: "control")
                
//                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: self.serviceUrl())!)
//                let headers = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
//                for key in headers.keys {
//                    let strKey = key as NSString
//                    let strVal = headers[key] as NSString
//                    AFStatic.managerGR.requestSerializer!.setValue(strVal, forHTTPHeaderField:strKey)
//                }
            } else{
                AFStatic.manager.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            }
        }
        return AFStatic.manager
        
    }
    
    func retrieve(entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil) -> AnyObject {
        return retrieve(entityName, sortBy:sortBy , isAscending:isAscending, predicate:predicate,expression:nil)
    }

    
    func retrieve(entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil,expression :NSExpressionDescription?) -> AnyObject {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    =  NSFetchRequest(entityName: entityName as NSString as String)
        
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        if (sortBy != nil) {
            var sorter = NSSortDescriptor(key:sortBy! , ascending:isAscending)
            request.sortDescriptors = [sorter]
        }
        
        if expression != nil {
            request.resultType = NSFetchRequestResultType.DictionaryResultType;
            request.propertiesToFetch = [expression!];
        }
        
        var error: NSError? = nil
        var fetchedResult = context.executeFetchRequest(request, error: &error)
        if error != nil {
            println("errore: \(error)")
        }
        return fetchedResult!
    }

    
    func callPOSTService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
     
        afManager.POST(serviceUrl(), parameters: params, success: {(request:NSURLSessionDataTask!, json:AnyObject!) in
            var resultJSON = json as! NSDictionary
            if let errorResult = self.validateCodeMessage(resultJSON) {
                if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                    if UserCurrentSession.sharedInstance().userSigned != nil {
                        let loginService = LoginWithEmailService()
                        loginService.loginIdGR = UserCurrentSession.sharedInstance().userSigned!.idUserGR as String
                        let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
                        loginService.callService(["email":emailUser], successBlock: { (response:NSDictionary) -> Void in
                            self.callPOSTService(params, successBlock: successBlock, errorBlock: errorBlock)
                            }, errorBlock: { (error:NSError) -> Void in
                                UserCurrentSession.sharedInstance().userSigned = nil
                             NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                        })
                    }
                    return
                }
                errorBlock!(errorResult)
                return
            }
             successBlock!(resultJSON)
            }, failure: {(request:NSURLSessionDataTask!, error:NSError!) in
                
                if error.code == -1005 {
                    println("Response Error : \(error) \n Response \(request.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                println("Response Error : \(error) \n Response \(request.response)")
                errorBlock!(error)
        })
        
    }
    
    func callGETService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callGETService(serviceUrl(),params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(serviceURL:String,params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        callGETService(afManager,serviceURL:serviceURL,params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(manager:AFHTTPSessionManager,serviceURL:String,params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.GET(serviceURL, parameters: params, success: {(request:NSURLSessionDataTask!, json:AnyObject!) in
            var resultJSON = json as! NSDictionary
            if let errorResult = self.validateCodeMessage(resultJSON) {
                if errorResult.code == self.needsToLoginCode()   {
                    if UserCurrentSession.sharedInstance().userSigned != nil {
                        let loginService = LoginWithEmailService()
                        //loginService.loginIdGR = UserCurrentSession.sharedInstance().userSigned!.idUserGR
                        let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
                        loginService.callService(["email":emailUser], successBlock: { (response:NSDictionary) -> Void in
                            self.callGETService(params, successBlock: successBlock, errorBlock: errorBlock)
                            }, errorBlock: { (error:NSError) -> Void in
                                UserCurrentSession.sharedInstance().userSigned = nil
                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                        })
                        return
                    }
                }
                errorBlock!(errorResult)
                return
            }
            successBlock!(resultJSON)
            }, failure: {(request:NSURLSessionDataTask!, error:NSError!) in
                if error.code == -1005 {
                    println("Response Error : \(error) \n Response \(request.response)")
                    self.callGETService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                println("Response Error : \(error)")
                errorBlock!(error)
        })
        
    }
    
    
    
    
    // MARK: - Service code validation
    
    func validateCodeMessage(response:NSDictionary) -> NSError? {
        if let codeMessage = response["codeMessage"] as? NSNumber {
            var message = response["message"] as! NSString
            if codeMessage.integerValue != 0  {
                println("error : Response with error \(message)")
                return NSError(domain: ERROR_SERIVCE_DOMAIN, code: codeMessage.integerValue, userInfo: [NSLocalizedDescriptionKey:message])
            }
        }
        return nil
    }
    
    // MARK: - File Manager
    
    func getFilePath(fileName:String) -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray!
        var docPath = paths[0] as! NSString
        var path = docPath.stringByAppendingPathComponent(fileName)
        return path
    }
    
  
    
    func saveDictionaryToFile(dictionary:NSDictionary,fileName:String) {
        let filePath = getFilePath(fileName)
        let data : NSData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            var error:NSError?
            var deleted = NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            if error != nil {
                println(error)
            }
        }
        data.writeToFile(filePath, atomically: true)
    }
    
    func getDataFromFile(fileName:String) -> NSDictionary? {
        var path = self.getFilePath(fileName)
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            var error: NSError?
            var jsonData = NSData(contentsOfFile:path, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
            var values = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
            return values
        }else {
            if let pathResource = NSBundle.mainBundle().pathForResource(fileName.lastPathComponent.stringByDeletingPathExtension, ofType:fileName.pathExtension ) {
                var error: NSError?
                var jsonData = NSData(contentsOfFile:pathResource, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
                var values = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
                return values
            }
        }
        return nil
    }

    
    
    func saveKeywords(items:NSArray) {
        //Creating keywords
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                for var idx = 0; idx < items.count; idx++ {
                    if let item = items[idx] as? NSDictionary {
                        if let desc = item[JSON_KEY_DESCRIPTION] as? String {
                            var description = desc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

                            var upc = item["upc"] as? String
                            upc = upc!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

                            var price: String?
                            if let pricetxt = item["price"] as? String {
                                price = pricetxt.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                            }
                            if let pricenum = item["price"] as? NSNumber {
                                price = pricenum.stringValue
                            }
                            
                            if price == nil {
                                continue
                            }

                            var select = WalMartSqliteDB.instance.buildFindProductKeywordQuery(description: description, price: price!)
                            if let rs = db.executeQuery(select, withArgumentsInArray:nil) {
                                var exist = false
                                while rs.next() {
                                    exist = true
                                }
                                rs.close()
                                rs.setParentDB(nil)
                                
                                if exist {
                                    continue
                                }
                            }
                            
                            var query = WalMartSqliteDB.instance.buildInsertProductKeywordQuery(forUpc: upc!, andDescription: description, andPrice:price!)
                            db.executeUpdate(query, withArgumentsInArray: nil)
                        }
                    }
                }
            }
        })
    }
    
    
    func shouldIncludeHeaders() -> Bool {
        return true
    }

    func jsonFromObject(object:AnyObject!) {
        let data : NSData = NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted, error: nil)!
        var jsonTxt = NSString(data: data, encoding: NSUTF8StringEncoding)
        println(jsonTxt)
    }
    
    func needsLogin() -> Bool {
        return true
    }
    
    
    func needsToLoginCode() -> Int {
        return -100
    }
    
    
    

    func loadKeyFieldCategories( items:AnyObject!, type:String ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                //let items : AnyObject = self.getCategoriesContent() as AnyObject!;
                for item in items as! [AnyObject] {
                    var name = item["description"] as! String
                    var idDepto = item["idDepto"] as! String
                    let famArray : AnyObject = item["family"] as AnyObject!
                    
                    for itemFamily in famArray as! [AnyObject] {
                        var idFamily = itemFamily["id"] as! String
                        let lineArray : AnyObject = itemFamily["line"] as AnyObject!
                        var namefamily = itemFamily["name"] as! String
                        for itemLine in lineArray as! [AnyObject] {
                            let idLine =  itemLine["id"] as! String
                            let nameLine =  itemLine["name"] as! String
                            var select = WalMartSqliteDB.instance.buildFindCategoriesKeywordQuery(categories: nameLine, departament: "\(name) > \(namefamily)", type:type, idLine:idLine)
                            if let rs = db.executeQuery(select, withArgumentsInArray:nil) {
                                var exist = false
                                while rs.next() {
                                    exist = true
                                }
                                rs.close()
                                rs.setParentDB(nil)
                                
                                if exist {
                                    continue
                                }
                            }
                            
                            var query = WalMartSqliteDB.instance.buildInsertCategoriesKeywordQuery(forCategorie: nameLine, andDepartament: name, andType:type, andLine:idLine, andFamily:idFamily, andDepto:idDepto,family:namefamily,line:nameLine)
                            db.executeUpdate(query, withArgumentsInArray: nil)
                            
                            
                        }
                    }
                }
            }
        })
    }
    
    
    func printTimestamp(message: String) {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        println("\(message)"  + timestamp)
    }
    
    func callPOSTServiceCam(manager:AFHTTPSessionManager, params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.POST(serviceUrl(), parameters: nil,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
                let imgData = params.objectForKey("image_request[image]") as! NSData
                let localeStr = params.objectForKey("image_request[locale]") as! String
                let langStr = params.objectForKey("image_request[language]") as! String
                formData.appendPartWithFileData(imgData, name: "image_request[image]", fileName: "image.jpg", mimeType: "image/jpeg")
                formData.appendPartWithFormData(localeStr.dataUsingEncoding(NSUTF8StringEncoding), name:"image_request[locale]")
                formData.appendPartWithFormData(langStr.dataUsingEncoding(NSUTF8StringEncoding), name:"image_request[language]")
            },
            success: {(request:NSURLSessionDataTask!, json:AnyObject!) in
                var resultJSON = json as! NSDictionary
                if let errorResult = self.validateCodeMessage(resultJSON) {
                    if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                        if UserCurrentSession.sharedInstance().userSigned != nil {
                            let loginService = LoginWithEmailService()
                            loginService.loginIdGR = UserCurrentSession.sharedInstance().userSigned!.idUserGR as String
                            let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
                            loginService.callService(["email":emailUser], successBlock: { (response:NSDictionary) -> Void in
                                self.callPOSTService(params, successBlock: successBlock, errorBlock: errorBlock)
                                }, errorBlock: { (error:NSError) -> Void in
                                    UserCurrentSession.sharedInstance().userSigned = nil
                                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                            })
                        }
                        return
                    }
                    errorBlock!(errorResult)
                    return
                }
                successBlock!(resultJSON)
            },
            failure: {(request:NSURLSessionDataTask!, error:NSError!) in
                if error.code == -1005 {
                    println("Response Error : \(error) \n Response \(request.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                println("Response Error : \(error) \n Response \(request.response)")
                errorBlock!(error)
        })
    }

    
}

