//
//  CheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

class CheckOutViewController : NavigationViewController,UIWebViewDelegate {

    let timeInterval : NSTimeInterval = 10.0
    
    var webCheckOut : UIWebView!
    var viewLoad : WMLoadingView?
    
    var username : String!
    var password : String!
    
    var didLoginWithEmail : Bool = false
    var takeSnapshot : Bool = true
    
    var finishLoadCheckOut : (() -> Void)? = nil
    var afterclose : (() -> Void)? = nil
    var isEmployeeDiscount :Bool =  false
    
    var checkResponsive = "app_Checkout.aspx"
    var paramAppDevice = "device"
    var itemsMG : NSArray!
    var total : String?
    var stopTune =  true
    var useLancaster = false
    let KEY_RATING = "ratingEnabled"
    var isRateActive = false
    
    struct ConfigUrls {
        
        static var WmMiCuenta : String = "www.walmart.com.mx/m_Mi-Cuenta.aspx"
        static var IngresarCheckOut : String = "https://www.walmart.com.mx/m_Ingresar.aspx?goto=app_Checkout.aspx" //ok
        static var PoliticasPrivacidad : String = "www.walmart.com.mx/Politicas-de-privacidad.aspx"
        static var RevisarCarrito : String = "/app_Revisar-Carrito.aspx"
        static var MInicio : String = "/m_inicio.aspx"
        static var WmInicio : String = "https://www.walmart.com.mx/inicio"
        static var ConfirmacionPedido : String = "/app_Confirmacion-Pedido.aspx"
        static var MMiCuenta : String = "/m_Mi-Cuenta.aspx"
        static var MIngresar : String = "/m_Ingresar.aspx"
        static var WmCheckOut : String = "https://www.walmart.com.mx/app_Checkout.aspx"
        static var WmComMX : String = "https://www.walmart.com.mx/"
    
        static var MCreditCartPayment : String = "/m_CreditCardPayment.aspx"
        static var CreditCartPAymentAsp : String = "/CreditCardPayment.aspx"
        
        
        
    }
    
    
    //let DOMAIN_CHECKOUT = "www.walmart.com.mx/m_Mi-Cuenta.aspx"//OK

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        useLancaster = NSBundle.mainBundle().objectForInfoDictionaryKey("UseLancasterUrls") as! Bool
        
