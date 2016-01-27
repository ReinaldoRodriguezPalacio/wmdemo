//
//  CheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import Tune

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

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.titleLabel!.text = NSLocalizedString("checkout.title",comment:"")
        webCheckOut = UIWebView(frame:CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height - 66 ))
        
        webCheckOut.scalesPageToFit = true
        
        webCheckOut.delegate = self
        
        let request = NSURLRequest(URL: NSURL(string: "https://www.walmart.com.mx/m_Ingresar.aspx?goto=\(checkResponsive)")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
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
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBadge.rawValue, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
          webCheckOut.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            print("URL shouldStartLoadWithRequest ::: \(request.URL!.absoluteString)")
            let string = request.URL!.absoluteString as NSString
            var range = string.rangeOfString("/m_inicio.aspx")
            if range.location != NSNotFound {
                
            }
            
            range = string.rangeOfString("www.walmart.com.mx/Politicas-de-privacidad.aspx")
            if range.location != NSNotFound {
                let previewHelp = PreviewHelpViewController()
                previewHelp.titleText = NSLocalizedString("help.item.privacy.notice", comment: "")
                previewHelp.resource = "privacy"
                previewHelp.type = "pdf"
                self.navigationController!.pushViewController(previewHelp,animated:true)
                return false
            }
            
            range = string.rangeOfString("www.walmart.com.mx/CheckOut.aspx")
            if range.location != NSNotFound {
                back()
            }
            
            range = string.rangeOfString("/app_Revisar-Carrito.aspx")
            if range.location != NSNotFound {
                back()
            }
            
            let rangeMobile = string.rangeOfString("/m_")
            let rangeMobilePayment = string.rangeOfString("/m_CreditCardPayment.aspx")
            let rangePayment = string.rangeOfString("/CreditCardPayment.aspx")
            range = string.rangeOfString("/m_Mi-Cuenta.aspx")
            let rangeMobileIngresa = string.rangeOfString("/m_Ingresar.aspx")
            if range.location == NSNotFound && rangeMobileIngresa.location == NSNotFound && rangeMobile.location != NSNotFound && rangeMobilePayment.location ==  NSNotFound && rangePayment.location ==  NSNotFound {
                back()
            }
            
            range = string.rangeOfString("www.walmart.com.mx/m_Mi-Cuenta.aspx")
            if range.location != NSNotFound {
                let request = NSURLRequest(URL: NSURL(string: "https://www.walmart.com.mx/\(checkResponsive)")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: timeInterval)
                webCheckOut.loadRequest(request)
                return false
            }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("URL::: FinishLoad --\(webView.request?.URL!.absoluteString)")
        let string = webView.request!.URL!.absoluteString as NSString
        var range = string.rangeOfString("www.walmart.com.mx/m_Ingresar.aspx?goto=\(checkResponsive)")
        if range.location != NSNotFound {
            //CheckoutiPad
            self.writeDeviceInfo(webView)
            
            webView.stringByEvaluatingJavaScriptFromString("document.getElementById('UserName').value='\(self.username.lowercaseString)';")
            webView.stringByEvaluatingJavaScriptFromString("document.getElementById('Password').value='\(self.password)';")
            webView.stringByEvaluatingJavaScriptFromString("WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(\"btnLogin\", \"\", true, \"loginControl\", \"\", false, true))")
            
            
            
            return
        } else {
            range = string.rangeOfString("www.walmart.com.mx/m_Mi-Cuenta.aspx")
            if range.location != NSNotFound {
                let request = NSURLRequest(URL: NSURL(string: "https://www.walmart.com.mx/\(checkResponsive)")!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeInterval)
                webCheckOut.loadRequest(request)
                return
            }
        }
        
        let rangeEnd = string.rangeOfString("/app_Confirmacion-Pedido.aspx")
        if rangeEnd.location != NSNotFound && !didLoginWithEmail {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BUY_MG.rawValue , label: "")
            didLoginWithEmail = true
            
            //sendTuneAnalytics
            //let items :[[String:AnyObject]] = self.itemsMG as! [[String:AnyObject]]
            //let newTotal:NSNumber = NSNumber(float:(self.total! as NSString).floatValue)
            //BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: self.username.lowercaseString, userName: self.username.lowercaseString, gender: "", idUser: "", itesShop: items,total:newTotal,refId:"")
            
            
            let loginService = LoginWithEmailService()
            loginService.loginIdGR = UserCurrentSession.sharedInstance().userSigned!.idUserGR as String
            let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
            loginService.callService(["email":emailUser], successBlock: { (response:NSDictionary) -> Void in
                print(response)
                }, errorBlock: { (error:NSError) -> Void in
            })
        }
        
        if rangeEnd.location != NSNotFound && takeSnapshot {
            takeSnapshot = false
            screenShotMethod()
        }
        
        if finishLoadCheckOut != nil {
               NSTimer.scheduledTimerWithTimeInterval(0.9, target: self, selector: "removeViewLoading", userInfo: nil, repeats: false)
            finishLoadCheckOut!()
        }
        
        
        print("URL:::-- \(webView.request)")
        
    }
   
    func removeViewLoading(){
        print("removeViewLoading")
        self.viewLoad?.stopAnnimating()
        //sendTuneAnalytics
        if stopTune {
            print("before finishLoadCheckOut stopTune:::")
            //let items :[[String:AnyObject]] = self.itemsMG as! [[String:AnyObject]]
            //let newTotal:NSNumber = NSNumber(float:(self.total! as NSString).floatValue)
            //BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: self.username.lowercaseString, userName: self.username.lowercaseString, gender: "", idUser: "", itesShop: items,total:newTotal,refId:"")
            stopTune =  false
        }
        
    }
    
    override func back() {
        
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
        self.navigationController?.popToRootViewControllerAnimated(true)
        if afterclose != nil {
            afterclose!()
        }
    }
    
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(CGSizeMake(self.webCheckOut.frame.width, self.webCheckOut.frame.height - 60))
        
        self.webCheckOut.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let library =  ALAssetsLibrary()
        library.saveImage(image, toAlbum: "Walmart", completion: { (url:NSURL!, error:NSError!) -> Void in
            print("saved image")
            }) { (error:NSError!) -> Void in
                print("Error saving image")
              

        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
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