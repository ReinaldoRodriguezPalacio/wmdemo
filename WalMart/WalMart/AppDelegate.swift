//
//  AppDelegate.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import FBNotifications
import FBSDKCoreKit
import FBSDKLoginKit
import AFNetworking
import AFNetworkActivityLogger
//import FBNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,TAGContainerOpenerNotifier {//TuneDelegate
                            
    var window: UIWindow?
    var imgView: UIImageView? = nil
    var alertNoInternet: IPOWMAlertViewController? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //White status bar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        
        //Push notifications
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: nil);
            UIApplication.shared.registerUserNotificationSettings(setting);
            UIApplication.shared.registerForRemoteNotifications();
        }
        
        
        //Facebook
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKAppEvents.activateApp()
       
        //Session --
        let authorizationService =  AuthorizationService()
        authorizationService.callGETService("", successBlock: { (response:[String:Any]) in
            UserCurrentSession.sharedInstance.searchForCurrentUser()
            },errorBlock:{ (error:NSError) in
                print(error.localizedDescription)
                
        })
        
//        // Optional: automatically send uncaught exceptions to Google Analytics.
//        GAI.sharedInstance().trackUncaughtExceptions = true
//        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//        GAI.sharedInstance().dispatchInterval = 20
//        // Optional: set Logger to VERBOSE for debug information.
//        GAI.sharedInstance().logger.logLevel = .None
//        // Initialize tracker. Replace with your tracking ID.
//        //GAI.sharedInstance().trackerWithTrackingId(WMGAIUtils.GAI_APP_KEY.rawValue)
        
        let fbDeferredAppLink: FBSDKDeferredAppLinkHandler = {(url: URL?, error: Error?) in
            if (error != nil) {
                print("Received error while fetching deferred app link %@", error!);
            }
            if (url != nil) {
                UIApplication.shared.openURL(url!)
            }
        }
        
        FBSDKAppLinkUtility.fetchDeferredAppLink(fbDeferredAppLink)
      

        //Set url image cache to application
        let sharedCache  = URLCache(memoryCapacity: 0, diskCapacity: 100 * 1024 * 1024 , diskPath: nil)
        URLCache.shared = sharedCache
        
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true) as NSArray!
        let docPath = paths?[0] as! String
        let todeletecloud =  URL(fileURLWithPath: docPath)
        do {
            try (todeletecloud as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch let error1 as NSError {
            print(error1.description)
        }
        
        //Log request
        AFNetworkActivityLogger.shared().startLogging()
        //AFNetworkActivityLogger.sharedLogger().level = AFHTTPRequestLoggerLevel.AFLoggerLevelDebug

        
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status:AFNetworkReachabilityStatus) -> Void in
            switch (status) {
            case AFNetworkReachabilityStatus.notReachable:
                if self.alertNoInternet == nil {
                    self.alertNoInternet = IPOWMAlertViewController.showAlert(UIImage(named:"noRed"),imageDone: nil, imageError: nil)
                     self.alertNoInternet?.setMessage("Por favor verifica tu conexión a internet")
                }
                break;
            case AFNetworkReachabilityStatus.reachableViaWiFi:
                if self.alertNoInternet != nil {
                    self.alertNoInternet?.close()
                    self.alertNoInternet = nil
                }
                break;
            case AFNetworkReachabilityStatus.reachableViaWWAN:
                if self.alertNoInternet != nil {
                    self.alertNoInternet?.close()
                    self.alertNoInternet = nil
                }
                break;
            default:
                if self.alertNoInternet == nil {
                    self.alertNoInternet = IPOWMAlertViewController.showAlert(UIImage(named:"noRed"),imageDone: nil, imageError: nil)
                     self.alertNoInternet?.setMessage("Por favor verifica tu conexión a internet")
                }
                break;
            }
        }
        
        
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        
        let storyboard = loadStoryboardDefinition()
        let vc : AnyObject! = storyboard!.instantiateViewController(withIdentifier: "principalVC")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = vc as! UIViewController!
        self.window!.makeKeyAndVisible()
        
        if launchOptions != nil {
            if let remoteNotifParam = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
                handleNotification(application,userInfo: remoteNotifParam)
            }
            
            if let localNotifParam = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                handleLocalNotification(application, localNotification: localNotifParam)
            }
        }
        
        //PayPal
        let payPalEnvironment =  Bundle.main.object(forInfoDictionaryKey: "WMPayPalEnvironment") as! [String:Any]
        let sandboxClientID = payPalEnvironment["SandboxClientID"] as! String
        let productionClientID =  payPalEnvironment["ProductionClientID"] as! String
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:productionClientID,PayPalEnvironmentSandbox:sandboxClientID])
        
        
        //Tune.framework
        //let mobileAppTracking =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMMobileAppTracking") as! [String:Any]
        //let advertiserId = mobileAppTracking.objectForKey("Advertiser_id") as! String
        //let conversionKey =  mobileAppTracking.objectForKey("Conversion_key") as! String
        //Tune.initializeWithTuneAdvertiserId(advertiserId, tuneConversionKey:conversionKey)
        //Tune.setDelegate(self)
        //Tune.setDebugMode(true)
        //Tune.setAllowDuplicateRequests(false)
        //CompuwareUEM.startupWithApplicationName("WalMart", serverURL:"https://www.walmartmobile.com.mx/walmartmg/", allowAnyCert: false, certificatePath: nil)
        NSSetUncaughtExceptionHandler { exception in
            
            let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
            dataLayer.push(["event": "ErrorEventCrash", "detailErrorCrash": exception.description ])

            
            NSLog("CRASH: \(exception)")
            NSLog("Stack Trace: \(exception.callStackSymbols)")
        }
        
        
        
        //TAGManager
        let GTM = TAGManager.instance()
        GTM?.logger.setLogLevel(kTAGLoggerLogLevelVerbose)
    
        //TODO Cambiar a produccion 
        //TAGContainerOpener.openContainer(withId: "GTM-TCGRR6", //Produccion
       TAGContainerOpener.openContainer(withId: "GTM-N7Z7PWM",// Desarrollo
            tagManager: GTM, openType: kTAGOpenTypePreferFresh,
            timeout: nil,
            notifier: self)
        
        
        
      
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        let controller = UIApplication.shared.keyWindow!.rootViewController
        let presented = controller!.presentedViewController
        presented?.dismiss(animated: false, completion: nil)
        if imgView == nil {
            imgView = UIImageView(frame: controller!.view.bounds)
            imgView!.image = UIImage(named:"spash_iphone")
        }
        controller!.view.addSubview(imgView!)
        controller!.view.bringSubview(toFront: imgView!)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        IPOSplashViewController.updateUserData(true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateNotificationBadge.rawValue), object: nil)
        //Facebook
        FBSDKAppEvents.activateApp()

        
        if imgView != nil {
            imgView!.removeFromSuperview()
            IPOSplashViewController.updateUserData(true)
        }
        
        //Tune.framework
        //Tune.measureSession()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bcg.dev.WalMart" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "WalMart", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("WalMart.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [AnyHashable: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain:"YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.current.userInterfaceIdiom == .phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        
        //let token = String(data: deviceToken.base64EncodedData(), encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        