        if useLancaster {
            
            ConfigUrls.WmMiCuenta = "www.walmart.com.mx/m_Mi-Cuenta.aspx"
            ConfigUrls.IngresarCheckOut = "https://www.walmart.com.mx/m_Ingresar.aspx?goto=/CheckOut"//okhttps://www.walmart.com.mx/m_CheckOut
            ConfigUrls.PoliticasPrivacidad = "seguridad-y-privacidad/politicas-de-privacidad"
            ConfigUrls.RevisarCarrito = "/revisar-carrito"
            ConfigUrls.MInicio = "/m_inicio.aspx"
            ConfigUrls.WmInicio = "https://www.walmart.com.mx/inicio"
            ConfigUrls.ConfirmacionPedido = "/Confirmacion-Pedido?"
            ConfigUrls.MMiCuenta = "/m_Mi-Cuenta.aspx"
            ConfigUrls.MIngresar = "/m_Ingresar.aspx"
            ConfigUrls.WmCheckOut = "https://www.walmart.com.mx/CheckOut"
            ConfigUrls.WmComMX = "https://www.walmart.com.mx/"
            ConfigUrls.MCreditCartPayment = "/mg/CreditCardPayment.aspx?"
            ConfigUrls.CreditCartPAymentAsp = "/CreditCardPayment.aspx?"
        
        }
        
        
        self.titleLabel!.text = NSLocalizedString("checkout.title",comment:"")
        webCheckOut = UIWebView(frame:CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height - 66 ))
        
        webCheckOut.scalesPageToFit = true
        
        webCheckOut.delegate = self
        
        let request = NSURLRequest(URL: NSURL(string: ConfigUrls.IngresarCheckOut)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
        webCheckOut.loadRequest(request)
        self.view.addSubview(webCheckOut)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBadge.rawValue, object: nil)
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad!.backgroundColor = UIColor.whiteColor()
            viewLoad!.startAnnimating(true)
            webCheckOut.addSubview(viewLoad!)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeAllCookies()
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBadge.rawValue, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
          webCheckOut.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height)
    }
    
    /**
     remove cookies in webview.
     */
    func removeAllCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var cookies = storage.cookiesForURL(NSURL(string: ConfigUrls.WmComMX)!)
        for idx in 0 ..< cookies!.count {
            let cookie = cookies![idx] as NSHTTPCookie
            storage.deleteCookie(cookie)
        }
    }
    
    //MARK: UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            print("URL shouldStartLoadWithRequest ::: \(request.URL!.absoluteString)")
            let string = request.URL!.absoluteString as NSString
            var range = string.rangeOfString(ConfigUrls.MInicio)//ok
            if range.location != NSNotFound {
                
            }
        
            range = string.rangeOfString(ConfigUrls.PoliticasPrivacidad)
            if range.location != NSNotFound {
                let previewHelp = PreviewHelpViewController()
                previewHelp.titleText = NSLocalizedString("help.item.privacy.notice", comment: "")
                previewHelp.resource = "privacy"
                previewHelp.type = "pdf"
                self.navigationController!.pushViewController(previewHelp,animated:true)
                return false
            }
            
            range = string.rangeOfString(ConfigUrls.WmCheckOut)//ok
            if range.location != NSNotFound {
                //back()
            }
        
            var stringcase: NSString = string.lowercaseString
            range = stringcase.rangeOfString(ConfigUrls.RevisarCarrito)// ok
            if range.location != NSNotFound {
                back()
            }
        
            stringcase.lowercaseString
            range = stringcase.rangeOfString(ConfigUrls.WmInicio)//ok
            if range.location != NSNotFound {
                back()
            }
        
        
            range = string.rangeOfString(ConfigUrls.WmComMX)//ok
        
        
             stringcase = string.lowercaseString
        
            let rangeMobile = stringcase.rangeOfString("/m_")
            let rangeMobilePayment = stringcase.rangeOfString(ConfigUrls.MCreditCartPayment)//ok
            let rangePayment = stringcase.rangeOfString(ConfigUrls.CreditCartPAymentAsp)//ok
        
        
        
            range = stringcase.rangeOfString(ConfigUrls.MMiCuenta)//ok
            let rangeMobileIngresa = stringcase.rangeOfString(ConfigUrls.MIngresar)//ok
        
            if range.location == NSNotFound && rangeMobileIngresa.location == NSNotFound && rangeMobile.location != NSNotFound && rangeMobilePayment.location ==  NSNotFound && rangePayment.location ==  NSNotFound {
                if !useLancaster {
                    //back()
                }
            }
            
            range = string.rangeOfString(ConfigUrls.WmMiCuenta)
            if range.location != NSNotFound {
                
                let request = NSURLRequest(URL: NSURL(string: ConfigUrls.WmCheckOut)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: timeInterval)
                webCheckOut.loadRequest(request)
                return false
            }else{
                print("NSNotFound ::: \(ConfigUrls.WmMiCuenta)")
            }
        
            let len = ConfigUrls.WmComMX //ok
            len.length()
            if range.location != NSNotFound &&  len.length() == string.length {
                print("cerrando ::: https://www.walmart.com.mx/")
                back()
            }
        
        return true
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("URL::: FinishLoad --\(webView.request?.URL!.absoluteString)")
        let string = webView.request!.URL!.absoluteString as NSString
        var range = string.rangeOfString(ConfigUrls.IngresarCheckOut)
        
        
        if range.location != NSNotFound {
            //CheckoutiPad
            self.writeDeviceInfo(webView)
            
            webView.stringByEvaluatingJavaScriptFromString("document.getElementById('UserName').value='\(self.username.lowercaseString)';")
            webView.stringByEvaluatingJavaScriptFromString("document.getElementById('Password').value='\(self.password)';")
            webView.stringByEvaluatingJavaScriptFromString("document.getElementById(\"btnLogin\").click()")
            
            //webView.stringByEvaluatingJavaScriptFromString("WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(\"btnLogin\", \"\", true, \"loginControl\", \"\", false, true))")
            
            
            
            return
        } else {
            range = string.rangeOfString(ConfigUrls.WmMiCuenta)
            if range.location != NSNotFound {
                
                let request = NSURLRequest(URL: NSURL(string: ConfigUrls.WmCheckOut)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeInterval)
                webCheckOut.loadRequest(request)
                return
            }else{
                print("NSNotFound:::: https://www.walmart.com.mx/CheckOut")
            }
        }
        
        let rangeEnd = string.rangeOfString(ConfigUrls.ConfirmacionPedido)//ok
        if rangeEnd.location != NSNotFound && !didLoginWithEmail {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BUY_MG.rawValue , label: "")
            didLoginWithEmail = true
            
            //sendTuneAnalytics
