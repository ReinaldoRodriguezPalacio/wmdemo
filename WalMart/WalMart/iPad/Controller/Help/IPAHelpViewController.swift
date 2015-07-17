
//
//  IPAHelpViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 11/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class IPAHelpViewController: HelpViewController {
    
    override func viewDidLoad() {
        self.hiddenBack = true
        if  self.navigationController != nil {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
        super.viewDidLoad()
    }
    
    
}