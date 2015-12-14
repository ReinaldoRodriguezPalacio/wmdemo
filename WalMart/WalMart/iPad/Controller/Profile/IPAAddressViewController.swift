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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var left : CGFloat = 87
        
        if self.idAddress != nil{
            left = left + 30
        }
        self.saveButton!.frame = CGRectMake(self.view.bounds.maxX - left , 0 , 71, self.header!.frame.height)
        if addFRomMg{
         self.saveButton!.frame = CGRectMake(self.titleLabel!.frame.maxX - 81 , 0 , 71, self.header!.frame.height)
        }
    }
    
    
    
    override func setContentSize(){
        super.setContentSize()
        if self.validateZip  && self.idAddress == nil {
            self.saveButton!.titleEdgeInsets = UIEdgeInsetsMake(self.saveButton!.titleEdgeInsets.top , self.saveButton!.titleEdgeInsets.left - 35.5 , self.saveButton!.titleEdgeInsets.bottom, self.saveButton!.titleEdgeInsets.right)
            
        }
        if addFRomMg{
            self.titleLabel!.frame = CGRectMake(0, 0, 465, 35)
            self.content.superview?.frame = CGRectMake(0 , 0, 718, 718)
        }
        
    }

}
