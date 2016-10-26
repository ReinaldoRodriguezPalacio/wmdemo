//
//  IPASignMGUpViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/12/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation
class IPASignMGUpViewController: IPASignUpViewController {
    
    var addressMGView: IPAAddressViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func registryUser() {
        
        if validateTerms() {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SIGNUP.rawValue,action: WMGAIUtils.ACTION_SAVE_SIGNUP.rawValue, label: "")
            
            let service = SignUpService()
            let dateFmtBD = NSDateFormatter()
            dateFmtBD.dateFormat = "dd/MM/yyyy"
            
            let dateOfBirth = dateFmtBD.stringFromDate(self.dateVal!)
            let gender = femaleButton!.selected ? "Female" : "Male"
            let allowTransfer = "\(self.acceptSharePersonal!.selected)"
            let allowPub = "\(self.promoAccept!.selected)"
            
            self.addressMGView = IPAAddressViewController()
            self.addressMGView.view?.frame.size = CGSizeMake(self.view.frame.width, self.view.frame.height - 60)
            self.addressMGView.typeAddress = TypeAddress.Shiping
            self.addressMGView.item =  NSDictionary()
            self.addressMGView.addFRomMg =  true
            self.addressMGView.showSaveAlert = false
            self.addressMGView.backButton?.hidden =  true
            self.addressMGView.saveButton?.titleLabel?.textAlignment = .Center
            self.addressMGView.successCallBackRegistry = {() in
                
                let params = service.buildParamsWithMembership(self.email!.text!, password:  self.password!.text!, name: self.name!.text!, lastName: self.lastName!.text!,allowMarketingEmail:allowPub,birthdate:dateOfBirth,gender:gender,allowTransfer:allowTransfer)
                
                self.view.endEditing(true)
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
                if self.addressMGView.viewAddress!.validateAddress() {
                    service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                        self.addressMGView.closeAlert()
                        let login = LoginService()
                        var firstEnter = true
                        login.callService(login.buildParams(self.email!.text!, password: self.password!.text!), successBlock: { (dict:NSDictionary) -> Void in
                            
                            // Event -- Succesful Registration
                            BaseController.sendAnalyticsSuccesfulRegistration()
                            
                            //self.alertView!.setMessage("Registro exitoso")
                            //self.alertView!.showDoneIcon()
                            self.successCallBack?()
                            }, errorBlock: { (error:NSError) -> Void in
                                self.addressMGView.registryAddress(self.email!.text!, password:self.password!.text!, successBlock: { (finish) -> Void in
                                    //Cerrar el registro de la direccion y mandar al checkout
                                    if finish{
                                        UserCurrentSession.sharedInstance().setMustUpdatePhoneProfile(self.addressMGView!.viewAddress!.telephone!.text!, work: "", cellPhone: "")
                                        self.addressMGView.view.removeFromSuperview()
                                        //self.alertView!.setMessage("Registro exitoso")
                                        //self.alertView!.showDoneIcon()
                                        if firstEnter{
                                            self.successCallBack?()
                                            firstEnter = false
                                        }
                                        print("Termina registro de direccion")
                                    }else{
                                        //Error
                                        self.backRegistry(self.backButton!)
                                        self.alertView!.setMessage("Error")
                                        self.alertView!.showErrorIcon("Ok")
                                        BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(error.localizedDescription, stepError: "Direcciones")
                                    }
                                })
                        })// close loginCallService
                        
                        
                        
                        }, errorBlock: {(error: NSError) in
                            
                            self.addressMGView.view.removeFromSuperview()
                            self.backRegistry(self.backButton!)
                            self.alertView!.setMessage(error.localizedDescription)
                            self.alertView!.showErrorIcon("Ok")
                            BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(error.localizedDescription, stepError: "Datos personales")
                    })// Close callService
                }else{//close validateService
                    if let errorView = self.addressMGView.viewAddress!.errorView {
                        BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(errorView.errorLabel.text!, stepError: "Direcciones")
                    }
                    self.alertView!.close()
                }
                
            }//Close successCallBack
            
            self.view.addSubview(self.addressMGView.view)
            
        }
    }
}