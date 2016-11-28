//
//  IPOWebViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/12/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class  IPOWebViewController : UIViewController {
    
    let timeInterval : TimeInterval = 10.0
    var webViewMain : UIWebView!
    var btnClose : UIButton!
    
    //var category : String!
    //var categoryNo : String!
    var action : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = UIColor.white
        btnClose = UIButton(frame:CGRect(x: 0,y: 20,width: 40,height: 40))
        btnClose.setImage(UIImage(named:"detail_close"), for: UIControlState())
        btnClose.addTarget(self , action: #selector(IPOWebViewController.close), for:UIControlEvents.touchUpInside)
        self.view.addSubview(btnClose)
        
        
        if webViewMain == nil {
            webViewMain = UIWebView(frame:CGRect.zero)
            self.view.addSubview(webViewMain)
        }
        
    }
    

    
    func openURLFactura() {
        if webViewMain == nil {
            webViewMain = UIWebView(frame:CGRect.zero)
            self.view.addSubview(webViewMain)
            self.view.sendSubview(toBack: webViewMain)
        }
        
        let request = URLRequest(url: URL(string: "https://facturacion.walmartmexico.com.mx/m/")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
        webViewMain.loadRequest(request)
        
        
        //category = WMGAIUtils.CATEGORY_GENERATE_BILLING_AUTH.rawValue
        //categoryNo = WMGAIUtils.CATEGORY_GENERATE_BILLING_NO_AUTH.rawValue
        
    }
    
    func openURL(_ togoURL:String) {
        if webViewMain == nil {
            webViewMain = UIWebView(frame:CGRect.zero)
            self.view.addSubview(webViewMain)
            self.view.sendSubview(toBack: webViewMain)
        }
        let request = URLRequest(url: URL(string: togoURL)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeInterval)
        webViewMain.loadRequest(request)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webViewMain.frame = CGRect(x: 0, y: btnClose.frame.maxY, width: self.view.frame.width, height: self.view.bounds.height - btnClose.frame.maxY)
    }
    
    
    func close() {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_BILLING_AUTH.rawValue, action: WMGAIUtils.ACTION_CLOSE_GERATE_BILLIG.rawValue, label: "")
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
}
