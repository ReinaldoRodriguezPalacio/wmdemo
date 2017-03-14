//
//  BaseService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData
import AFNetworking

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
    private static var __once: () = {
            AFStatic.manager = AFHTTPSessionManager()
            AFStatic.manager.requestSerializer = AFJSONRequestSerializer()
            AFStatic.manager.responseSerializer = AFJSONResponseSerializer()
            AFStatic.manager.responseSerializer.acceptableContentTypes = nil
            AFStatic.manager.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
            AFStatic.manager.securityPolicy.allowInvalidCertificates = true
            AFStatic.manager.securityPolicy.validatesDomainName = false
        
            AFStatic.managerGR = AFHTTPSessionManager()
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer()
            AFStatic.managerGR.responseSerializer = AFJSONResponseSerializer()
            AFStatic.managerGR.responseSerializer.acceptableContentTypes = nil
            AFStatic.managerGR.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
            AFStatic.managerGR.securityPolicy.allowInvalidCertificates = true
            AFStatic.managerGR.securityPolicy.validatesDomainName = false
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
        var serviceConfigDictionary = ConfigServices.ConfigIdMG
        
        if useSignalsServices {
            serviceConfigDictionary =  ConfigServices.ConfigIdMGSignals
        }
        
        let services = Bundle.main.object(forInfoDictionaryKey: serviceConfigDictionary) as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
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
            var jsessionIdSend = ""
            var jSessionAtgIdSend = UserCurrentSession.sharedInstance.JSESSIONATG
            
                if let param2 = CustomBarViewController.retrieveParamNoUser(key: "JSESSIONID") {
                    //print("PARAM JSESSIONID ::"+param2.value)
                    jsessionIdSend = param2.value
                }
                if let param3 = CustomBarViewController.retrieveParamNoUser(key: "JSESSIONATG") {
                    //print("PARAM JSESSIONATG ::" + param3.value)
                    jSessionAtgIdSend = param3.value
                }
           
            
            
            if UserCurrentSession.hasLoggedUser() && self.shouldIncludeHeaders() {
                let timeInterval = Date().timeIntervalSince1970
                let timeStamp  = String(NSNumber(value: (timeInterval * 1000) as Double).intValue)
                let uuid  = UUID().uuidString
                let strUsr  = "ff24423eefbca345" + timeStamp + uuid
                AFStatic.manager.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
                AFStatic.manager.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
                AFStatic.manager.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control")
                //Session --
                
                //print("URL:: \(self.serviceUrl())")
                print("send::sessionID mg -- \(jsessionIdSend) ATGID -- \(jSessionAtgIdSend) \(self.serviceUrl())")
                
               
                AFStatic.manager.requestSerializer.setValue("JSESSIONID=\(jsessionIdSend)", forHTTPHeaderField:"Cookie")
                AFStatic.manager.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
                AFStatic.manager.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
                
                
                
            } else{
                //Session --
                //print("URL:: \(self.serviceUrl())")
                 print("send::sessionID mg -- \(jsessionIdSend) ATGID -- \(jSessionAtgIdSend) \(self.serviceUrl())")
                AFStatic.manager.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
                    AFStatic.manager.requestSerializer.setValue("JSESSIONID=\(jsessionIdSend)", forHTTPHeaderField:"Cookie")
                    AFStatic.manager.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
                    AFStatic.manager.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
            
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
        let request    =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName as String)
        
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

    
    func callPOSTService(_ params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        let url = serviceUrl()
        print(url)
        print("callPOSTService params ::\(params)")
        afManager.post(url, parameters: params, progress: nil, success: {(request:URLSessionDataTask, json:Any?) in
            //session --
            //TODO Loginbyemail
            let response : HTTPURLResponse = request.response as! HTTPURLResponse
            let headers : [String:Any] = response.allHeaderFields as! [String : Any]
            let cookie = headers["Set-Cookie"] as? NSString ?? ""
            let atgSession = headers["JSESSIONATG"] as? NSString ?? ""
             let stringOfClassType: String = self.nameOfClass(type(of: self))
             var jsessionId_array :[String] = []
            
            if cookie != "" {
                print("Before : \(headers)")
                let httpResponse = response
                if let fields = httpResponse.allHeaderFields as? [String : String] {
                    
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response.url!)
                    HTTPCookieStorage.shared.setCookies(cookies, for: response.url!, mainDocumentURL: nil)
                    for cookie in cookies {
                        print("Response JSESSIONID::  \(cookie.name)  -- \(cookie.value) -- \(self.serviceUrl())")
                        if cookie.name == "JSESSIONID" &&  self.needsSaveSeion(cassType: stringOfClassType){
                            print("cookie.name == JSESSIONID")
                            jsessionId_array.append(cookie.value)
                            if cookie.value != "" {
                                
                                CustomBarViewController.addOrUpdateParamNoUser(key: "JSESSIONID", value: cookie.value)
                            }else{
                            print("JSESSIONID VACIO DE  \(stringOfClassType)")
                            }
                            print("name: \(cookie.name) value: \(cookie.value)")
                        }
                    }
                }
                
            }else{
                print(headers)
                print("noooooo post cookie \(stringOfClassType)")
            }
            print("ARRAY POST:: JSESSIONID")
            print(jsessionId_array)
            print("....")
            

             print("PostClassName \(stringOfClassType)")
            print("Response JSESSIONATG:: \(atgSession) -- \(self.serviceUrl())")
            UserCurrentSession.sharedInstance.JSESSIONATG =  atgSession != "" ? atgSession as String :  UserCurrentSession.sharedInstance.JSESSIONATG
            CustomBarViewController.addOrUpdateParamNoUser(key: "JSESSIONATG", value: UserCurrentSession.sharedInstance.JSESSIONATG)
            
            
            let resultJSON = json as! [String:Any]
              //print("callPOSTService resultJSON ::\(resultJSON)")
            if let errorResult = self.validateCodeMessage(resultJSON) {
                if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                    if UserCurrentSession.hasLoggedUser() {
                        
                        //NSLog("Base Service : LoginWithEmailService", "\(self.serviceUrl())")
                        let loginService = LoginWithEmailService()
                        loginService.loginIdGR = UserCurrentSession.sharedInstance.userSigned!.idUserGR as String
                        let emailUser = UserCurrentSession.sharedInstance.userSigned!.email
                        loginService.callService(["email":emailUser], successBlock: { (response:[String:Any]) -> Void in
                            self.callPOSTService(params, successBlock: successBlock, errorBlock: errorBlock)
                            }, errorBlock: { (error:NSError) -> Void in
                                UserCurrentSession.sharedInstance.userSigned = nil
                                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UserLogOut.rawValue), object: nil)
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
            }, failure: {(request:URLSessionDataTask?, error:Error) in
                //TAG Manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: error.localizedDescription)
                if (error as NSError).code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                if (error as NSError).code == -1001 || (error as NSError).code == -1003 || (error as NSError).code == -1009 {
                    let newError = NSError(domain: ERROR_SERIVCE_DOMAIN, code: -1, userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("conection.error",comment:"")])
                    errorBlock!(newError)
                    return
                }
                
                print("Response Error : \(error) \n Response \(request!.response)")
                errorBlock!((error as NSError))
        })

    }
    
    func callGETService(_ params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callGETService(serviceUrl(),params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(_ serviceURL:String,params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        callGETService(afManager,serviceURL:serviceURL,params:params,successBlock:successBlock, errorBlock:errorBlock)
    }
    
    func callGETService(_ manager:AFHTTPSessionManager,serviceURL:String,params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print(self.serviceUrl())
        print("callGETService params ::\(params)")
        manager.get(serviceURL, parameters: params, progress: nil, success: {(request:URLSessionDataTask, json:Any?) in
            
            //session --
            let response : HTTPURLResponse = request.response as! HTTPURLResponse
            let headers : [String:Any] = response.allHeaderFields as! [String : Any]
            let cookie = headers["Set-Cookie"] as? NSString ?? ""
            let atgSession = headers["JSESSIONATG"] as? NSString ?? ""
            let stringOfClassType: String = self.nameOfClass(type(of: self))
            var jsessionId_array :[String] = []

            if cookie != "" {
                let httpResponse = response
                if let fields = httpResponse.allHeaderFields as? [String : String] {
                    
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response.url!)
                    HTTPCookieStorage.shared.setCookies(cookies, for: response.url!, mainDocumentURL: nil)
                    
                    if stringOfClassType != "WalmartMG.ConfigService" {
                        for cookie in cookies {
                            print("Response JSESSIONID::  \(cookie.name)  -- \(cookie.value) - \(self.serviceUrl())")
                            if cookie.name == "JSESSIONID" && self.needsSaveSeion(cassType: stringOfClassType){
                                print("cookie.name == JSESSIONID")
                               jsessionId_array.append(cookie.value)
                                if cookie.value != "" {
                                    print("SAVE  JSESSIONID ame: \(cookie.name) value: \(cookie.value)")
                                    CustomBarViewController.addOrUpdateParam("JSESSIONID", value: cookie.value)
                                }else{
                                    print("JSESSIONID vacio DE: : \(stringOfClassType)")
                                }
                                print("classname:\(stringOfClassType) name: \(cookie.name) value: \(cookie.value)")
                            }
                        }
                    }
                }
                
                
            }else{
                print("nooooooo :: cookie \(stringOfClassType)")
            }
            print("ARRAY GET:: JSESSIONID")
            print(jsessionId_array)
            print("....")
            
            if stringOfClassType != "WalmartMG.ConfigService" {
                print("GetClassName \(stringOfClassType)")
                print("Regresa JSESSIONATG \(atgSession)  -- \(self.serviceUrl()) ")
                
                UserCurrentSession.sharedInstance.JSESSIONATG = atgSession != "" ? atgSession as String  : UserCurrentSession.sharedInstance.JSESSIONATG
                if UserCurrentSession.sharedInstance.JSESSIONATG != ""{
                CustomBarViewController.addOrUpdateParam("JSESSIONATG", value: UserCurrentSession.sharedInstance.JSESSIONATG)
                }
            }
           
            
            
            let resultJSON = json as! [String:Any]
             //print("callPOSTService resultJSON ::\(resultJSON)")
            if let errorResult = self.validateCodeMessage(resultJSON) {
                //Tag Manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: errorResult.localizedDescription)
                
                if errorResult.code == self.needsToLoginCode()   {
                    if UserCurrentSession.hasLoggedUser() {
                        self.clearCokkie()
                        let loginService = LoginWithEmailService()
                        //loginService.loginIdGR = UserCurrentSession.sharedInstance.userSigned!.idUserGR
                        let emailUser = UserCurrentSession.sharedInstance.userSigned!.email
                        loginService.callService(["email":emailUser], successBlock: { (response:[String:Any]) -> Void in
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
            }, failure: {(request:URLSessionDataTask?, error:Error) in
                
               // print("Error en ::" + self.serviceUrl())
                if (error as NSError).code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    BaseController.sendTagManagerErrors("ErrorEvent", detailError: error.localizedDescription)
                    self.callGETService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \((error as NSError))")
                //Tag Manager
                BaseController.sendTagManagerErrors("ErrorEvent", detailError: error.localizedDescription)
                errorBlock!((error as NSError))
        })
    }
    
    
    
    
    // MARK: - Service code validation
    
    func validateCodeMessage(_ response:[String:Any]) -> NSError? {
        if let codeMessage = response["codeMessage"] as? NSNumber {
            let message = response["message"] as! NSString
            if codeMessage.intValue != 0  {
                print("error : Response with error \(message) \(self.serviceUrl())")
                return NSError(domain: ERROR_SERIVCE_DOMAIN, code: codeMessage.intValue, userInfo: [NSLocalizedDescriptionKey:message])
            }
        }
        return nil
    }
    
    // MARK: - File Manager
    
    func getFilePath(_ fileName:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [Any]!
        let docPath = paths?[0] as! NSString
        let path = docPath.appendingPathComponent(fileName)
        return path
    }
    
  
    
    func saveDictionaryToFile(_ dictionary:[String:Any],fileName:String) {
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
                print(error!)
            }
        }
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    func getDataFromFile(_ fileName:NSString) -> [String:Any]? {
        let path = self.getFilePath(fileName as String)
        if FileManager.default.fileExists(atPath: path) {
            var jsonData: Data?
            do {
                jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
            } catch {
                jsonData = nil
            }
            let values = (try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)) as! [String:Any]
            return values
        }else {
            if let pathResource = Bundle.main.path(forResource: NSURL(string:fileName.lastPathComponent)!.deletingPathExtension?.absoluteString, ofType:fileName.pathExtension ) {
                var jsonData: Data?
                do {
                    jsonData = try Data(contentsOf: URL(fileURLWithPath: pathResource), options: NSData.ReadingOptions.mappedIfSafe)
                } catch {
                    jsonData = nil
                }
                let values = (try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)) as! [String:Any]
                return values
            }
        }
        return nil
    }

    
    
    func saveKeywords(_ items:[Any]) {
        //Creating keywords
       DispatchQueue.global(qos: .background).async(execute: { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase?) -> Void in
                for idx in 0 ..< items.count {
                    if let item = items[idx] as? [String:Any] {
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
                            if let rs = db?.executeQuery(select, withArgumentsIn:nil) {
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
                            db?.executeUpdate(query, withArgumentsIn: nil)
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
        //print(jsonTxt!)
    }
    
    func needsLogin() -> Bool {
        return true
    }
    
    
    func needsToLoginCode() -> Int {
        return -100
    }
    
    func clearCokkie(){
        print("****************** ****************** ****************** ****************** ")
        print("clearCokkie clearCokkie clearCokkie")
         CustomBarViewController.addOrUpdateParamNoUser(key: "JSESSIONID", value:"")
        let coockieStorege  = HTTPCookieStorage.shared
        for cookie in coockieStorege.cookies! {
            coockieStorege.deleteCookie(cookie)
        }
        
    }
    
    func needsSaveSeion(cassType:String) -> Bool {
        if cassType == "WalmartMG.LoginService" || cassType == "WalmartMG.LoginWithEmailService" {
            print("needsSaveSeion::: \(cassType)")
            return true
        }else {
            if self.serviceUrl().lowercased().contains("/walmartmg/login/") || cassType == "WalmartMG.GRZipCodeService"{
                 print("nooo:: needsSaveSeion::: \(cassType)")
                return false
            }
            print("needsSaveSeion::: \(cassType)")
            return true
        }
    }
    
    
    

    func loadKeyFieldCategories( _ items:Any!, type:String ) {
        DispatchQueue.global(qos: .background).async(execute: { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase?) -> Void in
                //let items : AnyObject = self.getCategoriesContent() as AnyObject!;
                for item in items as! [[String:Any]] {
                   
                    let name = item["description"] as! String
                    let idDepto = item["idDepto"] as! String
                    
                    let famArray : AnyObject = item["family"] as AnyObject!
                    for itemFamily in famArray as! [[String:Any]] {
                        let idFamily = itemFamily["id"] as! String
                        let lineArray : AnyObject = itemFamily["line"] as AnyObject!
                        let namefamily = itemFamily["name"] as! String
                        for itemLine in lineArray as! [[String:Any]] {
                            let idLine =  itemLine["id"] as! String
                            let nameLine =  itemLine["name"] as! String
                            let select = WalMartSqliteDB.instance.buildFindCategoriesKeywordQuery(categories: nameLine, departament: "\(name) > \(namefamily)", type:type, idLine:idLine)
                            if let rs = db?.executeQuery(select, withArgumentsIn:nil) {
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
                            db?.executeUpdate(query, withArgumentsIn: nil)
                            
                            
                        }
                    }
                }
            }
        })
    }
    
    
    
    func printTimestamp(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        print("\(message)"  + timestamp)
    }
    
    func callPOSTServiceCam(_ manager:AFHTTPSessionManager, params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        manager.post(serviceUrl(), parameters: nil, constructingBodyWith: { (formData: AFMultipartFormData!) in
            let imgData = params["image_request[image]"] as! Data
            let localeStr = params["image_request[locale]"] as! String
            let langStr = params["image_request[language]"] as! String
            formData.appendPart(withFileData: imgData, name: "image_request[image]", fileName: "image.jpg", mimeType: "image/jpeg")
            formData.appendPart(withForm: localeStr.data(using: String.Encoding.utf8)!, name:"image_request[locale]")
            formData.appendPart(withForm: langStr.data(using: String.Encoding.utf8)!, name:"image_request[language]")
            }, progress: nil, success: {(request:URLSessionDataTask, json:Any?) in
                let resultJSON = json as! [String:Any]
                if let errorResult = self.validateCodeMessage(resultJSON) {
                    //TAG manager
                    BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: errorResult.localizedDescription)
                    
                    if errorResult.code == self.needsToLoginCode() && self.needsLogin() {
                        if UserCurrentSession.hasLoggedUser() {
                           
                            let loginService = LoginWithEmailService()
                            loginService.loginIdGR = UserCurrentSession.sharedInstance.userSigned!.idUserGR as String
                            let emailUser = UserCurrentSession.sharedInstance.userSigned!.email
                            loginService.callService(["email":emailUser], successBlock: { (response:[String:Any]) -> Void in
                                self.callPOSTService(params, successBlock: successBlock, errorBlock: errorBlock)
                                }, errorBlock: { (error:NSError) -> Void in
                                    UserCurrentSession.sharedInstance.userSigned = nil
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.UserLogOut.rawValue), object: nil)
                            })
                        }
                        return
                    }
                    
                    errorBlock!(errorResult)
                    return
                }
                
                successBlock!(resultJSON)
            }, failure: {(request:URLSessionDataTask?, error:Error) in
                //TAG manager
                BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: error.localizedDescription)
                if (error as NSError).code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    self.callPOSTService(params,successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error) \n Response \(request!.response)")
                errorBlock!((error as NSError))
        })
    }

    
}

