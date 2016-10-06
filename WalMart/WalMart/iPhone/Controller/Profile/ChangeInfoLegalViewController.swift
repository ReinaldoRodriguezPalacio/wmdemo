//
//  ChangeInfoLegalViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ChangeInfoLegalViewController : NavigationViewController {
    
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var errorView: FormFieldErrorView?
    var alertView: IPOWMAlertViewController?
    var viewLoad: WMLoadingView!
    
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
        
        self.promoAccept = UIButton(frame: CGRectMake(16,self.header!.frame.maxY + 16.0,  self.view.frame.width - 8, 16))
        
        
        let attr = NSMutableAttributedString(string: NSLocalizedString("preferences.legal.terms", comment: ""))
        attr.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProRegularOfSize(13), range: NSMakeRange(0, NSLocalizedString("preferences.legal.terms", comment: "").characters.count))
        attr.addAttribute(NSForegroundColorAttributeName, value: WMColor.reg_gray, range: NSRange(location: 0, length: 34))
        self.promoAccept!.setAttributedTitle(attr, forState: UIControlState.Normal)
        
        
        self.promoAccept?.setTitle(NSLocalizedString("preferences.legal.terms", comment: ""), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"filter_check_gray"), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        //self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(13)
        self.promoAccept!.titleLabel?.numberOfLines = 2
        self.promoAccept!.titleLabel?.lineBreakMode = .ByWordWrapping
        self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.promoAccept!.titleEdgeInsets = UIEdgeInsetsMake(15, 15, 0, 0);
        self.promoAccept!.addTarget(self, action: #selector(ChangeInfoLegalViewController.checkSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.promoAccept!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)

        
        lblPersonalData = UILabel(frame: CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, self.view.frame.width - 32, 84))
        lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
        lblPersonalData.textColor = WMColor.reg_gray
        lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(12)
        lblPersonalData.numberOfLines = 0
        
        
        self.acceptSharePersonal = UIButton(frame: CGRectMake(45, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_gray"), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.acceptSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.acceptSharePersonal!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)
        
        self.declineSharePersonal = UIButton(frame: CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_gray"), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.declineSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.declineSharePersonal!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view!.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(ChangeInfoLegalViewController.save(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
       
        let allowMarketing =  UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail
        let allowTransfer = UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer
        
        self.promoAccept?.selected = allowMarketing!.uppercaseString == "TRUE"
        self.acceptSharePersonal?.selected = allowTransfer!.uppercaseString == "TRUE"
        self.declineSharePersonal?.selected = allowTransfer!.uppercaseString != "TRUE"
        
        self.view.addSubview(promoAccept!)
        self.view.addSubview(lblPersonalData)
        self.view.addSubview(acceptSharePersonal!)
        self.view.addSubview(declineSharePersonal!)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.promoAccept!.frame = CGRectMake(16,self.header!.frame.maxY + 8.0,  self.view.frame.width, 16)
        lblPersonalData.frame = CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, self.view.frame.width - 32, 84)
        self.acceptSharePersonal!.frame = CGRectMake(45, lblPersonalData.frame.maxY + 24.0, 120, 16)
        self.declineSharePersonal!.frame = CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16)
        self.layerLine.frame = CGRectMake(0, self.view.frame.height - 66,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148, self.view.frame.height - 50, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.view.frame.height - 50, 140, 34)
        self.titleLabel!.frame = CGRectMake(80 , 0, self.view.bounds.width - 160, self.header!.frame.maxY)
    }
    
    
    /**
     call service to update profile info
     
     - parameter sender: button send action
     */
    func save(sender:UIButton) {
        
        let service = UpdateUserProfileService()
       
        
        if  UserCurrentSession.hasLoggedUser() { //let user = UserCurrentSession.sharedInstance().userSigned {
//            let name = user.profile.name
//            let mail = user.email
//            let lastMame = user.profile.lastName
//            let birthDate = user.profile.birthDate
//            let gender = user.profile.sex
            
            let allowMarketing = "\( self.promoAccept!.selected)"
            let allowTransfer = "\( self.acceptSharePersonal!.selected)"
            
            UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail = allowMarketing
            UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer = allowTransfer
            
            
            let params  = [:]//service.buildParamsWithMembership(mail as String, password: "", newPassword: "", name: name as String, lastName: lastMame as String,birthdate:birthDate as String,gender:gender as String,allowTransfer:allowTransfer,allowMarketingEmail:allowMarketing,associateStore: "",joinDate: "",associateNumber: "")
            
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
    
    
    /**
     Active or disactive send promotion.
     
     - parameter sender: button send action.
     */
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
    
    /**
    Enable or disable user personal info.
     
     - parameter sender: button send action.
     */
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

    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRectMake(0, 0, 341, 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
}