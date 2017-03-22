//
//  IPOSplashViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData
import AFNetworking

struct ShoppingCartParams {
    static var maxProducts : Int = 5
}



struct ConfigServices {
    static var ConfigIdMG : String = "clusterWMURLServices"
    static var ConfigIdGRSign : String = "clusterWMGroceriesURLServicesSession"
    static var ConfigIdGR : String = "clusterWMGroceriesURLServices"
    
    static var ConfigIdMGSignals : String = "clusterWMURLSignalsServices"
    static var ConfigIdGRSignals : String = "clusterWMGroceriesURLSignalsServices"
    static var ConfigIdGRSignalsSing : String = "clusterWMGroceriesURLSignalsServicesSession"
  
    
    static var camfindparams : String = ""
}


struct RecommendedCategory {
    static var cagtegories : [Any] = []
    static var groceriescategory : [String:Any] = [:]
    
}




class IPOSplashViewController : IPOBaseController,UIWebViewDelegate,NSURLConnectionDelegate  {
    
    var webViewSplash: UIWebView!
    var splashDefault: UIImageView!
    var paramsSetup: [[String:String]]!
    
    var currentVersion: Double = 0.0
    var minimumVersion: Double = 0.0
    
    var blockScreen :Bool = false
    var splashTTL : Double = 1.0
    
    var didHideSplash: (() -> Void)? = nil
    var validateVersion: ((_ force: Bool) -> Void)? = nil
    
    deinit{
        print("Deinit splash")
    }
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SPLASH.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paramsSetup = []
        
