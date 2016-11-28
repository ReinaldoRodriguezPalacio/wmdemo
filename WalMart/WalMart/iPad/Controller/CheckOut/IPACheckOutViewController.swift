//
//  IPACheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 01/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPACheckOutViewController : CheckOutViewController {
    
    
    /**
     iyect info to webview to login user
     
     - parameter webView:  Web inyect info
     */
    override func writeDeviceInfo(_ webView:UIWebView){
        
        let majorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let minorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let version = "\(majorVersion) (\(minorVersion))"
        
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_channel').value='2';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_subchannel').value='3';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_osVersion').value='\(version)';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_osName').value='iOS \(UIDevice.current.systemVersion)';")
        let employe = self.isEmployeeDiscount ? "true" : "false"
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('_isEmployeeDiscount').value='\(employe)';")
        
        
//        let doc = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")
//        println(doc)

        
    }

    

}
