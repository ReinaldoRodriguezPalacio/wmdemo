//
//  SignUpMGViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 04/12/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class SignUpMGViewController: SignUpViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override   func registryUser() {
        
        if validateTerms() {
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SIGNUP.rawValue,action: WMGAIUtils.ACTION_SAVE_SIGNUP.rawValue, label: "")
            
            let service = SignUpService()
            
            let dateFmtBD = NSDateFormatter()
            dateFmtBD.dateFormat = "dd/MM/yyyy"
            
            let dateOfBirth = dateFmtBD.stringFromDate(self.dateVal!)
            let gender = femaleButton!.selected ? "Female" : "Male"
            let allowTransfer = "\(self.acceptSharePersonal!.selected)"
            let allowPub = "\(self.promoAccept!.selected)"
            
            let params = service.buildParamsWithMembership(email!.text!, password:  password!.text!, name: name!.text!, lastName: lastName!.text!,allowMarketingEmail:allowPub,birthdate:dateOfBirth,gender:gender,allowTransfer:allowTransfer)
            
//            if alertAddress == nil {
//              alertAddress = GRFormAddressAlertView.initAddressAlert()!
//          }
           // alertAddress?.showAddressAlert()
          //  alertAddress?.beforeAddAddress = {(dictSend:NSDictionary?) in
                self.view.endEditing(true)
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
                
                service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                    
                    let login = LoginService()
                    login.callService(login.buildParams(self.email!.text!, password: self.password!.text!), successBlock: { (dict:NSDictionary) -> Void in
                        
                       //self.alertAddress?.registryAddress(dictSend)
                        
                        }, errorBlock: { (error:NSError) -> Void in
                            self.alertView!.close()
                            //self.alertAddress?.registryAddress(dictSend)
                    })
                    
                    }
                    , errorBlock: {(error: NSError) in
                        
                        self.backRegistry(self.backButton!)
                        //self.alertAddress?.removeFromSuperview()
                        
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                })
            //}
            
            
        }
    }



}
