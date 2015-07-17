//
//  IPOSplashViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

struct ShoppingCartParams {
    static var maxProducts : Int = 10
}




struct RecommendedCategory {
    static var cagtegories : NSArray = []
    static var groceriescategory : [String:AnyObject] = [:]
    
}




class IPOSplashViewController : IPOBaseController,UIWebViewDelegate,NSURLConnectionDelegate  {
    
    var webViewSplash : UIWebView!
    var splashDefault : UIImageView!
    var paramsSetup : [[String:String]]!
    
    var currentVersion : Double = 0.0
    var minimumVersion : Double = 0.0
    
    var blockScreen :Bool = false
    var splashTTL : Double = 1.0
    
    var didHideSplash : (() -> Void)? = nil
    var validateVersion : ((force:Bool) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paramsSetup = []
        
        splashDefault = UIImageView(frame: self.view.bounds)
        splashDefault.image = UIImage(named: "spash_iphone")
        
        webViewSplash = UIWebView(frame:self.view.bounds)
        webViewSplash.delegate = self
        
        
        
        let confServ = ConfigService()
        confServ.callService([:], successBlock: { (result:NSDictionary) -> Void in
            var error: NSError?
            self.configureWebView(result)
            if error == nil {
                self.webViewSplash.loadRequest(NSURLRequest(URL: NSURL(string:self.serviceUrl("WalmartMG.Splash"))!))
            }else{
                self.gotohomecontroller()
            }
            
            }) { (error:NSError) -> Void in
            self.gotohomecontroller()
        }
        
            
        self.view.addSubview(webViewSplash)
        self.view.addSubview(splashDefault)
        
        callUpdateServices()
        
        
        
        
    }
    
    
    func gotohomecontroller(){
        UIView.animateWithDuration(0.4, delay: 0.3, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.view.alpha = 0
            }, completion: { (end:Bool) -> Void in
                if  self.view.superview != nil {
                    self.view.superview!.userInteractionEnabled = true
                }
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                
                if self.didHideSplash != nil {
                    self.didHideSplash!()
                }
        })
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        splashDefault.frame = self.view.bounds
        webViewSplash.frame = self.view.bounds
    }

    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {

        
        if request.URL.absoluteString!.hasPrefix("ios:") {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.splashDefault.alpha = 0
                }) { (response:Bool) -> Void in
                    self.splashDefault.removeFromSuperview()
            }
            return false
        }else {
            NSURLConnection(request: request, delegate: self)
        }
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {

        
    }
    

    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
    }
    func configureWebView(itemsconfig:NSDictionary) {
       
        
        if let block = itemsconfig["block"] as? Bool {
            blockScreen = block
        }
        if let ttlsplash = itemsconfig["ttl"] as? Double {
            splashTTL = ttlsplash
        }
        if let maxproducts = itemsconfig["maxproducts"] as? Int {
            ShoppingCartParams.maxProducts = maxproducts
        }
        if let specials = itemsconfig["specials"] as? NSArray {
            RecommendedCategory.cagtegories = specials
        }
        if let groceriescategory = itemsconfig["groceriescategory"] as? [String:AnyObject] {
            RecommendedCategory.groceriescategory = groceriescategory
        }
        
        
        if let currentVersionVal = itemsconfig["currentVersion"] as? Double {
            currentVersion = currentVersionVal
        }
        if let minimumVersionVal = itemsconfig["minimumVersion"] as? Double {
            minimumVersion = minimumVersionVal
        }
        if currentVersion > 0 && minimumVersion > 0 {
            if let majorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? NSString {
                if currentVersion > majorVersion.doubleValue  {
                    let force = minimumVersion > majorVersion.doubleValue
                    if validateVersion  != nil {
                        validateVersion!(force: force)
                    }
                }
            }
            
        }
        
     
        configureSplash()
    }
    
    func configureSplash() {
        if !blockScreen {
            UIView.animateWithDuration(0.4, delay: splashTTL, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
                self.view.alpha = 0
                }, completion: { (end:Bool) -> Void in
                    if  self.view.superview != nil {
                        self.view.superview!.userInteractionEnabled = true
                    }
                    
                    NSURLCache.sharedURLCache().removeAllCachedResponses()
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
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMURLServices") as NSDictionary
        let environmentServices = services.objectForKey(environment) as NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as String
        return serviceURL
    }

    
    
    func callUpdateServices() {
        
        let recommendedItems = RecommendedItemsService()
        let paramsRec = Dictionary<String, String>()
        recommendedItems.callService(paramsRec, successBlock: { (response:NSDictionary) -> Void in
            println("Call service RecommendedItemsService success")
            }) { (error:NSError) -> Void in
            println("Call service RecommendedItemsService error \(error)")
        }
        
        let exclusiveGrItems = GRExclusiveItemsService()
        let paramsExc = Dictionary<String, String>()
        exclusiveGrItems.callService(paramsRec, successBlock: { (response:NSDictionary) -> Void in
            println("Call service GRExclusiveItemsService success")
            }) { (error:NSError) -> Void in
                println("Call service GRExclusiveItemsService error \(error)")
        }
        
        
        let categoryService = CategoryService()
        categoryService.callService(Dictionary<String, String>(),
            successBlock: { (response:NSDictionary) -> Void in println("Call service CategoryService success") },
            errorBlock: { (error:NSError) -> Void in println("Call service CategoryService error \(error)") }
        )
        
        let categoryGRService = GRCategoryService()
        categoryGRService.callService(Dictionary<String, String>(),
            successBlock: { (response:NSDictionary) -> Void in println("Call service GRCategoryService success") },
            errorBlock: { (error:NSError) -> Void in println("Call service CategoryService error \(error)") }
        )
        
        let defaultlist = DefaultListService()
        defaultlist.callService({ (result:NSDictionary) -> Void in
            println("Call DefaultListService sucess")
            }, errorBlock: { (error:NSError) -> Void in
            println("Call DefaultListService error \(error)")
        })
        
        let storeService = StoreLocatorService()
        storeService.callService(
            { (response:NSDictionary) -> Void in
                println("Call StoreLocatorService sucess")
            },
            errorBlock: { (error:NSError) -> Void in
                println("Call StoreLocatorService error \(error)")
            }
        )
       
        IPOSplashViewController.updateUserData()
    }
    
    class func updateUserData() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_STORELACATION.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        
        /*let shoppingCartUpdateBg = ShoppingCartProductsService()
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartBegin.rawValue, object: nil)
        println("Call service ShoppingCartProductsService start")
        shoppingCartUpdateBg.callService([:], successBlock: { (result:NSDictionary) -> Void in
             println("Call service ShoppingCartProductsService success")
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartEnd.rawValue, object: nil)
            }, errorBlock: { (error:NSError) -> Void in
                //if error.code != -100 {
                 println("Call service ShoppingCartProductsService error")
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartEnd.rawValue, object: nil)
                //}
        })*/
        
        UserCurrentSession.sharedInstance().loadShoppingCarts { () -> Void in
            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
        }
        
        let banService = BannerService()
        let params = Dictionary<String, String>()
        banService.callService(params, successBlock: { (result:NSDictionary) -> Void in
            println("Call service BannerService success")
            }) { (error:NSError) -> Void in
                println("Call service BannerService error \(error)")
        }
        
    }
    
    deinit{
        println("Deinit splash")
    }
    
    
    
}