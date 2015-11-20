//
//  IPAEditProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 14/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPAEditProfileViewController: EditProfileViewController {

    override func viewDidLoad() {
        self.hiddenBack = true
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.saveButton!.tag = 100
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let fieldHeight: CGFloat = 40.0
       // self.content.frame = CGRectMake(0, self.header!.frame.maxY + 15 , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
        self.femaleButton!.frame = CGRectMake((self.view.frame.width / 2) - 76,  birthDate!.frame.maxY + 8,  76 , fieldHeight)
        self.maleButton!.frame = CGRectMake(self.femaleButton!.frame.maxX,  birthDate!.frame.maxY + 8, 76 , fieldHeight)
        self.changePasswordButton?.frame = CGRectMake((self.view.frame.width / 2) - 134, self.femaleButton!.frame.maxY+8 , 288,40 )
        self.legalInformation!.frame = CGRectMake((self.view.frame.width / 2) - 134, self.changePasswordButton!.frame.maxY+90 , 288,40 )
        
        


        
  
    }
    
}
