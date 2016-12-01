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
let JSON_KEY_RESPONSEARRAY_CORRECTION = "responseArrayCorrection"
let JSON_KEY_RESPONSEARRAY_ALTERNATIVE = "responseArrayAlternative"
let JSON_KEY_RESPONSEOBJECT = "responseObject"

let JSON_KEY_TEXT = "pText"
let JSON_KEY_IDDEPARTMENT = "idDepartment"
let JSON_KEY_IDFAMILY = "idFamily"
let JSON_KEY_IDLINE = "idLine"
let JSON_KEY_SORT = "sort"
let JSON_KEY_STARTOFFSET = "startOffSet"
let JSON_KEY_MAXRESULTS = "maxResults"
let JSON_KEY_ISFACET = "isFacet"
let JSON_KEY_BRAND = "brand"



enum FilterType : String {
    case none = ""
    case descriptionAsc = "descriptionASC"
    case descriptionDesc = "descriptionDESC"
    case priceAsc = "priceASC"
    case priceDesc = "priceDESC"
    case popularity = "popularity"
    case rankingASC = "rankingASC"
    case rating = "rating"
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
    
    var urlForSession = false
    var useSignalsServices = false
    
    override init() {
        super.init()
        dispatch_once(&AFStatic.onceToken) {
            AFStatic.manager = AFHTTPSessionManager()
            AFStatic.manager.requestSerializer = AFJSONRequestSerializer()
            AFStatic.manager.responseSerializer = AFJSONResponseSerializer()
            AFStatic.manager.responseSerializer.acceptableContentTypes = nil
            AFStatic.manager.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None)
            AFStatic.manager.securityPolicy.allowInvalidCertificates = true
            AFStatic.manager.securityPolicy.validatesDomainName = false
        
            AFStatic.managerGR = AFHTTPSessionManager()
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer()
            AFStatic.managerGR.responseSerializer = AFJSONResponseSerializer()
            AFStatic.managerGR.responseSerializer.acceptableContentTypes = nil
            AFStatic.managerGR.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None)
            AFStatic.managerGR.securityPolicy.allowInvalidCertificates = true
            AFStatic.managerGR.securityPolicy.validatesDomainName = false
        }
        
    }
    
    // MARK: - Service url helpers
    func serviceUrl() -> (String){
        let stringOfClassType: String = nameOfClass(self.dynamicType)
        return serviceUrl(stringOfClassType)
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        var serviceConfigDictionary = ConfigServices.ConfigIdMG
        
        if useSignalsServices {
            serviceConfigDictionary =  ConfigServices.ConfigIdMGSignals
        }
        
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey(serviceConfigDictionary) as! NSDictionary
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
            var jsessionIdSend = UserCurrentSession.sharedInstance().JSESSIONID
            var jSessionAtgIdSend = UserCurrentSession.sharedInstance().JSESSIONATG
            
            if jsessionIdSend == "" {
                if let param2 = CustomBarViewController.retrieveParamNoUser("JSESSIONID") {
                    print("PARAM JSESSIONID ::"+param2.value)
                    jsessionIdSend = param2.value
                }
                if let param3 = CustomBarViewController.retrieveParamNoUser("JSESSIONATG") {
                    print("PARAM JSESSIONATG ::" + param3.value)
                    jSessionAtgIdSend = param3.value
                }
            }
            
            if UserCurrentSession.hasLoggedUser() && self.shouldIncludeHeaders() {
                let timeInterval = NSDate().timeIntervalSince1970
                let timeStamp  = String(NSNumber(double:(timeInterval * 1000)).integerValue)
                let uuid  = NSUUID().UUIDString
                let strUsr  = "ff24423eefbca345" + timeStamp + uuid
                AFStatic.manager.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
                AFStatic.manager.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
                AFStatic.manager.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control")
                //Session --
                
                print("URL:: \(self.serviceUrl())")
                AFStatic.manager.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
                AFStatic.manager.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
                
                
            } else{
                //Session --
                print("URL:: \(self.serviceUrl())")
                print("SEND JSESSIONID::" + jsessionIdSend)
                print("SEND JSESSIONATG::" + jSessionAtgIdSend)
                AFStatic.manager.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
                AFStatic.manager.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
                AFStatic.manager.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
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
            let sorter = NSSortDescriptor(key:sortBy! , ascending:isAscending)
            request.sortDescriptors = [sorter]
        }
        
        if expression != nil {
            request.resultType = NSFetchRequestResultType.DictionaryResultType;
            request.propertiesToFetch = [expression!];
        }
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        return fetchedResult!
    }

    
    func callPOSTService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) -> NSURLSessionDataTask {
        let afManager = getManager()
        let url = serviceUrl()
   
        
        let task = afManager.POST(url, parameters: params, progress: nil, success: {(request:NSURLSessionDataTask, json:AnyObject?) in
            //session --
            //TODO Loginbyemail
            let response : NSHTTPURLResponse = request.response as! NSHTTPURLResponse
            let headers : NSDictionary = response.allHeaderFields
            
            let cookie = headers["Set-Cookie"] as? NSString ?? ""
            let atgSession = headers["JSESSIONATG"] as? NSString ?? ""
            if cookie != "" {
                if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                    
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response.URL!)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
                    for cookie in cookies {
                        print("Response JSESSIONID:: \(cookie.value)")
                        UserCurrentSession.sharedInstance().JSESSIONID = cookie.value
                        CustomBarViewController.addOrUpdateParamNoUser("JSESSIONID", value: cookie.value)
                        print("name: \(cookie.name) value: \(cookie.value)")
                    }
                }
              
            }
            print("Response JSESSIONATG:: \(atgSession)")
            print("UserCurrentSession.sharedInstance().JSESSIONATG::  \(UserCurrentSession.sharedInstance().JSESSIONATG)")
            UserCurrentSession.sharedInstance().JSESSIONATG =  atgSession != "" ? atgSession as String :  UserCurrentSession.sharedInstance().JSESSIONATG
            CustomBarViewController.addOrUpdateParamNoUser("JSESSIONATG", value: UserCurrentSession.sharedInstance().JSESSIONATG)
            
            let resultJSON = json as! NSDictionary
            self.jsonFromObject(resultJSON)
            if let errorResult = self.validateCodeMessage(resultJSON) {
                if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                    if UserCurrentSession.hasLoggedUser() {
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
                    errorBlock!(errorResult)
                    return
                }
                //TAG Manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: errorResult.localizedDescription)
                errorBlock!(errorResult)
                return
            }
            successBlock!(resultJSON)
            }, failure: {(request:NSURLSessionDataTask?, error:NSError) in
                //TAG Manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: error.localizedDescription)
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                if error.code == -1001 || error.code == -1003 || error.code == -1009 {
                    let newError = NSError(domain: ERROR_SERIVCE_DOMAIN, code: -1, userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("conection.error",comment:"")])
                    errorBlock!(newError)
                    return
                }
                
                print("Response Error : \(error) \n Response \(request!.response)")
                errorBlock!(error)
        })
        
 
        
       return task!
    }
    
    func callGETService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callGETService(serviceUrl(),params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(serviceURL:String,params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        callGETService(afManager,serviceURL:serviceURL,params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(manager:AFHTTPSessionManager,serviceURL:String,params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.GET(serviceURL, parameters: params, progress: nil, success: {(request:NSURLSessionDataTask, json:AnyObject?) in
            
            //session --
            let response : NSHTTPURLResponse = request.response as! NSHTTPURLResponse
            let headers : NSDictionary = response.allHeaderFields
            
            let cookie = headers["Set-Cookie"] as? NSString ?? ""
            let atgSession = headers["JSESSIONATG"] as? NSString ?? ""
            if cookie != "" {
                if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                    
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response.URL!)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
                    for cookie in cookies {
                        UserCurrentSession.sharedInstance().JSESSIONID = cookie.value
                        CustomBarViewController.addOrUpdateParam("JSESSIONID", value: cookie.value)
                        print("name: \(cookie.name) value: \(cookie.value)")
                    }
                }
                
                
            }
            print("serviceUrl() \(self.serviceUrl())")
            print("Regresa JSESSIONATG \(atgSession)")
             print("UserCurrentSession.sharedInstance().JSESSIONATG \(UserCurrentSession.sharedInstance().JSESSIONATG)")
            UserCurrentSession.sharedInstance().JSESSIONATG = atgSession != "" ? atgSession as String  : UserCurrentSession.sharedInstance().JSESSIONATG
            if UserCurrentSession.sharedInstance().JSESSIONATG != ""{
                CustomBarViewController.addOrUpdateParam("JSESSIONATG", value: UserCurrentSession.sharedInstance().JSESSIONATG)
            }
            
           
            
           
            let resultJSON = json as! NSDictionary
            self.jsonFromObject(resultJSON)
            if let errorResult = self.validateCodeMessage(resultJSON) {
                //Tag Manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: errorResult.localizedDescription)
                
                if errorResult.code == self.needsToLoginCode()   {
                    if UserCurrentSession.hasLoggedUser() {
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
            }, failure: {(request:NSURLSessionDataTask?, error:NSError) in
                
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    BaseController.sendTagManagerErrors("ErrorEvent", detailError: error.localizedDescription)
                    self.callGETService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error)")
                //Tag Manager
                BaseController.sendTagManagerErrors("ErrorEvent", detailError: error.localizedDescription)
                errorBlock!(error)
        })
    }
    
    
    
    
    // MARK: - Service code validation
    
    func validateCodeMessage(response:NSDictionary) -> NSError? {
        if let codeMessage = response["codeMessage"] as? NSNumber {
            let message = response["message"] as! NSString
            if codeMessage.integerValue != 0  {
                print("error : Response with error \(message)")
                return NSError(domain: ERROR_SERIVCE_DOMAIN, code: codeMessage.integerValue, userInfo: [NSLocalizedDescriptionKey:message])
            }
        }
        return nil
    }
    
    // MARK: - File Manager
    
    func getFilePath(fileName:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray!
        let docPath = paths[0] as! NSString
        let path = docPath.stringByAppendingPathComponent(fileName)
        return path
    }
    
  
    
    func saveDictionaryToFile(dictionary:NSDictionary,fileName:String) {
        let filePath = getFilePath(fileName)
        let data : NSData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            var error:NSError?
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                print(error)
            }
        }
        data.writeToFile(filePath, atomically: true)
    }
    
    func getDataFromFile(fileName:NSString) -> NSDictionary? {
        let path = self.getFilePath(fileName as String)
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            var jsonData: NSData?
            do {
                jsonData = try NSData(contentsOfFile:path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch {
                jsonData = nil
            }
            let values = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
            return values
        }else {
            if let pathResource = NSBundle.mainBundle().pathForResource(NSURL(string:fileName.lastPathComponent)!.URLByDeletingPathExtension?.absoluteString, ofType:fileName.pathExtension ) {
                var jsonData: NSData?
                do {
                    jsonData = try NSData(contentsOfFile:pathResource, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                } catch {
                    jsonData = nil
                }
                let values = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                return values
            }
        }
        return nil
    }

    
    
    func saveKeywords(items:NSArray) {
        //Creating keywords
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                for idx in 0 ..< items.count {
                    if let item = items[idx] as? NSDictionary {
                        if let desc = item[JSON_KEY_DESCRIPTION] as? String {
                            let description = desc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

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

                            let select = WalMartSqliteDB.instance.buildFindProductKeywordQuery(description: description, price: price!)
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
                            
                            let query = WalMartSqliteDB.instance.buildInsertProductKeywordQuery(forUpc: upc!, andDescription: description, andPrice:price!)
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
        let data : NSData = try! NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
        let jsonTxt = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(jsonTxt)
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
                    let name = item["description"] as! String
                    let idDepto = item["idDepto"] as! String
                    let famArray : AnyObject = item["family"] as AnyObject!
                    
                    for itemFamily in famArray as! [AnyObject] {
                        let idFamily = itemFamily["id"] as! String
                        let lineArray : AnyObject = itemFamily["line"] as AnyObject!
                        let namefamily = itemFamily["name"] as! String
                        for itemLine in lineArray as! [AnyObject] {
                            let idLine =  itemLine["id"] as! String
                            let nameLine =  itemLine["name"] as! String
                            let select = WalMartSqliteDB.instance.buildFindCategoriesKeywordQuery(categories: nameLine, departament: "\(name) > \(namefamily)", type:type, idLine:idLine)
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
                            
                            let query = WalMartSqliteDB.instance.buildInsertCategoriesKeywordQuery(forCategorie: nameLine, andDepartament: name, andType:type, andLine:idLine, andFamily:idFamily, andDepto:idDepto,family:namefamily,line:nameLine)
                            db.executeUpdate(query, withArgumentsInArray: nil)
                            
                            
                        }
                    }
                }
            }
        })
    }
    
    
    
    func printTimestamp(message: String) {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        print("\(message)"  + timestamp)
    }
    
    func callPOSTServiceCam(manager:AFHTTPSessionManager, params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.POST(serviceUrl(), parameters: nil, constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
            let imgData = params.objectForKey("image_request[image]") as! NSData
            let localeStr = params.objectForKey("image_request[locale]") as! String
            let langStr = params.objectForKey("image_request[language]") as! String
            formData.appendPartWithFileData(imgData, name: "image_request[image]", fileName: "image.jpg", mimeType: "image/jpeg")
            formData.appendPartWithFormData(localeStr.dataUsingEncoding(NSUTF8StringEncoding)!, name:"image_request[locale]")
            formData.appendPartWithFormData(langStr.dataUsingEncoding(NSUTF8StringEncoding)!, name:"image_request[language]")
            }, progress: nil, success: {(request:NSURLSessionDataTask, json:AnyObject?) in
                let resultJSON = json as! NSDictionary
                if let errorResult = self.validateCodeMessage(resultJSON) {
                    //TAG manager
                    BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: errorResult.localizedDescription)
                    
                    if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                        if UserCurrentSession.hasLoggedUser() {
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
            }, failure: {(request:NSURLSessionDataTask?, error:NSError) in
                //TAG manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: error.localizedDescription)
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error) \n Response \(request!.response)")
                errorBlock!(error)
        })
    }

    
}

