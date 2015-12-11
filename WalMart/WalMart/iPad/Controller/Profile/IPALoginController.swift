//
//  IPALoginController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 13/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPALoginController: LoginController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    
    override class func showLogin() -> IPALoginController! {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = IPALoginController()
        vc!.addChildViewController(newAlert)
        newAlert.view.frame = vc!.view.bounds
        vc!.view.addSubview(newAlert.view)
        newAlert.didMoveToParentViewController(vc)
        vc!.addChildViewController(newAlert)
        newAlert.view.tag = 5000
        return newAlert
    }
    
    
    override func registryUser() {
        if self.signUp == nil{
            
            self.signUp = isMGLogin ? IPASignMGUpViewController() : IPASignUpViewController()
            
            self.signUp!.view.frame = CGRectMake(self.viewCenter!.frame.width, self.content!.frame.minY, self.viewCenter!.frame.width, self.content!.frame.height)
            
            self.signUp.viewClose = {(hidden : Bool) in
                self.close!.hidden = hidden
            }
            
            self.signUp.cancelSignUp = {() in
                self.viewAnimated = true
                UIView.animateWithDuration(0.4, animations: {
                    self.signUp!.view.frame =  CGRectMake(self.viewCenter!.frame.width, self.content!.frame.minY, self.viewCenter!.frame.width, self.view.bounds.height)
                    self.signUp.view.alpha = 0
                    self.content!.frame = CGRectMake((self.viewCenter!.frame.width / 2) - (self.content!.frame.width / 2) , self.content!.frame.minY ,  self.content!.frame.width , self.content!.frame.height)
                    self.content!.alpha = 100
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.viewAnimated = false
                        }
                })
            }
            self.signUp.successCallBack =  {() in
                self.signUp.view.alpha = 0
                let service = LoginService()
                self.email!.text = self.signUp.email!.text!
                self.password!.text  =  self.signUp.password!.text
                let params  = service.buildParams(self.signUp.email!.text!, password: self.signUp.password!.text!)
                self.callService(params, alertViewService:self.signUp.alertView!)
                
            }// self.successCallBack
            //self.signUp.successCallBack = self.successCallBack
            
            self.viewCenter!.addSubview(signUp.view)
        }//if self.signUp == nil{
        
        signUp.view.alpha = 0
        self.viewAnimated = true
        
        UIView.animateWithDuration(0.4, animations: {
            self.signUp!.view.frame =  CGRectMake(0, self.content!.frame.minY, self.viewCenter!.frame.width, self.content!.frame.height)
            self.signUp.view.alpha = 1
            self.content!.frame = CGRectMake(-self.content!.frame.width, 50, self.content!.frame.width ,  self.content!.frame.height)
            self.content!.alpha = 0
            }, completion: {(bool : Bool) in
                if bool {
                    self.viewAnimated = false
                }
        })
    }

    
    func showAddres() {
        if self.addressViewController == nil && self.viewCenter!.frame.width > 0 {
            self.addressViewController = IPAAddressViewController()
            self.addressViewController!.hiddenBack = true
            self.addressViewController!.isLogin = true
            self.addressViewController!.view.frame = CGRectMake(self.viewCenter!.frame.width, self.content!.frame.minY, self.viewCenter!.frame.width, self.content!.frame.height)
            self.addressViewController!.typeAddress = TypeAddress.Shiping
            self.addressViewController!.item =  NSDictionary()
            self.addressViewController!.successCallBack = {() in
                self.viewAnimated = true
                UIView.animateWithDuration(0.4, animations: {
                    self.addressViewController!.view.frame =  CGRectMake(self.viewCenter!.frame.width, self.content!.frame.minY, self.viewCenter!.frame.width, self.view.bounds.height)
                    self.addressViewController.view.alpha = 0
                    self.content!.frame = CGRectMake((self.viewCenter!.frame.width / 2) - (self.content!.frame.width / 2) , self.content!.frame.minY ,  self.content!.frame.width , self.content!.frame.height)
                    self.content!.alpha = 100
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.viewAnimated = false
                        }
                })
            }
            self.viewCenter!.addSubview(addressViewController.view)
        }//if showAddres == nil{
    
        self.addressViewController!.view.backgroundColor = UIColor.clearColor()
        self.addressViewController!.titleLabel!.textColor = UIColor.whiteColor()
        self.addressViewController!.viewAddress!.backgroundColor = UIColor.clearColor()
        
        addressViewController.view.alpha = 0
        self.viewAnimated = true
        addressViewController!.addressFiscalButton!.enabled = false
        addressViewController!.header!.backgroundColor = UIColor.clearColor()
        
            UIView.animateWithDuration(0.4, animations: {
                self.addressViewController!.view.frame =  CGRectMake(0, self.content!.frame.minY, self.viewCenter!.frame.width, self.content!.frame.height)
            self.addressViewController.view.alpha = 1
                self.content!.frame = CGRectMake(-self.content!.frame.width, 50, self.content!.frame.width ,  self.content!.frame.height)
                self.content!.alpha = 0
                }, completion: {(bool : Bool) in
                    if bool {
                        self.viewAnimated = false
                    }
            })
        
    }
    
}
