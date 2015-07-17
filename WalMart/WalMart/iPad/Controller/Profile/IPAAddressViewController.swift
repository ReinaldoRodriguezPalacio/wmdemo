//
//  IPAAddressViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 15/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPAAddressViewController: AddressViewController {
   
    override func viewDidLoad() {
        if  self.navigationController != nil {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
        self.isIpad = true
        
        super.viewDidLoad()
        if self.saveButton != nil {
            self.saveButton!.tag = 100
        }
        
        if self.deleteButton != nil {
            self.deleteButton!.tag = 100
        }
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
    }

    
}
