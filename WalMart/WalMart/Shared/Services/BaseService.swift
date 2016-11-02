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
    private static var __once: () = {
            AFStatic.manager = AFHTTPSessionManager()
            AFStatic.manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            //AFStatic.manager.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.Certificate)
            //AFStatic.manager.securityPolicy.validatesCertificateChain = false
            AFStatic.manager.securityPolicy.allowInvalidCertificates = true
            
        
            AFStatic.managerGR = AFHTTPSessionManager()
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            //AFStatic.managerGR.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.Certificate)
            //AFStatic.managerGR.securityPolicy.validatesCertificateChain = false
            AFStatic.managerGR.securityPolicy.allowInvalidCertificates = true
        }()
    struct AFStatic {
        static var cookie : String!
        static var manager : AFHTTPSessionManager!
        static var managerGR : AFHTTPSessionManager!
        static var onceToken : Int = 0
    }
    
    var urlForSession = false
    var useSignalsServices = false
    
    override init() {
        super.init()
        _ = BaseService.__once
        
    }
    
    // MARK: - Service url helpers
    func serviceUrl() -> (String){
        let stringOfClassType: String = nameOfClass(type(of: self))
        return serviceUrl(stringOfClassType)
    }
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let serviceConfigDictionary = ConfigServices.ConfigIdMG
        
