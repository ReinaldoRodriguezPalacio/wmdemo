//
//  SignUpMGViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 04/12/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class SignUpMGViewController: SignUpViewController {

    var checkVC : CheckOutViewController!
    var canceledAction : Bool = false
    
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
            
            let address = AddressViewController()
            address.typeAddress = TypeAddress.Shiping
            address.item =  NSDictionary()
            address.addFRomMg =  true
            address.backButton?.hidden =  true
            address.successCallBackRegistry = {() in
                
                let params = service.buildParamsWithMembership(self.email!.text!, password:  self.password!.text!, name: self.name!.text!, lastName: self.lastName!.text!,allowMarketingEmail:allowPub,birthdate:dateOfBirth,gender:gender,allowTransfer:allowTransfer)
                
                self.view.endEditing(true)
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
                
                service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                    
                    address.closeAlert()
                    
                    let login = LoginService()
                    login.callService(login.buildParams(self.email!.text!, password: self.password!.text!), successBlock: { (dict:NSDictionary) -> Void in
                        
                        self.alertView!.setMessage("Registro exitoso")
                        self.alertView!.showErrorIcon("Ok")
                        
                        }, errorBlock: { (error:NSError) -> Void in
                            
                            //self.alertView!.close()
                            address.registryAddress(self.email!.text!, password:self.password!.text!, successBlock: { (finish) -> Void in
                                //Cerrar el registro de la direccion y mandar al checkout
                                if finish{
                                   //mandar notificacion para cerrar logincontroller
                                    let params = ["userName":self.email!.text!,"password":self.password!.text!]
                                    NSNotificationCenter.defaultCenter().postNotificationName("CLOSELOGINFROMMG", object: params)
                                        print("Termina registro de direccion")
                                    
                                }else{
                                    //Error
                                    
                                    self.backRegistry(self.backButton!)
                                    self.alertView!.setMessage("Error")
                                    self.alertView!.showErrorIcon("Ok")
                                
                                }
                             
                                
                            })
                    })
                    
                    self.alertView!.close()
                    
                    }, errorBlock: {(error: NSError) in
                        
                        self.backRegistry(self.backButton!)
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                })// Close callService
                
            }//Close successCallBack
            
            self.view.addSubview(address.view)
            
        }
    }
    




}