        splashDefault = UIImageView(frame: self.view.bounds)
        splashDefault.image = UIImage(named: "spash_iphone")
        //splashDefault = UIImageView(image: UIImage(named: "spash_iphone"))
        
        
        webViewSplash = UIWebView(frame:self.view.bounds)
        webViewSplash.delegate = self
        webViewSplash.contentMode = UIViewContentMode.center
        webViewSplash.scalesPageToFit = false
        self.view.addSubview(webViewSplash)
      
      
        configSplashAndGoToHome()
        
        
        self.view.addSubview(splashDefault)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        splashDefault.frame = self.view.bounds
        webViewSplash.frame = self.view.bounds
    }
    
    func retrieveParam(_ key: String) -> Param? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let user = UserCurrentSession.sharedInstance.userSigned
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Param", in: context)
        if user != nil {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, user!)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, NSNull())
        }
        var result: [Param]? = nil
        do{
            result = try context.fetch(fetchRequest) as? [Param]
        }catch{
            print("retrieveParam error in executeFetchRequest")
        }
        var parameter: Param? = nil
        if result != nil && result!.count > 0 {
            parameter = result!.first
        }
        return parameter
    }
    
    func gotohomecontroller(){
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.allowAnimatedContent, animations: { () -> Void in
            self.view.alpha = 0
            }, completion: { (end:Bool) -> Void in
                if  self.view.superview != nil {
                    self.view.superview!.isUserInteractionEnabled = true
                }
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                
                if self.didHideSplash != nil {
                    self.didHideSplash!()
                }
        })
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url!.absoluteString.hasPrefix("ios:") {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.splashDefault.alpha = 0
                }, completion: { (response:Bool) -> Void in
                    self.splashDefault.removeFromSuperview()
            }) 
            return false
        }
        //else {
       //     NSURLConnection(request: request, delegate: self)
       // }
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
    func configureWebView(_ itemsconfig: [String:Any]) -> Bool {
        
        
        if let block = itemsconfig["block"] as? Bool {
            blockScreen = block
            if blockScreen {
                splashDefault.image = UIImage(named: "splash_ups_4")
                return blockScreen
            }

        }
        if let ttlsplash = itemsconfig["ttl"] as? Double {
            splashTTL = ttlsplash
        }
        if let maxproducts = itemsconfig["maxproducts"] as? Int {
            ShoppingCartParams.maxProducts = maxproducts
        }
        
        if let serviceapp = itemsconfig["newServiceUrl"] as? String {
            if serviceapp == "standalone" {
                ConfigServices.ConfigIdMG = "WMURLServices"
                ConfigServices.ConfigIdGRSign = "WMGroceriesURLServicesSession"
                ConfigServices.ConfigIdGR = "WMGroceriesURLServices"
                
                ConfigServices.ConfigIdMGSignals = "WMURLSignalsServices"
                ConfigServices.ConfigIdGRSignals = "WMGroceriesURLSignalsServices"
                ConfigServices.ConfigIdGRSignalsSing = "WMGroceriesURLSignalsServicesSession"
                
             
            }
        }
        
        if let camfindparams = itemsconfig["camfindparams"] as? String {
                ConfigServices.camfindparams = camfindparams
        }
        
        
        
        if let currentVersionVal = itemsconfig["currentVersion"] as? Double {
            currentVersion = currentVersionVal
        }
        if let minimumVersionVal = itemsconfig["minimumVersion"] as? Double {
            minimumVersion = minimumVersionVal
        }
        if currentVersion > 0 && minimumVersion > 0 {
            if let majorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? NSString {
                if currentVersion > majorVersion.doubleValue  {
                    let force = minimumVersion > majorVersion.doubleValue
                    if validateVersion  != nil {
                        validateVersion!(force)
                    }
                }
            }
            
        }
        
        
        configureSplash()
        return false
    }
    
    func configureSplash() {
        if !blockScreen {
            UIView.animate(withDuration: 0.4, delay: splashTTL, options: UIViewAnimationOptions.allowAnimatedContent, animations: { () -> Void in
                self.view.alpha = 0
                }, completion: { (end:Bool) -> Void in
                    if  self.view.superview != nil {
                        self.view.superview!.isUserInteractionEnabled = true
                    }
                    
                    URLCache.shared.removeAllCachedResponses()
                    self.webViewSplash.removeFromSuperview()
                    self.webViewSplash = nil
                    
                    self.removeFromParentViewController()
                    self.view.removeFromSuperview()
                    if self.didHideSplash != nil {
                        self.didHideSplash!()
                    }
            })
        }
    }
    
    func serviceUrl(_ serviceName:String) -> String {
        //DynatraceUEM.startupWithApplicationName("Walmart MG Movil", serverURL: "https://www.walmartmobile.com.mx/walmartmg/dynaTraceMonitor", allowAnyCert: true, certificatePath: nil)
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMURLServices") as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        return serviceURL
    }
    
    func configSplashAndGoToHome() {
        let confServ = ConfigService()
        confServ.callService([:], successBlock: { (result:[String:Any]) -> Void in

//            Meter validacion
            if UserCurrentSession.sharedInstance.JSESSIONID != "" {
                 self.afterConfigService(result: result)
            }else{
            let authorizationService =  AuthorizationService()
            authorizationService.callGETService("", successBlock: { (response:[String:Any]) in
            //--
                //TODO afterConfig service
                self.afterConfigService(result: result)
            //--
                // ---
                },errorBlock:{ (error:NSError) in
                    print("error : authorizationService")
                    print(error.localizedDescription)
                    self.afterConfigService(result: result)
            })
            }
            
        }) { (error:NSError) -> Void in
            self.gotohomecontroller()
        }
    }
    
    func afterConfigService(result:[String:Any]){
        var error: NSError?
        
        let isBlock =  self.configureWebView(result)
        
        if !isBlock {
            
            IPOSplashViewController.callUpdateServices()
            UserCurrentSession.sharedInstance.finishConfig  = true
            
            self.invokeServiceToken()
            //TODO : Agrer todo lo de abajo a este succes
            if error == nil{
                print("WalmartMG.Splash")
                print(NSURL(string:self.serviceUrl("WalmartMG.Splash"))!)
                print( UIApplication.shared.canOpenURL(NSURL(string:self.serviceUrl("WalmartMG.Splash"))! as URL))
                
                
                
                
                if let privateNot = result["privaceNotice"] as? [[String:Any]] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let sinceDate = dateFormatter.date(from: privateNot[0]["sinceDate"] as! String)!
                    let untilDate = dateFormatter.date(from: privateNot[0]["untilDate"] as! String)!
                    let version = privateNot[0]["version"] as! NSNumber
                    let versionAP = "AP\(version)" as String!
                    var isReviewActive : NSString = "false"
                    
                    if let value = result["isReviewActive"] as? NSString {
                        isReviewActive = value
                    }
                    
                    UserCurrentSession.sharedInstance.dateStart = sinceDate
                    UserCurrentSession.sharedInstance.dateEnd = untilDate
                    UserCurrentSession.sharedInstance.version = versionAP
                    
                    UserCurrentSession.sharedInstance.isReviewActive = isReviewActive.boolValue
                    
                    if let commensChck = result["alertComment"] as? [[String:Any]] {
                        if let active = commensChck[0]["isActive"] as? Bool {
                            UserCurrentSession.sharedInstance.activeCommens = active
                        }
                        if let message = commensChck[0]["message"] as? String {
                            UserCurrentSession.sharedInstance.messageInCommens = message
                        }
                        if let upcs = commensChck[0]["upcs"] as? [String] {
                            UserCurrentSession.sharedInstance.upcSearch = upcs
                        }
                        
                    }
                    
                    
                    var requiredAP = true
                    if let param = self.retrieveParam(versionAP!) {
                        requiredAP = !(param.value == "false")
                    }
                    
                    
                    if requiredAP {
                        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                        let filePath = paths.appendingPathComponent("AvisoPrivacidad.pdf")
                        //                    var checkValidation = NSFileManager.defaultManager()
                        if (FileManager.default.fileExists(atPath: filePath)) {
                            do {
                                try FileManager.default.removeItem(atPath: filePath)
                            } catch let error1 as NSError {
                                error = error1
                            } catch {
                                fatalError()
                            }
                        }
                        
                        let privaceNotice = result["privaceNotice"] as? [[String:Any]]
                        let url = privaceNotice?[0]["url"] as! String
                        let request = NSURLRequest(url: NSURL(string:url)! as URL)
                        let configuration = URLSessionConfiguration.default
                        let manager = AFURLSessionManager(sessionConfiguration: configuration)
                        let downloadTask = manager.downloadTask(with: request as URLRequest, progress: nil, destination: { (url:URL, urlResponse:URLResponse) -> URL in
                            let file =  try? FileManager.default.url(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                            return file!.appendingPathComponent("AvisoPrivacidad.pdf")
                        }, completionHandler: { (response:URLResponse, fileUrl:URL?, error:Error?) -> Void in
                            print("File Path : \(fileUrl)")
                        })
                        downloadTask.resume()
                    }
                    
                    
                }
                self.webViewSplash.loadRequest(NSURLRequest(url: NSURL(string:self.serviceUrl("WalmartMG.Splash"))! as URL) as URLRequest)
                UserCurrentSession.sharedInstance.searchForCurrentUser()
            }
        }
        
        
        
    }
    
    func invokeServiceToken(){
        
        let idDevice = UIDevice.current.identifierForVendor!.uuidString
        let notService = NotificationService()
        let showNotificationParam = CustomBarViewController.retrieveParam("showNotification", forUser: false)
        
        let showNotification = showNotificationParam == nil ? true : (showNotificationParam!.value == "true")
        if  UserCurrentSession.sharedInstance.deviceToken != "" {
            
            let params = notService.buildParams(UserCurrentSession.sharedInstance.deviceToken, identifierDevice: idDevice, enablePush: !showNotification)
            print("Splash")
            print(notService.jsonFromObject(params as AnyObject!))
            notService.callPOSTService(params, successBlock: { (result:[String:Any]) -> Void in
                //println( "Registrado para notificaciones")
                
            }) { (error:NSError) -> Void in
                print( "Error device token: \(error.localizedDescription)" )
            }
        }
    }
    
    class func callUpdateServices() {
                
        let categoryService = CategoryService()
        categoryService.callService(Dictionary<String, String>(),
            successBlock: { (response:[String:Any]) -> Void in print("Call service CategoryService success") },
            errorBlock: { (error:NSError) -> Void in print("Call service CategoryService error \(error)") }
        )
        
        let categoryGRService = GRCategoryService()
        categoryGRService.callService(Dictionary<String, String>(),
            successBlock: { (response:[String:Any]) -> Void in print("Call service GRCategoryService success") },
            errorBlock: { (error:NSError) -> Void in print("Call service CategoryService error \(error)") }
        )
        
        let caroService = CarouselService()
        let caroparams = Dictionary<String, String>()
        caroService.callService(caroparams, successBlock: { (result:[String:Any]) -> Void in
            print("Call service caroService success")
            }) { (error:NSError) -> Void in
                print("Call service caroService error \(error)")
        }

        
        IPOSplashViewController.updateUserData(false)
    }
    
    class func updateUserData(_ invokeService: Bool) {
        
        
        /*let shoppingCartUpdateBg = ShoppingCartProductsService()
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartBegin.rawValue, object: nil)
        println("Call service ShoppingCartProductsService start")
        shoppingCartUpdateBg.callService([:], successBlock: { (result:[String:Any]) -> Void in
        println("Call service ShoppingCartProductsService success")
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartEnd.rawValue, object: nil)
        }, errorBlock: { (error:NSError) -> Void in
        //if error.code != -100 {
        println("Call service ShoppingCartProductsService error")
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartEnd.rawValue, object: nil)
        //}
        })*/
        
        UserCurrentSession.sharedInstance.loadShoppingCarts { () -> Void in
            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
        }
        
        let banService = BannerService()
        let params = Dictionary<String, String>()
        banService.callService(params, successBlock: { (result:[String:Any]) -> Void in
            
            }) { (error:NSError) -> Void in
                print("Call service BannerService error \(error)")
        }
        
        if invokeService {
            let caroService = CarouselService()
            let caroparams = Dictionary<String, String>()
            caroService.callService(caroparams, successBlock: { (result:[String:Any]) -> Void in
                print("Call service BannerService success")
                }) { (error:NSError) -> Void in
                    print("Call service BannerService error \(error)")
            }
        }
        
    }
    
}
