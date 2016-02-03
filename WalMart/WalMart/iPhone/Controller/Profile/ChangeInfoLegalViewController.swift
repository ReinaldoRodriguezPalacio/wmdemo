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
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.titleLabel!.text = NSLocalizedString("profile.change.legalinfo", comment: "")
        
        
        self.promoAccept = UIButton(frame: CGRectMake(16,self.header!.frame.maxY + 16.0,  self.view.frame.width, 16))
        self.promoAccept?.setTitle(NSLocalizedString("signup.info.pub", comment: ""), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.promoAccept!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.promoAccept!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        self.promoAccept!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)

        
        lblPersonalData = UILabel(frame: CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, self.view.frame.width - 32, 84))
        lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
        lblPersonalData.textColor = WMColor.gray
        lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(12)
        lblPersonalData.numberOfLines = 0
        
        
        self.acceptSharePersonal = UIButton(frame: CGRectMake(45, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.acceptSharePersonal!.addTarget(self, action: "changeCons:", forControlEvents: UIControlEvents.TouchUpInside)
        self.acceptSharePersonal!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        
        self.declineSharePersonal = UIButton(frame: CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.declineSharePersonal!.addTarget(self, action: "changeCons:", forControlEvents: UIControlEvents.TouchUpInside)
        self.declineSharePersonal!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        self.saveButton = WMRoundButton()
        //self.saveButton!.setImage(iconImage, forState: UIControlState.Normal)
        //self.saveButton!.setImage(iconSelected, forState: UIControlState.Highlighted)
        self.saveButton!.setBackgroundColor(WMColor.UIColorFromRGB(0x8EBB36), size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.saveButton!.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton!.tintColor = WMColor.navigationFilterTextColor
        self.saveButton!.layer.cornerRadius = 11
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.saveButton?.titleLabel!.textColor = WMColor.navigationFilterTextColor
        self.saveButton!.hidden = true
        self.saveButton!.tag = 0
        self.header?.addSubview(self.saveButton!)

        let allowMarketing =  UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail
        let allowTransfer = UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer
        
        self.promoAccept?.selected = allowMarketing!.uppercaseString == "TRUE"
        self.acceptSharePersonal?.selected = allowTransfer!.uppercaseString == "TRUE"
        self.declineSharePersonal?.selected = allowTransfer!.uppercaseString != "TRUE"
        
        self.view.addSubview(promoAccept!)
        self.view.addSubview(lblPersonalData)
        self.view.addSubview(acceptSharePersonal!)
        self.view.addSubview(declineSharePersonal!)
        
        
    }

    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.promoAccept!.frame = CGRectMake(16,self.header!.frame.maxY + 8.0,  self.view.frame.width, 16)
        lblPersonalData.frame = CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, self.view.frame.width - 32, 84)
        self.acceptSharePersonal!.frame = CGRectMake(45, lblPersonalData.frame.maxY + 24.0, 120, 16)
        self.declineSharePersonal!.frame = CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16)
        self.saveButton!.frame = CGRectMake( self.view.bounds.maxX - 87, 0 , 71, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(80 , 0, self.view.bounds.width - 160, self.header!.frame.maxY)
    }
    
    func save(sender:UIButton) {
        
        let service = UpdateUserProfileService()
       
        
        if let user = UserCurrentSession.sharedInstance().userSigned {
            let name = user.profile.name
            let mail = user.email
            let lastMame = user.profile.lastName
            let birthDate = user.profile.birthDate
            let gender = user.profile.sex
            
            let allowMarketing = "\( self.promoAccept!.selected)"
            let allowTransfer = "\( self.acceptSharePersonal!.selected)"
            
            UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail = allowMarketing
            UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer = allowTransfer
            
            
            let params  = service.buildParamsWithMembership(mail as String, password: "", newPassword: "", name: name as String, lastName: lastMame as String,birthdate:birthDate as String,gender:gender as String,allowTransfer:allowTransfer,allowMarketingEmail:allowMarketing)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label:"")
            
            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.navigationController!.popViewControllerAnimated(true)
                },errorBlock: {(error: NSError) in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
            
        }
    }
    
    
    
    func checkSelected(sender:UIButton) {
        sender.selected = !(sender.selected)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:sender.selected ? WMGAIUtils.ACTION_ENABLE_PROMO.rawValue : WMGAIUtils.ACTION_DISBALE_PROMO.rawValue, label: "")
        if errorView != nil{
            if errorView?.superview != nil {
                errorView?.removeFromSuperview()
            }
            errorView!.focusError = nil
            errorView = nil
        }
        if self.saveButton!.hidden {
            self.saveButton!.hidden = false
            UIView.animateWithDuration(0.4, animations: {
                self.saveButton!.alpha = 1.0
                }, completion: {(bool : Bool) in
                    if bool {
                        self.saveButton!.alpha = 1.0
                    }
            })
        }
    }
    
    func changeCons(sender:UIButton) {
        if sender == self.acceptSharePersonal {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action: WMGAIUtils.ACTION_LEGAL_ACEPT.rawValue, label: "")
            self.acceptSharePersonal?.selected = true
            self.declineSharePersonal?.selected = false
        } else if sender == self.declineSharePersonal  {
             BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action: WMGAIUtils.ACTION_LEGAL_NO_ACEPT.rawValue, label: "")
            self.acceptSharePersonal?.selected = false
            self.declineSharePersonal?.selected = true
        }
        if self.saveButton!.hidden {
            self.saveButton!.hidden = false
            UIView.animateWithDuration(0.4, animations: {
                self.saveButton!.alpha = 1.0
                }, completion: {(bool : Bool) in
                    if bool {
                        self.saveButton!.alpha = 1.0
                    }
            })
        }
        
    }

    
}