//
//  GRCheckOutConfirmViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/18/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutConfirmViewController : NavigationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.titleLabel?.text = "Si se pudo"
        
    }
    
    
    override func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}