//        if useSignalsServices {
//            //serviceConfigDictionary =  ConfigServices.ConfigIdMGSignals
//        }
        
        let services = Bundle.main.object(forInfoDictionaryKey: serviceConfigDictionary) as! NSDictionary
        let environmentServices = services.object(forKey: environment) as! NSDictionary
        let serviceURL =  environmentServices.object(forKey: serviceName) as! String
        return serviceURL
    }
    
    func nameOfClass(_ classType: AnyClass) -> String {
        let stringOfClassType: String = NSStringFromClass(classType)
        return stringOfClassType
    }
    
    
    // MARK: - Request service
    
    
    
    func getManager() -> AFHTTPSessionManager {
        
        let lockQueue = DispatchQueue(label: "com.test.LockQueue", attributes: [])
        lockQueue.sync {
            if self.shouldIncludeHeaders() { //UserCurrentSession.hasLoggedUser() && 
                let timeInterval = Date().timeIntervalSince1970
                let timeStamp  = String(NSNumber(value: (timeInterval * 1000) as Double).intValue)
                let uuid  = UUID().uuidString
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
    
    func retrieve(_ entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil) -> AnyObject {
        return retrieve(entityName, sortBy:sortBy , isAscending:isAscending, predicate:predicate,expression:nil)
    }

    
    func retrieve(_ entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil,expression :NSExpressionDescription?) -> AnyObject {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        if (sortBy != nil) {
            let sorter = NSSortDescriptor(key:sortBy! , ascending:isAscending)
            request.sortDescriptors = [sorter]
        }
        
        if expression != nil {
            request.resultType = NSFetchRequestResultType.dictionaryResultType;
            request.propertiesToFetch = [expression!];
        }
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        return fetchedResult! as AnyObject
    }

    
    func callPOSTService(_ params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) -> URLSessionDataTask {
        let afManager = getManager()
        let url = serviceUrl()
   
        let task = afManager.post(url, parameters: params, success: {(request:URLSessionDataTask!, json:Any!) in
            let resultJSON = json as! NSDictionary
            self.jsonFromObject(resultJSON)
            if let errorResult = self.validateCodeMessage(resultJSON) {
                if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                    if UserCurrentSession.hasLoggedUser() {
                        let loginService = LoginWithIdService()
                        let idUser = UserCurrentSession.sharedInstance.userSigned!.idUser
                        loginService.callService(["profileId":idUser], successBlock: { (response:NSDictionary) -> Void in
                            self.callPOSTService(params, successBlock: successBlock, errorBlock: errorBlock)
                            }, errorBlock: { (error:NSError) -> Void in
                                UserCurrentSession.sharedInstance.userSigned = nil
                             NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UserLogOut.rawValue), object: nil)
                        })
                    }
                    errorBlock!(errorResult)
                    return
                }
                errorBlock!(errorResult)
                return
            }
             successBlock!(resultJSON)
            }, failure: {(request:URLSessionDataTask!, error:NSError!) in
                
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                if error.code == -1001 || error.code == -1003 || error.code == -1009 {
                    let newError = NSError(domain: ERROR_SERIVCE_DOMAIN, code: -1, userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("conection.error",comment:"")])
                    errorBlock!(newError)
                    return
                }
                
                print("Response Error : \(error) \n Response \(request.response)")
                errorBlock!(error)
        })
       return task
    }
    
    func callGETService(_ params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callGETService(serviceUrl(),params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(_ serviceURL:String,params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        callGETService(afManager,serviceURL:serviceURL,params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(_ manager:AFHTTPSessionManager,serviceURL:String,params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.get(serviceURL, parameters: params, success: {(request:URLSessionDataTask!, json:AnyObject!) in
            let resultJSON = json as! NSDictionary
            if let errorResult = self.validateCodeMessage(resultJSON) {
                if errorResult.code == self.needsToLoginCode()   {
                    if UserCurrentSession.hasLoggedUser() {
                        let loginService = LoginWithIdService()
                        let idUser = UserCurrentSession.sharedInstance.userSigned!.idUser
                        loginService.callService(["profileId":idUser], successBlock: { (response:NSDictionary) -> Void in
                            //TODO:QUITAR IMPORTANTE DESCOMENTAR
                            self.callGETService(params, successBlock: successBlock, errorBlock: errorBlock)
                            }, errorBlock: { (error:NSError) -> Void in
                                UserCurrentSession.sharedInstance.userSigned = nil
                                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UserLogOut.rawValue), object: nil)
                        })
                        return
                    }
                }
                errorBlock!(errorResult)
                return
            }
            successBlock!(resultJSON)
            }, failure: {(request:URLSessionDataTask!, error:NSError!) in
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request.response)")
                    self.callGETService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error)")
                errorBlock!(error)
        })
        
    }
    
    
    
    
    // MARK: - Service code validation
    
    func validateCodeMessage(_ response:NSDictionary) -> NSError? {
        if let codeMessage = response["codeMessage"] as? NSNumber {
            var messages =  ""
            if  let message = response["message"] as? NSString{
                messages = message as String
            }
            
            if codeMessage.intValue != 0  {
                print("error : Response with error \(messages)")
                return NSError(domain: ERROR_SERIVCE_DOMAIN, code: codeMessage.intValue, userInfo: [NSLocalizedDescriptionKey:messages])
            }
        }
        return nil
    }
    
    // MARK: - File Manager
    
    func getFilePath(_ fileName:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray!
        let docPath = paths?[0] as! NSString
        let path = docPath.appendingPathComponent(fileName)
        return path
    }
    
  
    
    func saveDictionaryToFile(_ dictionary:NSDictionary,fileName:String) {
        let filePath = getFilePath(fileName)
        let data : Data = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        if FileManager.default.fileExists(atPath: filePath) {
            var error:NSError?
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                print(error)
            }
        }
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    func getDataFromFile(_ fileName:NSString) -> NSDictionary? {
        let path = self.getFilePath(fileName as String)
        if FileManager.default.fileExists(atPath: path) {
            var jsonData: Data?
            do {
                jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
            } catch {
                jsonData = nil
            }
            let values = (try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary
            return values
        }else {
            if let pathResource = Bundle.main.path(forResource: NSURL(string:fileName.lastPathComponent)!.deletingPathExtension?.absoluteString, ofType:fileName.pathExtension ) {
                var jsonData: Data?
                do {
                    jsonData = try Data(contentsOf: URL(fileURLWithPath: pathResource), options: NSData.ReadingOptions.mappedIfSafe)
                } catch {
                    jsonData = nil
                }
                let values = (try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary
                return values
            }
        }
        return nil
    }

    
    
    func saveKeywords(_ items:NSArray) {
        //Creating keywords
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async(execute: { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                for idx in 0 ..< items.count {
                    if let item = items[idx] as? NSDictionary {
                        if let desc = item[JSON_KEY_DESCRIPTION] as? String {
                            let description = desc.trimmingCharacters(in: CharacterSet.whitespaces)

                            var upc = item["upc"] as? String
                            upc = upc!.trimmingCharacters(in: CharacterSet.whitespaces)

                            var price: String?
                            if let pricetxt = item["price"] as? String {
                                price = pricetxt.trimmingCharacters(in: CharacterSet.whitespaces)
                            }
                            if let pricenum = item["price"] as? NSNumber {
                                price = pricenum.stringValue
                            }
                            
                            if price == nil {
                                continue
                            }

                            let select = WalMartSqliteDB.instance.buildFindProductKeywordQuery(description: description, price: price!)
                            if let rs = db.executeQuery(select, withArgumentsIn:nil) {
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
                            db.executeUpdate(query, withArgumentsIn: nil)
                        }
                    }
                }
            }
        })
    }
    
    
    func shouldIncludeHeaders() -> Bool {
        return true
    }

    func jsonFromObject(_ object:AnyObject!) {
        let data : Data = try! JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        let jsonTxt = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        print(jsonTxt)
    }
    
    func needsLogin() -> Bool {
        return true
    }
    
    
    func needsToLoginCode() -> Int {
        return -100
    }
    
    
    

    func loadKeyFieldCategories( _ items:AnyObject!, type:String ) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async(execute: { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase) -> Void in
                //let items : AnyObject = self.getCategoriesContent() as AnyObject!;
                for item in (items as? [Any])! {
                    let name = item["DepartmentName"] as? String ?? ""
                    let idDepto = item["idDept"] as! String
                    let dicItem = item as! NSDictionary
                    let items :AnyObject? =  dicItem["familyContent"]
                    if  items !=  nil {
                        let famArray : AnyObject = item["familyContent"] as AnyObject!
                        let bussines = item["bussines"] as? String ?? ""
                        
                        
                        for itemFamily in famArray as! [Any] {
                            let idFamily = itemFamily["id"] as? String ?? ""
                            if itemFamily.count > 1 {
                                
                                let itemdic = itemFamily as! NSDictionary
                                let itemsContent :AnyObject? =  itemdic["fineContent"]
                                if  itemsContent !=  nil {
                                    let lineArray : AnyObject = itemFamily["fineContent"] as AnyObject!
                                    let namefamily = itemFamily["familyName"] as! String
                                    for itemLine in lineArray as! [Any] {
                                        let idLine =  itemLine["id"] as! String
                                        let nameLine =  itemLine["displayName"] as! String
                                        let select = WalMartSqliteDB.instance.buildFindCategoriesKeywordQuery(categories: nameLine, departament: "\(name) > \(namefamily)", type:bussines, idLine:idLine)
                                        if let rs = db.executeQuery(select, withArgumentsIn:nil) {
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
                                        
                                        let query = WalMartSqliteDB.instance.buildInsertCategoriesKeywordQuery(forCategorie: nameLine, andDepartament: name, andType:bussines, andLine:idLine, andFamily:idFamily, andDepto:idDepto,family:namefamily,line:nameLine)
                                        db.executeUpdate(query, withArgumentsIn: nil)
                                        
                                        
                                    }
                                }//items !=  nil
                            }//Close count
                        }//for
                    }//Close if
                }
            }
        })
    }
    
    
    
    func printTimestamp(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        print("\(message)"  + timestamp)
    }
    
    func callPOSTServiceCam(_ manager:AFHTTPSessionManager, params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.post(serviceUrl(), parameters: nil,
            constructingBodyWith: { (formData: AFMultipartFormData!) in
                let imgData = params.object(forKey: "image_request[image]") as! Data
                let localeStr = params.object(forKey: "image_request[locale]") as! String
                let langStr = params.object(forKey: "image_request[language]") as! String
                formData.appendPart(withFileData: imgData, name: "image_request[image]", fileName: "image.jpg", mimeType: "image/jpeg")
                formData.appendPart(withForm: localeStr.data(using: String.Encoding.utf8), name:"image_request[locale]")
                formData.appendPart(withForm: langStr.data(using: String.Encoding.utf8), name:"image_request[language]")
            },
            success: {(request:URLSessionDataTask!, json:AnyObject!) in
                let resultJSON = json as! NSDictionary
                if let errorResult = self.validateCodeMessage(resultJSON) {
                    if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                        if UserCurrentSession.hasLoggedUser() {
                            let loginService = LoginWithIdService()
                            let idUser = UserCurrentSession.sharedInstance.userSigned!.idUser
                            loginService.callService(["profileId":idUser], successBlock: { (response:NSDictionary) -> Void in
                                self.callPOSTService(params, successBlock: successBlock, errorBlock: errorBlock)
                                }, errorBlock: { (error:NSError) -> Void in
                                    UserCurrentSession.sharedInstance.userSigned = nil
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UserLogOut.rawValue), object: nil)
                            })
                        }
                        return
                    }
                    errorBlock!(errorResult)
                    return
                }
                successBlock!(resultJSON)
            },
            failure: {(request:URLSessionDataTask!, error:NSError!) in
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error) \n Response \(request.response)")
                errorBlock!(error)
        })
    }

    
}

