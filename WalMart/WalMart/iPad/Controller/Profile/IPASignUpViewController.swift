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

    //MARK: UIViewController
    override func viewWillLayoutSubviews() {
        //super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        let fieldHeight  : CGFloat = CGFloat(40)
        let leftRightPadding  : CGFloat = CGFloat(0)
        
        self.content.frame = CGRect(x: 0, y: 0 , width: self.view.bounds.width , height: self.view.bounds.height)
        self.titleLabel?.frame = CGRect(x: 0, y: 0, width: self.content.bounds.width, height: 14)
        self.name?.frame = CGRect(x: leftRightPadding,   y: self.titleLabel!.frame.maxY + 25 , width: ( (self.view.bounds.width - (leftRightPadding*2)) / 2) - 5 , height: fieldHeight)
        self.lastName?.frame = CGRect(x: self.name!.frame.maxX + 10 , y: self.name!.frame.minY,   width: self.name!.frame.width  , height: fieldHeight)
        self.email?.frame = CGRect(x: leftRightPadding,  y: lastName!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.password?.frame = CGRect(x: leftRightPadding,   y: email!.frame.maxY + 8, width: (self.email!.frame.width / 2) - 5 , height: fieldHeight)
        self.confirmPassword?.frame = CGRect(x: self.password!.frame.maxX + 10 , y: self.password!.frame.minY,   width: self.password!.frame.width  , height: fieldHeight)
//        self.contentTerms!.frame = CGRectMake(0 ,  confirmPassword!.frame.maxY + 15 , self.view.bounds.width ,65)
//        self.acceptTerms?.frame = CGRectMake(15, 0, 17, 17 )
//        self.labelTerms?.frame =  CGRectMake(acceptTerms!.frame.maxX + 12, self.acceptTerms!.frame.minY ,  self.email!.frame.width - (acceptTerms!.frame.width + 20)  , 75 )
        
        self.birthDate?.frame = CGRect(x: leftRightPadding,  y: confirmPassword!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.femaleButton!.frame = CGRect(x: 144,  y: birthDate!.frame.maxY + 15,  width: 76 , height: fieldHeight)
        self.maleButton!.frame = CGRect(x: self.femaleButton!.frame.maxX,  y: birthDate!.frame.maxY + 15, width: 76 , height: fieldHeight)
        
        self.cancelButton!.frame = CGRect(x: leftRightPadding,  y: maleButton!.frame.maxY + 15,  width: (self.email!.frame.width / 2) - 5 , height: fieldHeight)
        self.continueButton!.frame = CGRect(x: self.cancelButton!.frame.maxX + 10 , y: self.cancelButton!.frame.minY ,  width: self.cancelButton!.frame.width, height: fieldHeight)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.continueButton!.frame.maxY + 40)
        
//        self.cancelButton!.frame = CGRectMake(leftRightPadding,  self.contentTerms!.frame.minY + 15 + self.labelTerms!.frame.maxY,  self.confirmPassword!.frame.width, fieldHeight)
//        self.registryButton!.frame = CGRectMake(self.name!.frame.maxX + 10 , self.cancelButton!.frame.minY ,  self.confirmPassword!.frame.width, fieldHeight)
//        self.content.contentSize = CGSize(width: bounds.width, height: self.registryButton!.frame.maxY)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
   
  
    
}
