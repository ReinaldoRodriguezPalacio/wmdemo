//
//  PrivacyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 22/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class PrivacyViewController :  PreviewHelpViewController,UIScrollViewDelegate {
    
    override func viewDidLoad() {
        self.titleText = NSLocalizedString("profile.terms.privacy",comment:"")
        super.viewDidLoad()
    }
    
    override func loadPreview () {
        
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let myFilePath = documentDirectory.stringByAppendingPathComponent("AvisoPrivacidad.pdf")
            let manager = NSFileManager.defaultManager()
            
            if (manager.fileExistsAtPath(myFilePath)) {
                var request = NSURLRequest(URL: NSURL(fileURLWithPath: myFilePath)!)
                self.webShowDetail.loadRequest(request)
            }
    }
    
    
}
