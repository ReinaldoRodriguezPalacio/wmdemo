//
//  IPASignUpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 21/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPASignUpViewController: SignUpViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        //super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        let fieldHeight  : CGFloat = CGFloat(40)
        let leftRightPadding  : CGFloat = CGFloat(0)
        
        self.content.frame = CGRectMake(0, 0 , self.view.bounds.width , self.view.bounds.height)
        self.titleLabel?.frame = CGRectMake(0, 0, self.content.bounds.width, 14)
        self.name?.frame = CGRectMake(leftRightPadding,   self.titleLabel!.frame.maxY + 25 , ( (self.view.bounds.width - (leftRightPadding*2)) / 2) - 5 , fieldHeight)
        self.lastName?.frame = CGRectMake(self.name!.frame.maxX + 10 , self.name!.frame.minY,   self.name!.frame.width  , fieldHeight)
        self.email?.frame = CGRectMake(leftRightPadding,  lastName!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.password?.frame = CGRectMake(leftRightPadding,   email!.frame.maxY + 8, (self.email!.frame.width / 2) - 5 , fieldHeight)
        self.confirmPassword?.frame = CGRectMake(self.password!.frame.maxX + 10 , self.password!.frame.minY,   self.password!.frame.width  , fieldHeight)
//        self.contentTerms!.frame = CGRectMake(0 ,  confirmPassword!.frame.maxY + 15 , self.view.bounds.width ,65)
//        self.acceptTerms?.frame = CGRectMake(15, 0, 17, 17 )
//        self.labelTerms?.frame =  CGRectMake(acceptTerms!.frame.maxX + 12, self.acceptTerms!.frame.minY ,  self.email!.frame.width - (acceptTerms!.frame.width + 20)  , 75 )
        
        self.birthDate?.frame = CGRectMake(leftRightPadding,  confirmPassword!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        
        
        
        
        self.femaleButton!.frame = CGRectMake(144,  birthDate!.frame.maxY + 15,  76 , fieldHeight)
        self.maleButton!.frame = CGRectMake(self.femaleButton!.frame.maxX,  birthDate!.frame.maxY + 15, 76 , fieldHeight)
        
        self.cancelButton!.frame = CGRectMake(leftRightPadding,  maleButton!.frame.maxY + 15,  (self.email!.frame.width / 2) - 5 , fieldHeight)
        self.continueButton!.frame = CGRectMake(self.cancelButton!.frame.maxX + 10 , self.cancelButton!.frame.minY ,  self.cancelButton!.frame.width, fieldHeight)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.continueButton!.frame.maxY + 40)
        
//        self.cancelButton!.frame = CGRectMake(leftRightPadding,  self.contentTerms!.frame.minY + 15 + self.labelTerms!.frame.maxY,  self.confirmPassword!.frame.width, fieldHeight)
//        self.registryButton!.frame = CGRectMake(self.name!.frame.maxX + 10 , self.cancelButton!.frame.minY ,  self.confirmPassword!.frame.width, fieldHeight)
//        self.content.contentSize = CGSize(width: bounds.width, height: self.registryButton!.frame.maxY)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
   
  
    
}