//            let items :[[String:AnyObject]] = self.itemsMG as! [[String:AnyObject]]
//            let newTotal:NSNumber = NSNumber(float:(self.total! as NSString).floatValue)
            //BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: self.username.lowercaseString, userName: self.username.lowercaseString, gender: "", idUser: "", itesShop: items,total:newTotal,refId:"")
            
            
            let loginService = LoginWithIdService()
            let idUser = UserCurrentSession.sharedInstance().userSigned!.idUser
            let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
            loginService.callService(["idUser":idUser], successBlock: { (response:NSDictionary) -> Void in
                print(response)
                }, errorBlock: { (error:NSError) -> Void in
            })
            
           
            
        }
        
        if rangeEnd.location != NSNotFound && takeSnapshot {
            takeSnapshot = false
            screenShotMethod()
        }
        
        if finishLoadCheckOut != nil {
               NSTimer.scheduledTimerWithTimeInterval(0.9, target: self, selector: #selector(CheckOutViewController.removeViewLoading), userInfo: nil, repeats: false)
            finishLoadCheckOut!()
        }
        
        
        print("URL:::-- \(webView.request)")
        
    }
    
    //MARK: Actions
    
    /**
     Show alert whidth options like or i dont like app
     */
    func rateFinishShopp(){
        //Validar presentar mensaje
        let showRating = CustomBarViewController.retrieveRateParam(self.KEY_RATING)
        let velue = showRating == nil ? "" :showRating?.value
        
        if UserCurrentSession.sharedInstance().isReviewActive && (velue == "" ||  velue == "true") {
            let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
            alert!.isCustomAlert = true
            alert!.spinImage.hidden =  true
            alert!.setMessage(NSLocalizedString("review.title.like.app", comment: ""))
            alert!.addActionButtonsWithCustomText("No", leftAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                //regresar a carrito
               self.backFinish()
                print("Save in data base")
                
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_DONT_LIKE_APP.rawValue , label: "No me gusta la app")
                }, rightText: "Sí", rightAction: {
                    alert?.close()
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_LIKE_APP.rawValue , label: "Me gusta la app")
                    self.rankingApp()
                }, isNewFrame: false)
            
            alert!.leftButton.layer.cornerRadius = 20
            alert!.rightButton.layer.cornerRadius = 20
        }else{
            //regresar a carrito
           self.backFinish()
        }
        
    }
    
    /**
     Show screen rate with options :
     -review app
     -later or no thanks
     */
    func rankingApp(){
        
        let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
        alert!.spinImage.hidden =  true
        alert!.setMessage(NSLocalizedString("review.description.ok.rate", comment: ""))
       
        alert!.addActionButtonsWithCustomTextRating(NSLocalizedString("review.no.thanks", comment: ""), leftAction: {
            // --- 
            CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
            alert?.close()
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_NO_THANKS.rawValue , label: "No gracias")
            //regresar a carrito
            self.backFinish()
            
            }, rightText: NSLocalizedString("review.maybe.later", comment: ""), rightAction: {
                
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "true")
                alert?.close()
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_MAYBE_LATER.rawValue , label: "Más tarde")
                //regresar a carrito
                self.backFinish()
             
              
            }, centerText: NSLocalizedString("review.yes.rate", comment: ""),centerAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_OPEN_APP_STORE.rawValue , label: "Si Claro")
                //regresar a carrito
                self.backFinish()
                let url  = NSURL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
                if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                    UIApplication.sharedApplication().openURL(url!)
                }
               
                
        })
        
        alert!.leftButton.backgroundColor = WMColor.regular_blue
        alert!.leftButton.layer.cornerRadius = 20
        
        alert!.rightButton.backgroundColor = WMColor.dark_blue
        alert!.rightButton.layer.cornerRadius = 20
        
        
    }

    /**
     Remove loading view from chekout
     */
    func removeViewLoading(){
        print("removeViewLoading")
        self.viewLoad?.stopAnnimating()
        //sendTuneAnalytics
        if stopTune {
            print("before finishLoadCheckOut stopTune:::")
//            let items :[[String:AnyObject]] = self.itemsMG as! [[String:AnyObject]]
//            let newTotal:NSNumber = NSNumber(float:(self.total! as NSString).floatValue)
            //BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: self.username.lowercaseString, userName: self.username.lowercaseString, gender: "", idUser: "", itesShop: items,total:newTotal,refId:"")
            stopTune =  false
        }
        
    }
    
    /**
     validate if present rate app or finish chekout.
     */
    override func back() {
        if isRateActive {
            self.rateFinishShopp()
        }else{
            self.backFinish()
        }
    }
    
    /**
     close Checkout when finish shopp or cancel
     */
    func backFinish(){
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BACK_TO_SHOPPING_CART.rawValue , label: "")
        
        ShoppingCartService.shouldupdate = true
        
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        self.webCheckOut.loadHTMLString("",baseURL:nil)
        if (self.webCheckOut.loading){
            self.webCheckOut.stopLoading()
        }
        self.webCheckOut.delegate = nil
        self.webCheckOut = nil
        self.finishLoadCheckOut = nil
        //self.navigationController?.popToRootViewControllerAnimated(true)
        self.navigationController?.popViewControllerAnimated(true)
        if afterclose != nil {
            afterclose!()
        }
    
    }
    
   
    /**
     Create Image from webview and save image in device fotos, when finish order.
     */
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(CGSizeMake(self.webCheckOut.frame.width, self.webCheckOut.frame.height))
        
        self.webCheckOut.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let library =  ALAssetsLibrary()
        library.saveImage(image, toAlbum: "Walmart", completion: { (url:NSURL!, error:NSError!) -> Void in
            print("saved image")
            }) { (error:NSError!) -> Void in
                print("Error saving image")
              

        }
        //Presentar
        isRateActive =  true
       
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    
    /**
     iyect info to webview to login user
     
     - parameter webView:  Web inyect info
     */
    func writeDeviceInfo(webView:UIWebView){
        
        let majorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let minorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        let version = "\(majorVersion) (\(minorVersion))"
        
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_channel').value='2';")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_subchannel').value='4';")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_osVersion').value='\(version)';")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_osName').value='iOS \(UIDevice.currentDevice().systemVersion)';")
        let employe = self.isEmployeeDiscount ? "true" : "false"
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_isEmployeeDiscount').value='\(employe)';")
    }
    
    

    
   
    
}