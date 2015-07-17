//
//  TmpIPAHomeViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 01/11/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import UIKit

class TmpIPAHomeViewController : BaseController {
    
    @IBOutlet var webview: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.walmart.com.mx/")!))
        
    }
    
}