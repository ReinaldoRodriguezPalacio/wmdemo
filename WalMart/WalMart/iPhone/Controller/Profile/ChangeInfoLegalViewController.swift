//
//  ChangeInfoLegalViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ChangeInfoLegalViewController : NavigationViewController {
    
    var saveButton: WMRoundButton?
    
    var errorView: FormFieldErrorView?
    var alertView: IPOWMAlertViewController?
    
    var promoAccept : UIButton? = nil
    var acceptSharePersonal : UIButton? = nil
    var declineSharePersonal : UIButton? = nil
    var lblPersonalData : UILabel!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LEGALINFORMATION.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.titleLabel!.text = NSLocalizedString("profile.change.legalinfo", comment: "")
        
        
        self.promoAccept = UIButton(frame: CGRect(x: 16,y: self.header!.frame.maxY + 16.0,  width: self.view.frame.width, height: 16))
        self.promoAccept?.setTitle(NSLocalizedString("signup.info.pub", comment: ""), for: UIControlState())
        self.promoAccept!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.promoAccept!.setImage(UIImage(named:"filter_check_blue_selected"), for: UIControlState.selected)
        self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.promoAccept!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.promoAccept!.addTarget(self, action: #selector(ChangeInfoLegalViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        self.promoAccept!.setTitleColor(WMColor.gray, for: UIControlState())

        
        lblPersonalData = UILabel(frame: CGRect(x: 16, y: self.promoAccept!.frame.maxY + 24.0, width: self.view.frame.width - 32, height: 84))
        lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
        lblPersonalData.textColor = WMColor.gray
        lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(12)
        lblPersonalData.numberOfLines = 0
        
        
        self.acceptSharePersonal = UIButton(frame: CGRect(x: 45, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16))
        self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), for: UIControlState())
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), for: UIControlState.selected)
        self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.acceptSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), for: UIControlEvents.touchUpInside)
        self.acceptSharePersonal!.setTitleColor(WMColor.gray, for: UIControlState())
        
        self.declineSharePersonal = UIButton(frame: CGRect(x: acceptSharePersonal!.frame.maxX, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16))
        self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), for: UIControlState())
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), for: UIControlState.selected)
        self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.declineSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), for: UIControlEvents.touchUpInside)
        self.declineSharePersonal!.setTitleColor(WMColor.gray, for: UIControlState())
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        self.saveButton = WMRoundButton()
        //self.saveButton!.setImage(iconImage, forState: UIControlState.Normal)
        //self.saveButton!.setImage(iconSelected, forState: UIControlState.Highlighted)
        self.saveButton!.setBackgroundColor(WMColor.green, size: CGSize(width: 71, height: 22), forUIControlState: UIControlState())
        self.saveButton!.addTarget(self, action: #selector(ChangeInfoLegalViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , for: UIControlState())
        self.saveButton!.tintColor = UIColor.white
        self.saveButton!.layer.cornerRadius = 11
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.saveButton?.titleLabel!.textColor = UIColor.white
        self.saveButton!.isHidden = true
        self.saveButton!.tag = 0
        self.header?.addSubview(self.saveButton!)

        let allowMarketing =  UserCurrentSession.sharedInstance.userSigned?.profile.allowMarketingEmail
        let allowTransfer = UserCurrentSession.sharedInstance.userSigned?.profile.allowTransfer
        
        self.promoAccept?.isSelected = allowMarketing!.uppercased == "TRUE"
        self.acceptSharePersonal?.isSelected = allowTransfer!.uppercased == "TRUE"
        self.declineSharePersonal?.isSelected = allowTransfer!.uppercased != "TRUE"
        
        self.view.addSubview(promoAccept!)
        self.view.addSubview(lblPersonalData)
        self.view.addSubview(acceptSharePersonal!)
        self.view.addSubview(declineSharePersonal!)
        
        
    }

    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.promoAccept!.frame = CGRect(x: 16,y: self.header!.frame.maxY + 8.0,  width: self.view.frame.width, height: 16)
        lblPersonalData.frame = CGRect(x: 16, y: self.promoAccept!.frame.maxY + 24.0, width: self.view.frame.width - 32, height: 84)
        self.acceptSharePersonal!.frame = CGRect(x: 45, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16)
        self.declineSharePersonal!.frame = CGRect(x: acceptSharePersonal!.frame.maxX, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16)
        self.saveButton!.frame = CGRect( x: self.view.bounds.maxX - 87, y: 0 , width: 71, height: self.header!.frame.height)
        self.titleLabel!.frame = CGRect(x: 80 , y: 0, width: self.view.bounds.width - 160, height: self.header!.frame.maxY)
    }
    
    
    /**
     call service to update profile info
     
     - parameter sender: button send action
     */
    func save(_ sender:UIButton) {
        
        let service = UpdateUserProfileService()
       
        
        if let user = UserCurrentSession.sharedInstance.userSigned {
            let name = user.profile.name
            let mail = user.email
            let lastMame = user.profile.lastName
            let birthDate = user.profile.birthDate
            let gender = user.profile.sex
            
            let allowMarketing = "\( self.promoAccept!.isSelected)"
            let allowTransfer = "\( self.acceptSharePersonal!.isSelected)"
            
            UserCurrentSession.sharedInstance.userSigned?.profile.allowMarketingEmail = allowMarketing as NSString
            UserCurrentSession.sharedInstance.userSigned?.profile.allowTransfer = allowTransfer as NSString
            
            
            let params  = service.buildParamsWithMembership(mail as String, password: "", newPassword: "", name: name as String, lastName: lastMame as String,birthdate:birthDate as String,gender:gender as String,allowTransfer:allowTransfer,allowMarketingEmail:allowMarketing)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label:"")
            
            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:[String:Any]?) in
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.navigationController!.popViewController(animated: true)
                },errorBlock: {(error: NSError) in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
            
        }
    }
    
    
    /**
     Active or disactive send promotion.
     
     - parameter sender: button send action.
     */
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = !(sender.isSelected)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:sender.selected ? WMGAIUtils.ACTION_ENABLE_PROMO.rawValue : WMGAIUtils.ACTION_DISBALE_PROMO.rawValue, label: "")
        if errorView != nil{
            if errorView?.superview != nil {
                errorView?.removeFromSuperview()
            }
            errorView!.focusError = nil
            errorView = nil
        }
        if self.saveButton!.isHidden {
            self.saveButton!.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.saveButton!.alpha = 1.0
                }, completion: {(bool : Bool) in
                    if bool {
                        self.saveButton!.alpha = 1.0
                    }
            })
        }
    }
    
    /**
    Enable or disable user personal info.
     
     - parameter sender: button send action.
     */
    func changeCons(_ sender:UIButton) {
        if sender == self.acceptSharePersonal {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action: WMGAIUtils.ACTION_LEGAL_ACEPT.rawValue, label: "")
            self.acceptSharePersonal?.isSelected = true
            self.declineSharePersonal?.isSelected = false
        } else if sender == self.declineSharePersonal  {
             //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action: WMGAIUtils.ACTION_LEGAL_NO_ACEPT.rawValue, label: "")
            self.acceptSharePersonal?.isSelected = false
            self.declineSharePersonal?.isSelected = true
        }
        if self.saveButton!.isHidden {
            self.saveButton!.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.saveButton!.alpha = 1.0
                }, completion: {(bool : Bool) in
                    if bool {
                        self.saveButton!.alpha = 1.0
                    }
            })
        }
        
    }

    
}
