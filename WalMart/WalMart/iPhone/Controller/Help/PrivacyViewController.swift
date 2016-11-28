//
//  PrivacyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 22/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class PrivacyViewController :  PreviewHelpViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        self.titleLabel!.text = NSLocalizedString("help.item.privacy.notice", comment: "")
        self.titleText = self.titleLabel!.text as NSString!
    }
    
    override func loadPreview () {
        
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let myFilePath = documentDirectory.appendingPathComponent("AvisoPrivacidad.pdf")
            let manager = FileManager.default
            
            if (manager.fileExists(atPath: myFilePath)) {
                let request = URLRequest(url: URL(fileURLWithPath: myFilePath))
                self.webShowDetail.loadRequest(request)
            }
    }
    
    
}
