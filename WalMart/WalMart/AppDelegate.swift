//
//  AppDelegate.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import TwitterKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
                            
    var window: UIWindow?
    var imgView: UIImageView? = nil
    var alertNoInternet: IPOWMAlertViewController? = nil

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //White status bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //Push notifications
         if #available(iOS 8.0, *) {
          if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
                let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
                let setting = UIUserNotificationSettings(forTypes: type, categories: nil);
                UIApplication.sharedApplication().registerUserNotificationSettings(setting);
                UIApplication.sharedApplication().registerForRemoteNotifications();
            }
        }
         else {
           application.registerForRemoteNotificationTypes( [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert] )
        }
        
        //Twitter
        Fabric.with([Twitter.self])
        
        //Facebook
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKAppEvents.activateApp()
        //UserCurrentSession.sharedInstance().searchForCurrentUser()
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20
        // Optional: set Logger to VERBOSE for debug information.
        GAI.sharedInstance().logger.logLevel = .None
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().trackerWithTrackingId(WMGAIUtils.GAI_APP_KEY.rawValue)
        
        let fbDeferredAppLink: FBSDKDeferredAppLinkHandler = {(url: NSURL?, error: NSError?) in
            if (error != nil) {
                print("Received error while fetching deferred app link %@", error);
            }
            if (url != nil) {
                UIApplication.sharedApplication().openURL(url!)
            }
        }
        
        FBSDKAppLinkUtility.fetchDeferredAppLink(fbDeferredAppLink)
      
        
        //Google Login
        GIDSignIn.sharedInstance().clientID = NSBundle.mainBundle().objectForInfoDictionaryKey("GoogleClientId") as! String
        

        //Set url image cache to application
        let sharedCache  = NSURLCache(memoryCapacity: 0, diskCapacity: 100 * 1024 * 1024 , diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
        
     
        let paths = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true) as NSArray!
        let docPath = paths[0] as! String
        let todeletecloud =  NSURL(fileURLWithPath: docPath)
        do {
            try todeletecloud.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
        } catch let error1 as NSError {
            print(error1.description)
        }
        
        //Log request
        AFNetworkActivityLogger.sharedLogger().startLogging()
        AFNetworkActivityLogger.sharedLogger().level = AFHTTPRequestLoggerLevel.AFLoggerLevelDebug

        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status:AFNetworkReachabilityStatus) -> Void in
            switch (status) {
            case AFNetworkReachabilityStatus.NotReachable:
                if self.alertNoInternet == nil {
                    self.alertNoInternet = IPOWMAlertViewController.showAlert(UIImage(named:"noRed"),imageDone: nil, imageError: nil)
                     self.alertNoInternet?.setMessage("Por favor verifica tu conexión a internet")
                }
                break;
            case AFNetworkReachabilityStatus.ReachableViaWiFi:
                if self.alertNoInternet != nil {
                    self.alertNoInternet?.close()
                    self.alertNoInternet = nil
                }
                break;
            case AFNetworkReachabilityStatus.ReachableViaWWAN:
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
        
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        let storyboard = loadStoryboardDefinition()
        let vc : AnyObject! = storyboard!.instantiateViewControllerWithIdentifier("principalVC")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = vc as! UIViewController!
        self.window!.makeKeyAndVisible()
        
        if launchOptions != nil {
            if let remoteNotifParam = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject:AnyObject] {
                handleNotification(application,userInfo: remoteNotifParam)
            }
            
            if let localNotifParam = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                handleLocalNotification(application, localNotification: localNotifParam)
            }
        }
        
        //PayPal
        let payPalEnvironment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMPayPalEnvironment") as! NSDictionary
        let sandboxClientID = payPalEnvironment.objectForKey("SandboxClientID") as! String
        let productionClientID =  payPalEnvironment.objectForKey("ProductionClientID") as! String
        PayPalMobile.initializeWithClientIdsForEnvironments([PayPalEnvironmentProduction:productionClientID,PayPalEnvironmentSandbox:sandboxClientID])
        
        //MERCURY
        //TODO: Uncomment
        //MercuryService.sharedInstance().startMercuryService()
        
        //Tune.framework
        //let mobileAppTracking =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMMobileAppTracking") as! NSDictionary
        //let advertiserId = mobileAppTracking.objectForKey("Advertiser_id") as! String
        //let conversionKey =  mobileAppTracking.objectForKey("Conversion_key") as! String
        //Tune.initializeWithTuneAdvertiserId(advertiserId, tuneConversionKey:conversionKey)
        //Tune.setDelegate(self)
        //Tune.setDebugMode(true)
        //Tune.setAllowDuplicateRequests(false)
        //CompuwareUEM.startupWithApplicationName("WalMart", serverURL:"https://www.walmartmobile.com.mx/walmartmg/", allowAnyCert: false, certificatePath: nil)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        let controller = UIApplication.sharedApplication().keyWindow!.rootViewController
        let presented = controller!.presentedViewController
        presented?.dismissViewControllerAnimated(false, completion: nil)
        if imgView == nil {
            imgView = UIImageView(frame: controller!.view.bounds)
            imgView!.image = UIImage(named:"spash_iphone")
        }
        controller!.view.addSubview(imgView!)
        controller!.view.bringSubviewToFront(imgView!)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        IPOSplashViewController.updateUserData(true)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateNotificationBadge.rawValue, object: nil)
        //Facebook
        FBSDKAppEvents.activateApp()
        
        //MERCURY
        //TODO: Uncomment
        //MercuryService.sharedInstance().updateMercuryService()

        
        if imgView != nil {
            imgView!.removeFromSuperview()
            IPOSplashViewController.updateUserData(true)
        }
        
        //Tune.framework
        //Tune.measureSession()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bcg.dev.WalMart" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("WalMart", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("WalMart.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [NSObject : AnyObject]()
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
        let storyboardName = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
    

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        NSLog("Device token: \(deviceTokenString)")
        print("Device token: \(deviceTokenString)")
        
        UserCurrentSession.sharedInstance().deviceToken = deviceTokenString
        
        
        let idDevice = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let notService = NotificationService()
        let params = notService.buildParams(deviceTokenString, identifierDevice: idDevice, enablePush: true)
        if UserCurrentSession.sharedInstance().finishConfig {
            notService.callPOSTService(params, successBlock: { (result:NSDictionary) -> Void in
                //println( "Registrado para notificaciones")
                CustomBarViewController.addOrUpdateParam("showNotification", value: "true",forUser: false)
            }) { (error:NSError) -> Void in
                print( "Error device token: \(error.localizedDescription)" )
            }
        }
        
        print("deviceTokenString \(deviceTokenString)" )
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        
        print( error.localizedDescription )
    }
    
    class func scaleFactor() -> CGFloat {
        if UIScreen.mainScreen().respondsToSelector(#selector(UIScreen.displayLinkWithTarget(_:selector:))) {
            return UIScreen.mainScreen().scale
        }
        return 1.0
    }
    
    class func separatorHeigth() -> CGFloat {
        return 1.0 / scaleFactor()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let controller = UIApplication.sharedApplication().keyWindow!.rootViewController
        let presented = controller!.presentedViewController
        presented?.dismissViewControllerAnimated(false, completion: nil)
       UIApplication.sharedApplication().applicationIconBadgeNumber = 1
       NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateNotificationBadge.rawValue, object: nil)
        self.handleNotification(application,userInfo: userInfo)
        
        //MERCURY
        //TODO: Uncomment
        //MercuryService.sharedInstance().startMercuryService()

    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let controller = UIApplication.sharedApplication().keyWindow!.rootViewController
        let presented = controller!.presentedViewController
        presented?.dismissViewControllerAnimated(false, completion: nil)
        self.handleLocalNotification(application, localNotification: notification)
    }
    
    func handleLocalNotification(application: UIApplication, localNotification notification: UILocalNotification){
        let name = notification.userInfo!["name"] as! String
        let value = notification.userInfo!["value"] as! String
        let bussines = notification.userInfo!["business"] as! String
        let listName =  notification.userInfo![REMINDER_PARAM_LISTNAME] as! String
        
        if let ipaCustomBar = self.window?.rootViewController as? IPACustomBarViewController{
            if (application.applicationState == UIApplicationState.Background ||  application.applicationState == UIApplicationState.Inactive)
            {
                ipaCustomBar.handleNotification(value,name:name,value:value,bussines:bussines)
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
                        
                        ipaCustomBar.handleNotification(value,name:name,value:value,bussines:bussines)
                        alertNot?.close()
                    },isNewFrame: false)
            }
        }
        
        else if let customBar = self.window?.rootViewController as? CustomBarViewController{
            if (application.applicationState == UIApplicationState.Background ||  application.applicationState == UIApplicationState.Inactive)
            {
                customBar.handleNotification(value,name:name,value:value,bussines:bussines)
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
                        
                        customBar.handleNotification(value,name:name,value:value,bussines:bussines)
                        alertNot?.close()
                    },isNewFrame: false)
            }
        }

    }

    func handleNotification(application: UIApplication,userInfo: [NSObject : AnyObject]) {
        if let notiicationInfo = userInfo["notification"] as? NSDictionary {
            
            //let notiicationInfo = userInfo["notification"] as! NSDictionary
            let notiicationAPS = userInfo["aps"] as! NSDictionary
            let type = notiicationInfo["type"] as! String
            let name = notiicationInfo["name"] as! String
            let value = notiicationInfo["value"] as! String
            let message = notiicationAPS["alert"] as! String
            let bussines = notiicationInfo["business"] as! String
            
            let serviceSave = NotificationFileService()
            serviceSave.saveNotification(userInfo)
            
            if let customBar = self.window?.rootViewController as? CustomBarViewController {
               
                if (application.applicationState == UIApplicationState.Background ||  application.applicationState == UIApplicationState.Inactive)
                {
                    customBar.helpView?.removeFromSuperview()
                    customBar.handleNotification(type,name:name,value:value,bussines:bussines)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("OPEN_TUTORIAL", object: nil)
                    let alertNot = IPAWMAlertViewController.showAlert(UIImage(named:"special"),imageDone:UIImage(named:"special"),imageError:UIImage(named:"special"))
                    alertNot?.showDoneIconWithoutClose()
                    alertNot?.setMessage(message)
                    alertNot?.addActionButtonsWithCustomText(NSLocalizedString("noti.keepshopping",comment:""), leftAction: { () -> Void in
                        alertNot?.close()
                        }, rightText: NSLocalizedString("noti.godetail",comment:""), rightAction: { () -> Void in
                            
                            //Obtiene vista de login
                            if let viewLogin =  customBar.view.viewWithTag(5000) {
                                viewLogin.removeFromSuperview()
                            }
                            
                            customBar.handleNotification(type,name:name,value:value,bussines:bussines)
                            alertNot?.close()
                        },isNewFrame: true)
                }
            }
        }
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    }
  
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        handleURL(url)
        return true
    }
    

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
       
        //Tune.applicationDidOpenURL(url.absoluteString, sourceApplication: sourceApplication)
        //Quitar para produccion
        handleURLFacebook(url,sourceApplication:sourceApplication!)
        handleURL(url)
        let fb = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
        //var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!,UIApplicationOpenURLOptionsAnnotationKey: annotation]
        let gid = GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
        return fb || gid
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        
            return GIDSignIn.sharedInstance().handleURL(url,
                                                        sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                        annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    func handleURLFacebook(url: NSURL,sourceApplication:String){
        let parsedUrl = BFURL(inboundURL:url, sourceApplication:sourceApplication)
        let stringCompare = parsedUrl.targetURL.absoluteString as NSString
        let rangeEnd = stringCompare.rangeOfString("walmartmexicoapp://")
        
        if rangeEnd.location != NSNotFound {
            if (parsedUrl.appLinkData != nil) {
            
                let targetUrl:NSURL =  parsedUrl.targetURL
                NSLog("targetUrl::\(targetUrl)")
                
                let strAction = stringCompare.stringByReplacingOccurrencesOfString("walmartmexicoapp://", withString: "") as NSString
                var components = strAction.componentsSeparatedByString("/")
                
                if let customBar = self.window!.rootViewController as? CustomBarViewController {
                    let srtBussines  = components[0].componentsSeparatedByString("_")[1]
                    let srtType  = components[1].componentsSeparatedByString("_")[1]
                    let srtValue  = components[2].componentsSeparatedByString("_")[1]
                //TODO validar como llegara los links
                    customBar.handleNotification(srtType.uppercaseString,name:"",value:srtValue,bussines:srtBussines.lowercaseString)
                }
                //TODO quitar en produccion 
//                UIAlertView(title: "Received link:",
//                    message:targetUrl.absoluteString, delegate: nil,
//                    cancelButtonTitle: "ok").show()
            }else{
                //let targetUrl:NSURL =  parsedUrl.targetURL
                let strAction = stringCompare.stringByReplacingOccurrencesOfString("walmartmexicoapp://", withString: "") as NSString
                var components = strAction.componentsSeparatedByString("&")
                
                if let customBar = self.window!.rootViewController as? CustomBarViewController {
                    let srtBussines  = components[0].componentsSeparatedByString("_")[1]
                    let srtType  = components[1].componentsSeparatedByString("_")[1]
                    let srtValue  = components[2].componentsSeparatedByString("_")[1]
                    var schoolName = ""
                    var grade = ""
                    
                    if components.count > 3 {
                        schoolName = components[3].componentsSeparatedByString("_")[1]
                        schoolName = schoolName.stringByReplacingOccurrencesOfString("-", withString: " ").stringByRemovingPercentEncoding!
                        grade = components[4].componentsSeparatedByString("_")[1]
                        grade = grade.stringByReplacingOccurrencesOfString("-", withString: " ").stringByRemovingPercentEncoding!
                    }
                    customBar.handleListNotification(srtType,name:"",value:srtValue,bussines:srtBussines,schoolName: schoolName,grade:grade)
                }

            }
        }
    }
    
    
    
    func handleURL(url: NSURL){
        let stringCompare = url.absoluteString as NSString
        let rangeEnd = stringCompare.rangeOfString("walmartmg://")
        if rangeEnd.location != NSNotFound {
            let strAction = stringCompare.stringByReplacingOccurrencesOfString("walmartmg://", withString: "") as NSString
            var components = strAction.componentsSeparatedByString("_")
            if(components.count > 1){
                if let customBar = self.window!.rootViewController as? CustomBarViewController {
                    let cmpStr  = components[0] 
                    let strValue = strAction.stringByReplacingOccurrencesOfString("\(cmpStr)_", withString: "")
                    customBar.handleNotification(cmpStr,name:"",value:strValue,bussines:"mg")
                }
            }
        }

    }
    
    
    func readNotificationFile() {
        
    }
    
    func writeNotificationFile() {
        
    }
    
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
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
            if (application.applicationState == UIApplicationState.Background ||  application.applicationState == UIApplicationState.Inactive)
            {
                if self.alertNoInternet == nil{
                      customBar.handleNotification(strType,name:"",value:"",bussines:"")
                }
            }
        }
        
    }
    
    //MARK: TuneDelegate
    func tuneDidSucceedWithData(data: NSData!) {
        let response = NSString(data: data, encoding:NSUTF8StringEncoding)
        NSLog("Tune.success: %@", response!);

    }
    
    
    func tuneDidFailWithError(error: NSError!) {
        NSLog("Tune.failure: %@", error);
    }
}  
