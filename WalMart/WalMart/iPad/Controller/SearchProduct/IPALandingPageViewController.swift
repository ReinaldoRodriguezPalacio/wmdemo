//
//  IPALandingPageViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPALandingPageViewController: IPASearchCatProductViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        contentCollectionOffset = CGPointZero
        self.collection!.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
    }
    
}
