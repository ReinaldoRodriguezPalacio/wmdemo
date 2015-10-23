//
//  CheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class CheckOutViewController : NavigationViewController,UIWebViewDelegate {

    let timeInterval : NSTimeInterval = 10.0
    
    var webCheckOut : UIWebView!
    
    var username : String!
    var password : String!
    
    var didLoginWithEmail : Bool = false
    var takeSnapshot : Bool = true
    
    var finishLoadCheckOut : (() -> Void)? = nil
    var afterclose : (() -> Void)? = nil
    
    var checkResponsive = "app_Checkout.aspx"
    var paramAppDevice = "device"

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
        print("URL::: \(webView.request?.URL!.absoluteString)")
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
            didLoginWithEmail = true
            let loginService = LoginWithEmailService()
            loginService.loginIdGR = UserCurrentSession.sharedInstance().userSigned!.idUserGR as String
            let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
            loginService.callService(["email":emailUser], successBlock: { (response:NSDictionary) -> Void in
                }, errorBlock: { (error:NSError) -> Void in
            })
        }
        
        if rangeEnd.location != NSNotFound && takeSnapshot {
            takeSnapshot = false
            screenShotMethod()
        }
        
        if finishLoadCheckOut != nil {
            finishLoadCheckOut!()
        }
        
        print("URL::: \(webView.request)")
        
    }
    
    override func back() {
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
    }
    
   
    
}