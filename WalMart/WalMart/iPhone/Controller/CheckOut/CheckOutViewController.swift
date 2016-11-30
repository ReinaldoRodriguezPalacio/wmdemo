//
//  CheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

var mgCheckOutComplete = false

class CheckOutViewController : NavigationViewController,UIWebViewDelegate {

    let timeInterval : TimeInterval = 10.0
    
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
    var itemsMG : [Any]!
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
        useLancaster = Bundle.main.object(forInfoDictionaryKey: "UseLancasterUrls") as! Bool
        
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
        webCheckOut = UIWebView(frame:CGRect(x: 0, y: self.header!.frame.maxY , width: self.view.bounds.width , height: self.view.bounds.height - self.header!.frame.height - 66 ))
        
        webCheckOut.scalesPageToFit = true
        
        webCheckOut.delegate = self
        
        let request = URLRequest(url: URL(string: ConfigUrls.IngresarCheckOut)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
        webCheckOut.loadRequest(request)
        self.view.addSubview(webCheckOut)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.HideBadge.rawValue), object: nil)
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad!.backgroundColor = UIColor.white
            viewLoad!.startAnnimating(true)
            webCheckOut.addSubview(viewLoad!)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeAllCookies()
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBadge.rawValue), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
          webCheckOut.frame = CGRect(x: 0, y: self.header!.frame.maxY , width: self.view.bounds.width , height: self.view.bounds.height - self.header!.frame.height)
    }
    
    /**
     remove cookies in webview.
     */
    func removeAllCookies() {
        let storage = HTTPCookieStorage.shared
        var cookies = storage.cookies(for: URL(string: ConfigUrls.WmComMX)!)
        for idx in 0 ..< cookies!.count {
            let cookie = cookies![idx] as HTTPCookie
            storage.deleteCookie(cookie)
        }
    }
    
    //MARK: UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            print("URL shouldStartLoadWithRequest ::: \(request.url!.absoluteString)")
            let string = request.url!.absoluteString as NSString
            var range = string.range(of: ConfigUrls.MInicio)//ok
            if range.location != NSNotFound {
                
            }
        
            range = string.range(of: ConfigUrls.PoliticasPrivacidad)
            if range.location != NSNotFound {
                let previewHelp = PreviewHelpViewController()
                previewHelp.titleText = NSLocalizedString("help.item.privacy.notice", comment: "") as NSString!
                previewHelp.resource = "privacy"
                previewHelp.type = "pdf"
                self.navigationController!.pushViewController(previewHelp,animated:true)
                return false
            }
            
            range = string.range(of: ConfigUrls.WmCheckOut)//ok
            if range.location != NSNotFound {
                //back()
            }
        
            var stringcase: NSString = string.lowercased as NSString
            range = stringcase.range(of: ConfigUrls.RevisarCarrito)// ok
            if range.location != NSNotFound {
                back()
            }
        
            stringcase.lowercased
            range = stringcase.range(of: ConfigUrls.WmInicio)//ok
            if range.location != NSNotFound {
                back()
            }
        
        
            range = string.range(of: ConfigUrls.WmComMX)//ok
        
        
             stringcase = string.lowercased as NSString
        
            let rangeMobile = stringcase.range(of: "/m_")
            let rangeMobilePayment = stringcase.range(of: ConfigUrls.MCreditCartPayment)//ok
            let rangePayment = stringcase.range(of: ConfigUrls.CreditCartPAymentAsp)//ok
        
        
        
            range = stringcase.range(of: ConfigUrls.MMiCuenta)//ok
            let rangeMobileIngresa = stringcase.range(of: ConfigUrls.MIngresar)//ok
        
            if range.location == NSNotFound && rangeMobileIngresa.location == NSNotFound && rangeMobile.location != NSNotFound && rangeMobilePayment.location ==  NSNotFound && rangePayment.location ==  NSNotFound {
                if !useLancaster {
                    //back()
                }
            }
            
            range = string.range(of: ConfigUrls.WmMiCuenta)
            if range.location != NSNotFound {
                
                let request = URLRequest(url: URL(string: ConfigUrls.WmCheckOut)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: timeInterval)
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
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("URL::: FinishLoad --\(webView.request?.url!.absoluteString)")
        let string = webView.request!.url!.absoluteString as NSString
        var range = string.range(of: ConfigUrls.IngresarCheckOut)
        
        
        if range.location != NSNotFound {
            //CheckoutiPad
            self.writeDeviceInfo(webView)
            
            webView.stringByEvaluatingJavaScript(from: "document.getElementById('UserName').value='\(self.username.lowercased())';")
            webView.stringByEvaluatingJavaScript(from: "document.getElementById('Password').value='\(self.password)';")
            webView.stringByEvaluatingJavaScript(from: "document.getElementById(\"btnLogin\").click()")
            
            //webView.stringByEvaluatingJavaScriptFromString("WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(\"btnLogin\", \"\", true, \"loginControl\", \"\", false, true))")
            
            
            
            return
        } else {
            range = string.range(of: ConfigUrls.WmMiCuenta)
            if range.location != NSNotFound {
                
                let request = URLRequest(url: URL(string: ConfigUrls.WmCheckOut)!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: timeInterval)
                webCheckOut.loadRequest(request)
                return
            }else{
                print("NSNotFound:::: https://www.walmart.com.mx/CheckOut")
            }
        }
        
        let rangeEnd = string.range(of: ConfigUrls.ConfirmacionPedido)//ok
        if rangeEnd.location != NSNotFound && !didLoginWithEmail {
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BUY_MG.rawValue , label: "")
            didLoginWithEmail = true
            
            //sendTuneAnalytics
//            let items :[[String:Any]] = self.itemsMG as! [[String:Any]]
//            let newTotal:NSNumber = NSNumber(float:(self.total! as NSString).floatValue)
            //BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: self.username.lowercaseString, userName: self.username.lowercaseString, gender: "", idUser: "", itesShop: items,total:newTotal,refId:"")
            
            
            let loginService = LoginWithEmailService()
            loginService.loginIdGR = UserCurrentSession.sharedInstance.userSigned!.idUserGR as String
            let emailUser = UserCurrentSession.sharedInstance.userSigned!.email
            loginService.callService(["email":emailUser], successBlock: { (response:[String:Any]) -> Void in
                print(response)
                }, errorBlock: { (error:NSError) -> Void in
            })
            
           
            
        }
        
        if rangeEnd.location != NSNotFound && takeSnapshot {
            takeSnapshot = false
            screenShotMethod()
        }
        
        if finishLoadCheckOut != nil {
               Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(CheckOutViewController.removeViewLoading), userInfo: nil, repeats: false)
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
        
        if UserCurrentSession.sharedInstance.isReviewActive && (velue == "" ||  velue == "true") {
            let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
            alert!.isCustomAlert = true
            alert!.spinImage.isHidden =  true
            alert!.setMessage(NSLocalizedString("review.title.like.app", comment: ""))
            alert!.addActionButtonsWithCustomText("No", leftAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                //regresar a carrito
               self.backFinish()
                print("Save in data base")
                
                
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_DONT_LIKE_APP.rawValue , label: "No me gusta la app")
                }, rightText: "Sí", rightAction: {
                    alert?.close()
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_LIKE_APP.rawValue , label: "Me gusta la app")
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
        alert!.spinImage.isHidden =  true
        alert!.setMessage(NSLocalizedString("review.description.ok.rate", comment: ""))
       
        alert!.addActionButtonsWithCustomTextRating(NSLocalizedString("review.no.thanks", comment: ""), leftAction: {
            // --- 
            CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
            alert?.close()
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_NO_THANKS.rawValue , label: "No gracias")
            //regresar a carrito
            self.backFinish()
            
            }, rightText: NSLocalizedString("review.maybe.later", comment: ""), rightAction: {
                
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "true")
                alert?.close()
                
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_MAYBE_LATER.rawValue , label: "Más tarde")
                //regresar a carrito
                self.backFinish()
             
              
            }, centerText: NSLocalizedString("review.yes.rate", comment: ""),centerAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_OPEN_APP_STORE.rawValue , label: "Si Claro")
                //regresar a carrito
                self.backFinish()
                let url  = URL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
                if UIApplication.shared.canOpenURL(url!) == true  {
                    UIApplication.shared.openURL(url!)
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
//            let items :[[String:Any]] = self.itemsMG as! [[String:Any]]
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
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BACK_TO_SHOPPING_CART.rawValue , label: "")
        
        ShoppingCartService.shouldupdate = true
        
        
        URLCache.shared.removeAllCachedResponses()
        
        self.webCheckOut.loadHTMLString("",baseURL:nil)
        if (self.webCheckOut.isLoading){
            self.webCheckOut.stopLoading()
        }
        self.webCheckOut.delegate = nil
        self.webCheckOut = nil
        self.finishLoadCheckOut = nil
        //self.navigationController?.popToRootViewControllerAnimated(true)
        self.navigationController?.popViewController(animated: true)
        if afterclose != nil {
            afterclose!()
        }
    
    }
    
   
    /**
     Create Image from webview and save image in device fotos, when finish order.
     */
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(CGSize(width: self.webCheckOut.frame.width, height: self.webCheckOut.frame.height))
        
        self.webCheckOut.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let library =  ALAssetsLibrary()
        library.save(image, toAlbum: "Walmart", completion: { (url:URL!, error:NSError!) -> Void in
            print("saved image")
            }) { (error:NSError!) -> Void in
                print("Error saving image")
              

        }
        //Presentar
        isRateActive =  true
        mgCheckOutComplete = true
       
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    
    /**
     iyect info to webview to login user
     
     - parameter webView:  Web inyect info
     */
    func writeDeviceInfo(_ webView:UIWebView){
        
        let majorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let minorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let version = "\(majorVersion) (\(minorVersion))"
        
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_channel').value='2';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_subchannel').value='4';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_osVersion').value='\(version)';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_osName').value='iOS \(UIDevice.current.systemVersion)';")
        let employe = self.isEmployeeDiscount ? "true" : "false"
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_isEmployeeDiscount').value='\(employe)';")
    }
    
    

    
   
    
}