//        let deviceTokenString: String = ( deviceToken.description as NSString )
//            .trimmingCharacters( in: characterSet )
//            .replacingOccurrences( of: " ", with: "" ) as String
        
        NSLog("Device token: hexString \(deviceToken.hexString)")
        print("Device token: hexString \(deviceToken.hexString)")
        //TODO
        
        FBSDKAppEvents.setPushNotificationsDeviceToken(deviceToken)

        UserCurrentSession.sharedInstance.deviceToken = deviceToken.hexString
        
        
        let idDevice = UIDevice.current.identifierForVendor!.uuidString
        let notService = NotificationService()
        
        let showNotificationParam = CustomBarViewController.retrieveParam("showNotification", forUser: false)
        let showNotification = showNotificationParam == nil ? true : (showNotificationParam!.value == "true")
        
        let params = notService.buildParams(deviceToken.hexString, identifierDevice: idDevice, enablePush: !showNotification)
        print("AppDelegate")
            print(notService.jsonFromObject(params as AnyObject!))
        if UserCurrentSession.sharedInstance.finishConfig {
           var _ = notService.callPOSTService(params, successBlock: { (result:[String:Any]) -> Void in
                print("Registrado para notificaciones \(result)")
                CustomBarViewController.addOrUpdateParam("showNotification", value: "true",forUser: false)
            }, errorBlock: { (error:NSError) -> Void in
                print( "Error device token: \(error.localizedDescription)" )
            })
        }
        

        print("deviceTokenString \(deviceToken.hexString)" )
    }
    

    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        print( error.localizedDescription )
    }
    
    class func scaleFactor() -> CGFloat {
        if UIScreen.main.responds(to: #selector(UIScreen.displayLink(withTarget:selector:))) {
            return UIScreen.main.scale
        }
        return 1.0
    }
    
    class func separatorHeigth() -> CGFloat {
        return 1.0 / scaleFactor()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let controller = UIApplication.shared.keyWindow!.rootViewController
        let presented = controller!.presentedViewController
        presented?.dismiss(animated: false, completion: nil)
        if userInfo["notification"] != nil {
            UIApplication.shared.applicationIconBadgeNumber = 1
        }
       
       NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateNotificationBadge.rawValue), object: nil)
        self.handleNotification(application,userInfo: userInfo)
       
        
        FBSDKAppEvents.logPushNotificationOpen(userInfo)
        
        FBNotificationsManager.shared().presentPushCard(forRemoteNotificationPayload: userInfo, from: nil, completion: { (control:FBNCardViewController?, error: Error?) in
            
        })
     
    
        
    }


    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let controller = UIApplication.shared.keyWindow!.rootViewController
        let presented = controller!.presentedViewController
        presented?.dismiss(animated: false, completion: nil)
        self.handleLocalNotification(application, localNotification: notification)
    }
    
    func handleLocalNotification(_ application: UIApplication, localNotification notification: UILocalNotification){
        let name = notification.userInfo!["name"] as! String
        let value = notification.userInfo!["value"] as! String
        let bussines = notification.userInfo!["business"] as! String
        let listName =  notification.userInfo![REMINDER_PARAM_LISTNAME] as! String
        
        if let ipaCustomBar = self.window?.rootViewController as? IPACustomBarViewController{
            if (application.applicationState == UIApplicationState.background ||  application.applicationState == UIApplicationState.inactive)
            {
                let _ = ipaCustomBar.handleNotification(value,name:name,value:value,bussines:bussines)
            }else{
                let alertNot = IPAWMAlertViewController.showAlert(UIImage(named:"reminder_alert"),imageDone:UIImage(named:"reminder_alert"),imageError:UIImage(named:"reminder_alert"))
                alertNot?.showDoneIconWithoutClose()
                alertNot?.setMessage(String(format: NSLocalizedString("list.reminder.alert.content", comment:""), listName))
                alertNot?.addActionButtonsWithCustomText(NSLocalizedString("noti.keepshopping",comment:""), leftAction: { () -> Void in
                    alertNot?.close()
                    }, rightText: NSLocalizedString("noti.godetail",comment:""), rightAction: { () -> Void in
                        
                        //Obtiene vista de login
                        if let viewLogin =  ipaCustomBar.view.viewWithTag(5000) {
                            viewLogin.removeFromSuperview()
                        }
                        
                        let _ = ipaCustomBar.handleNotification(value,name:name,value:value,bussines:bussines)
                        alertNot?.close()
                    },isNewFrame: false)
            }
        }
        
        else if let customBar = self.window?.rootViewController as? CustomBarViewController{
            if (application.applicationState == UIApplicationState.background ||  application.applicationState == UIApplicationState.inactive)
            {
                let _ = customBar.handleNotification(value,name:name,value:value,bussines:bussines)
            }else{
                let alertNot = IPOWMAlertViewController.showAlert(UIImage(named:"reminder_alert"),imageDone:UIImage(named:"reminder_alert"),imageError:UIImage(named:"reminder_alert"))
                alertNot?.showDoneIconWithoutClose()
                alertNot?.setMessage(String(format: NSLocalizedString("list.reminder.alert.content", comment:""), listName))
                alertNot?.addActionButtonsWithCustomText(NSLocalizedString("noti.keepshopping",comment:""), leftAction: { () -> Void in
                    alertNot?.close()
                    }, rightText: NSLocalizedString("noti.godetail",comment:""), rightAction: { () -> Void in
                        
                        //Obtiene vista de login
                        if let viewLogin =  customBar.view.viewWithTag(5000) {
                            viewLogin.removeFromSuperview()
                        }
                        
                        let _ = customBar.handleNotification(value,name:name,value:value,bussines:bussines)
                        alertNot?.close()
                    },isNewFrame: false)
            }
        }

    }

    func handleNotification(_ application: UIApplication,userInfo: [AnyHashable: Any]) {
        if let notiicationInfo = userInfo["notification"] as? [String:Any] {
            
            print(userInfo)
            //let notiicationInfo = userInfo["notification"] as! [String:Any]
            let notiicationAPS = userInfo["aps"] as! [String:Any]
            let type = notiicationInfo["type"] as! String
            let name = notiicationInfo["name"] as! String
            let value = notiicationInfo["value"] as! String
            let message = notiicationAPS["alert"] as! String
            let bussines = notiicationInfo["business"] as! String
            
            let serviceSave = NotificationFileService()
            serviceSave.saveNotification(userInfo)
            
            if let customBar = self.window?.rootViewController as? CustomBarViewController {
               
                var banner =  Banner()
                
                banner.id = value
                banner.name = value
                banner.creative = bussines
                banner.position = "1"
                
                if (application.applicationState == UIApplicationState.background ||  application.applicationState == UIApplicationState.inactive)
                {
                    customBar.helpView?.removeFromSuperview()
                    let _ = customBar.handleNotification(type,name:name,value:value,bussines:bussines)
                    
                    BaseController.sendAnalyticsClickBanner(banner)
                    
                }else{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "OPEN_TUTORIAL"), object: nil)
                    
                    let banners = [banner]
                    BaseController.sendAnalyticsBanners(banners)
                    
                    let alertNot = IPAWMAlertViewController.showAlert(UIImage(named:"special"),imageDone:UIImage(named:"special"),imageError:UIImage(named:"special"))
                    alertNot?.showDoneIconWithoutClose()
                    alertNot?.setMessage(message)
                    alertNot?.addActionButtonsWithCustomText(NSLocalizedString("noti.keepshopping",comment:""), leftAction: { () -> Void in
                        alertNot?.close()
                        }, rightText: NSLocalizedString("noti.godetail",comment:""), rightAction: { () -> Void in
                            
                            BaseController.sendAnalyticsClickBanner(banner)
                            
                            //Obtiene vista de login
                            if let viewLogin =  customBar.view.viewWithTag(5000) {
                                viewLogin.removeFromSuperview()
                            }
                            
                            let _ = customBar.handleNotification(type,name:name,value:value,bussines:bussines)
                            alertNot?.close()
                        },isNewFrame: false)
                }
            }
        }
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    }
  
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        handleURL(url)
        return true
    }
    

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       
        //Tune.applicationDidOpenURL(url.absoluteString, sourceApplication: sourceApplication)
        //Quitar para produccion
        handleURLFacebook(url,sourceApplication:sourceApplication!)
        
        
        handleURL(url)
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        //return true
    }
    
    func handleURLFacebook(_ url: URL,sourceApplication:String){
        let parsedUrl = BFURL(inboundURL:url, sourceApplication:sourceApplication)
        let stringCompare = parsedUrl!.targetURL.absoluteString as NSString
        let rangeEnd = stringCompare.range(of: "walmartmexicoapp://")
        
        if rangeEnd.location != NSNotFound {
            if (parsedUrl?.appLinkData != nil) {
            
                let targetUrl:URL =  parsedUrl!.targetURL
                NSLog("targetUrl::\(targetUrl)")
                
                let strAction = stringCompare.replacingOccurrences(of: "walmartmexicoapp://", with: "") as NSString
                var components = strAction.components(separatedBy: "/")
                
                if let customBar = self.window!.rootViewController as? CustomBarViewController {
                    let srtBussines  = components[0].components(separatedBy: "_")[1]
                    let srtType  = components[1].components(separatedBy: "_")[1]
                    let srtValue  = components[2].components(separatedBy: "_")[1]
                //TODO validar como llegara los links
                    let _ = customBar.handleNotification(srtType.uppercased(),name:"",value:srtValue,bussines:srtBussines.lowercased())
                }
                //TODO quitar en produccion 
//                UIAlertView(title: "Received link:",
//                    message:targetUrl.absoluteString, delegate: nil,
//                    cancelButtonTitle: "ok").show()
            }else{
                //let targetUrl:NSURL =  parsedUrl.targetURL
                let strAction = stringCompare.replacingOccurrences(of: "walmartmexicoapp://", with: "") as NSString
                var components = strAction.components(separatedBy: "&")
                
                if let customBar = self.window!.rootViewController as? CustomBarViewController {
                    let srtBussines  = components[0].components(separatedBy: "_")[1]
                    let srtType  = components[1].components(separatedBy: "_")[1]
                    let srtValue  = components[2].components(separatedBy: "_")[1]
                    var schoolName = ""
                    var grade = ""
                    
                    if components.count > 3 {
                        schoolName = components[3].components(separatedBy: "_")[1]
                        schoolName = (schoolName.replacingOccurrences(of: "-", with: " ")as NSString).removingPercentEncoding!
                        grade = components[4].components(separatedBy: "_")[1]
                        grade = (grade.replacingOccurrences(of: "-", with: " ")as NSString).removingPercentEncoding!
                    }
                    let _ = customBar.handleListNotification(srtType,name:"",value:srtValue,bussines:srtBussines,schoolName: schoolName,grade:grade)
                }

            }
        }
    }
    
    
    
    func handleURL(_ url: URL){
        let stringCompare = url.absoluteString as NSString
        let rangeEnd = stringCompare.range(of: "walmartmg://")
        if rangeEnd.location != NSNotFound {
            let strAction = stringCompare.replacingOccurrences(of: "walmartmg://", with: "") as NSString
            var components = strAction.components(separatedBy: "_")
            if(components.count > 1){
                if let customBar = self.window!.rootViewController as? CustomBarViewController {
                    let cmpStr  = components[0] 
                    let strValue = strAction.replacingOccurrences(of: "\(cmpStr)_", with: "")
                    let _ = customBar.handleNotification(cmpStr,name:"",value:strValue,bussines:"mg")
                }
            }
        }

    }
    
    
    func readNotificationFile() {
        
    }
    
    func writeNotificationFile() {
        
    }
    

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        FBSDKAppEvents.logPushNotificationOpen(userInfo, action: identifier)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        
       
        
        var strType = ""
        if shortcutItem.type == "com.bcg.opensearch" {
           strType = "SH"
        }
        
        if shortcutItem.type == "com.bcg.openshoppingcart" {
            strType = "CF"
        }
        
        if shortcutItem.type == "com.bcg.openlists" {
            strType = "WF"
        }
        
        if let customBar = self.window?.rootViewController as? CustomBarViewController {
            if (application.applicationState == UIApplicationState.background ||  application.applicationState == UIApplicationState.inactive)
            {
                if self.alertNoInternet == nil{
                      let _ = customBar.handleNotification(strType,name:"",value:"",bussines:"")
                }
            }
        }
        
    }
    
    //MARK: TuneDelegate
    func tuneDidSucceedWithData(_ data: Data!) {
        let response = NSString(data: data, encoding:String.Encoding.utf8.rawValue)
        NSLog("Tune.success: %@", response!);

    }
    
    func tuneDidFailWithError(_ error: NSError!) {
        NSLog("Tune.failure: %@", error);
    }
    
    //MARK: TAGContainerOpenerNotifier
    
    func containerAvailable(_ container: TAGContainer!) {
        container.refresh()
    }
    

}
