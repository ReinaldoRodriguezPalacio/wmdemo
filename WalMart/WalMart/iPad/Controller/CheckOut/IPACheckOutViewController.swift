//
//  IPACheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 01/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPACheckOutViewController : CheckOutViewController {
    
    
    override func writeDeviceInfo(webView:UIWebView){
        
        let majorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
        let minorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as String
        let version = "\(majorVersion) (\(minorVersion))"
        
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_channel').value='2';")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_subchannel').value='3';")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_osVersion').value='\(version)';")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('_osName').value='iOS \(UIDevice.currentDevice().systemVersion)';")
        
        
//        let doc = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")
//        println(doc)

        
    }

    

}