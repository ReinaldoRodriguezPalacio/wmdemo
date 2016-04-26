//
//  IPOWebViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/12/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class  IPOWebViewController : UIViewController {
    
    let timeInterval : NSTimeInterval = 10.0
    var webViewMain : UIWebView!
    var btnClose : UIButton!
    
    var category : String!
    var categoryNo : String!
    var action : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = UIColor.whiteColor()
        btnClose = UIButton(frame:CGRectMake(0,20,40,40))
        btnClose.setImage(UIImage(named:"detail_close"), forState: UIControlState.Normal)
        btnClose.addTarget(self , action: #selector(IPOWebViewController.close), forControlEvents:UIControlEvents.TouchUpInside)
        self.view.addSubview(btnClose)
        
        
        if webViewMain == nil {
            webViewMain = UIWebView(frame:CGRectZero)
            self.view.addSubview(webViewMain)
        }
        
    }
    

    
    func openURLFactura() {
        if webViewMain == nil {
            webViewMain = UIWebView(frame:CGRectZero)
            self.view.addSubview(webViewMain)
            self.view.sendSubviewToBack(webViewMain)
        }
        
        let request = NSURLRequest(URL: NSURL(string: "https://facturacion.walmartmexico.com.mx/m/")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
        webViewMain.loadRequest(request)
        
        
        category = WMGAIUtils.CATEGORY_GENERATE_BILLING_AUTH.rawValue
        categoryNo = WMGAIUtils.CATEGORY_GENERATE_BILLING_NO_AUTH.rawValue
        
    }
    
    func openURL(togoURL:String) {
        if webViewMain == nil {
            webViewMain = UIWebView(frame:CGRectZero)
            self.view.addSubview(webViewMain)
            self.view.sendSubviewToBack(webViewMain)
        }
        let request = NSURLRequest(URL: NSURL(string: togoURL)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
        webViewMain.loadRequest(request)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webViewMain.frame = CGRectMake(0, btnClose.frame.maxY, self.view.frame.width, self.view.bounds.height - btnClose.frame.maxY)
    }
    
    
    func close() {
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_BILLING_AUTH.rawValue, action: WMGAIUtils.ACTION_CLOSE_GERATE_BILLIG.rawValue, label: "")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
}