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
        self.view.backgroundColor = UIColor.white
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
        let intWidth = Int( self.view.frame.width / 2) - 56
        self.femaleButton!.frame = CGRect(x: CGFloat(intWidth),  y: birthDate!.frame.maxY + 8,  width: 76 , height: fieldHeight)
        self.maleButton!.frame = CGRect(x: self.femaleButton!.frame.maxX,  y: birthDate!.frame.maxY + 8, width: 76 , height: fieldHeight)
        self.changePasswordButton?.frame = CGRect(x: (self.view.frame.width / 2) - 134, y: self.femaleButton!.frame.maxY+8 , width: 288,height: 40 )
        self.legalInformation!.frame = CGRect(x: (self.view.frame.width / 2) - 134, y: self.changePasswordButton!.frame.maxY+90 , width: 288,height: 40 )

        
    }
    
}
