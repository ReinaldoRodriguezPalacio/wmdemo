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
    var isPreferences:Bool = false
    var userPreferences: NSMutableDictionary = [:]
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LEGALINFORMATION.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.titleLabel!.text = NSLocalizedString("profile.change.legalinfo", comment: "")
        self.promoAccept = UIButton(frame: CGRectMake(16, self.header!.frame.maxY + 16.0,  self.view.frame.width - 8, 16))
        
        let attr = NSMutableAttributedString(string: NSLocalizedString("preferences.legal.terms", comment: ""))
        attr.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12), range: NSMakeRange(0, NSLocalizedString("preferences.legal.terms", comment: "").characters.count))
        attr.addAttribute(NSForegroundColorAttributeName, value: WMColor.reg_gray, range: NSRange(location: 0, length: 34))
        self.promoAccept!.setAttributedTitle(attr, forState: UIControlState.Normal)
        
        self.promoAccept!.setTitle(NSLocalizedString("preferences.legal.terms", comment: ""), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        //self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(13)
        self.promoAccept!.titleLabel?.numberOfLines = 2
        self.promoAccept!.titleLabel?.lineBreakMode = .ByWordWrapping
        self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.promoAccept!.titleEdgeInsets = IS_IPAD ? UIEdgeInsetsMake(5, 16, 0, 0) : UIEdgeInsetsMake(5, 8, 0, 0)
        self.promoAccept!.addTarget(self, action: #selector(ChangeInfoLegalViewController.checkSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.promoAccept!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)
        
        lblPersonalData = UILabel(frame: CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, self.view.frame.width - 32, 84))
        lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
        lblPersonalData.textColor = WMColor.reg_gray
        lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
        lblPersonalData.numberOfLines = 0
        
        self.acceptSharePersonal = UIButton(frame: CGRectMake(45, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_gray"), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
        self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.acceptSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.acceptSharePersonal!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)
        
        self.declineSharePersonal = UIButton(frame: CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_gray"), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), forState: UIControlState.Selected)
        self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
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
        
        if isPreferences {
            self.promoAccept?.selected = true
        }
        
        self.view.addSubview(promoAccept!)
        self.view.addSubview(lblPersonalData)
        self.view.addSubview(acceptSharePersonal!)
        self.view.addSubview(declineSharePersonal!)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
        self.invokePreferenceService()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.promoAccept!.frame = CGRectMake(16, self.header!.frame.maxY + 8.0, self.view.frame.width - 16, 16)
        self.lblPersonalData.frame = CGRectMake(16, self.promoAccept!.frame.maxY + (IS_IPAD ? 8 : 24), self.view.frame.width - 32, 84)
        self.acceptSharePersonal!.frame = CGRectMake(16, lblPersonalData.frame.maxY + (IS_IPAD ? 16 : 24), 120, 16)
        self.declineSharePersonal!.frame = CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + (IS_IPAD ? 16 : 24), 120, 16)
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
        if  UserCurrentSession.hasLoggedUser() {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label:"")
            self.view.endEditing(true)
            self.invokeSavepeferences()
        }
    }
    
    
    /**
     Active or disactive send promotion.
     
     - parameter sender: button send action.
     */
    func checkSelected(sender:UIButton) {
        sender.selected = true
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:sender.selected ? WMGAIUtils.ACTION_ENABLE_PROMO.rawValue : WMGAIUtils.ACTION_DISBALE_PROMO.rawValue, label: "")
        self.openPrivacyNotice()
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
    
    private func invokePreferenceService(){
        
        self.addViewLoad()
        
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:NSDictionary) in
            self.userPreferences.addEntriesFromDictionary(result as [NSObject : AnyObject])
            let acceptConsent = result["receiveInfoEmail"] as! Bool
            self.acceptSharePersonal?.selected = acceptConsent
            self.declineSharePersonal?.selected = !acceptConsent
            self.removeViewLoad()
        }, errorBlock: { (error:NSError) in
            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"alert_ups"),imageDone:UIImage(named:"alert_ups"),imageError:UIImage(named:"alert_ups"))
            alertView!.setMessage(NSLocalizedString("preferences.message.errorLoad", comment:""))
            alertView!.showErrorIcon("Ok")
            self.removeViewLoad()
            print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    private func invokeSavepeferences(){
        
        // TODO preguntar por valor:: acceptConsent
        
        let peferencesService = SetPreferencesService()
        let params = peferencesService.buildParams(self.userPreferences["userPreferences"] as! NSArray, onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as! String, abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.userPreferences["receivePromoEmail"] as! String, forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: self.acceptSharePersonal!.selected, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
        peferencesService.jsonFromObject(params)
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"icon_alert_saving"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"alert_ups"))
        self.alertView!.setMessage(NSLocalizedString("preferences.message.saving", comment:""))
        
        peferencesService.callService(requestParams:params , successBlock: { (result:NSDictionary) in
            print("Preferencias Guardadas")
            self.alertView!.setMessage(NSLocalizedString("preferences.message.saved", comment:""))
            self.alertView!.showDoneIcon()
            self.invokePreferenceService()
            }, errorBlock: { (error:NSError) in
                print("Hubo un error al guardar las Preferencias")
                self.alertView!.setMessage(NSLocalizedString("preferences.message.errorSave", comment:""))
                self.alertView!.showErrorIcon("Ok")
        })
        
    }
    
    func openPrivacyNotice() {
        let controller = PreviewHelpViewController()
        let name = NSLocalizedString("profile.terms.privacy", comment: "")
        controller.titleText = NSLocalizedString(name, comment: "")
        controller.resource = "privacy"
        controller.type = "pdf"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
}