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
    
    var promoEmail: UIButton? = nil
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
        
        self.view.backgroundColor = UIColor.white
        
        self.titleLabel!.text = NSLocalizedString("signup.info", comment: "")
        
        self.promoEmail = UIButton(frame: CGRect(x: 16,y: self.header!.frame.maxY + 16.0,  width: self.view.frame.width, height: 16))
        self.promoEmail!.setTitle(NSLocalizedString("signup.info.pub", comment: ""), for: UIControlState())
        self.promoEmail!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.promoEmail!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.promoEmail!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
        self.promoEmail!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.promoEmail!.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
        self.promoEmail!.addTarget(self, action: #selector(ChangeInfoLegalViewController.checkPromoEmail(_:)), for: UIControlEvents.touchUpInside)
        self.promoEmail!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        
        self.promoAccept = UIButton(frame: CGRect(x: 16, y: self.promoEmail!.frame.maxY + 30.0,  width: self.view.frame.width - 16, height: 18))
        
        let attr = NSMutableAttributedString(string: NSLocalizedString("preferences.legal.terms", comment: ""))
        attr.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12), range: NSMakeRange(0, NSLocalizedString("preferences.legal.terms", comment: "").characters.count))
        attr.addAttribute(NSForegroundColorAttributeName, value: WMColor.reg_gray, range: NSMakeRange( 0, attr.length))
        
        let attrPrivacy = NSMutableAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: ""))
        attrPrivacy.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProSemiboldSize(IS_IPAD ? 14 : 12), range: NSMakeRange(0, attrPrivacy.length))
        attrPrivacy.addAttribute(NSForegroundColorAttributeName, value: WMColor.reg_gray, range: NSMakeRange( 0, attrPrivacy.length))

        attr.append(attrPrivacy)
        
        self.promoAccept!.setAttributedTitle(attr, for: UIControlState())
        
        self.promoAccept!.setImage(UIImage(named:"check_blue"), for: UIControlState())
        self.promoAccept!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        //self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(13)
        self.promoAccept!.titleLabel?.numberOfLines = 2
        self.promoAccept!.titleLabel?.lineBreakMode = .byWordWrapping
        self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.promoAccept!.titleEdgeInsets = IS_IPAD ? UIEdgeInsetsMake(5, 16, 0, 0) : UIEdgeInsetsMake(12, 16, 0, 0)
        self.promoAccept!.addTarget(self, action: #selector(ChangeInfoLegalViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        self.promoAccept!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        
        lblPersonalData = UILabel(frame: CGRect(x: 16, y: self.promoAccept!.frame.maxY + 24.0, width: self.view.frame.width - 32, height: 84))
        lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
        lblPersonalData.textColor = WMColor.reg_gray
        lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
        lblPersonalData.numberOfLines = 0
        
        self.acceptSharePersonal = UIButton(frame: CGRect(x: 45, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16))
        self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), for: UIControlState())
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.acceptSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), for: UIControlState.selected)
        self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
        self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.acceptSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), for: UIControlEvents.touchUpInside)
        self.acceptSharePersonal!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        
        self.declineSharePersonal = UIButton(frame: CGRect(x: acceptSharePersonal!.frame.maxX, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16))
        self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), for: UIControlState())
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.declineSharePersonal!.setImage(UIImage(named:"filter_check_blue_selected"), for: UIControlState.selected)
        self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(IS_IPAD ? 14 : 12)
        self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.declineSharePersonal!.addTarget(self, action: #selector(ChangeInfoLegalViewController.changeCons(_:)), for: UIControlEvents.touchUpInside)
        self.declineSharePersonal!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view!.layer.insertSublayer(layerLine, at: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(ChangeInfoLegalViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
       
        let allowMarketing =  UserCurrentSession.sharedInstance.userSigned?.profile.allowMarketingEmail
        let allowTransfer = UserCurrentSession.sharedInstance.userSigned?.profile.allowTransfer
        
        self.promoAccept?.isSelected = allowMarketing!.uppercased == "TRUE"
        self.acceptSharePersonal?.isSelected = allowTransfer!.uppercased == "TRUE"
        self.declineSharePersonal?.isSelected = allowTransfer!.uppercased != "TRUE"
        
        if isPreferences {
            self.promoAccept?.isSelected = true
        }
        
        self.view.addSubview(promoEmail!)
        self.view.addSubview(promoAccept!)
        self.view.addSubview(lblPersonalData)
        self.view.addSubview(acceptSharePersonal!)
        self.view.addSubview(declineSharePersonal!)
        
        self.invokePreferenceService()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.promoEmail!.frame = CGRect(x: 16, y: self.header!.frame.maxY + 16.0, width: self.view.frame.width - 24, height: 16)
        self.promoAccept!.frame = CGRect(x: 16, y: self.promoEmail!.frame.maxY + 30.0, width: self.view.frame.width - 24, height: 16)
        self.lblPersonalData.frame = CGRect(x: 16, y: self.promoAccept!.frame.maxY + (IS_IPAD ? 8 : 24), width: self.view.frame.width - 32, height: 84)
        self.acceptSharePersonal!.frame = CGRect(x: (IS_IPAD ? 16 : 50), y: lblPersonalData.frame.maxY + (IS_IPAD ? 16 : 24), width: 120, height: 16)
        self.declineSharePersonal!.frame = CGRect(x: acceptSharePersonal!.frame.maxX, y: lblPersonalData.frame.maxY + (IS_IPAD ? 16 : 24), width: 120, height: 16)
        
        if TabBarHidden.isTabBarHidden || IS_IPAD {
            self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 66,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 50, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 50, width: 140, height: 34)
        } else {
            self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 112,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 96, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 96, width: 140, height: 34)
        }
        
        self.titleLabel!.frame = CGRect(x: 80 , y: 0, width: self.view.bounds.width - 160, height: self.header!.frame.maxY)
    }
    
    /**
     call service to update profile info
     
     - parameter sender: button send action
     */
    func save(_ sender:UIButton) {
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
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = true
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:sender.selected ? WMGAIUtils.ACTION_ENABLE_PROMO.rawValue : WMGAIUtils.ACTION_DISBALE_PROMO.rawValue, label: "")
        self.openPrivacyNotice()
    }
    
    func checkPromoEmail(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action:sender.selected ? WMGAIUtils.ACTION_ENABLE_PROMO.rawValue : WMGAIUtils.ACTION_DISBALE_PROMO.rawValue, label: "")
    }
    
    /**
    Enable or disable user personal info.
     
     - parameter sender: button send action.
     */
    func changeCons(_ sender:UIButton) {
        if sender == self.acceptSharePersonal {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action: WMGAIUtils.ACTION_LEGAL_ACEPT.rawValue, label: "")
            self.acceptSharePersonal?.isSelected = true
            self.declineSharePersonal?.isSelected = false
        } else if sender == self.declineSharePersonal  {
             BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LEGAL_INFORMATION.rawValue, action: WMGAIUtils.ACTION_LEGAL_NO_ACEPT.rawValue, label: "")
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

    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRect(x: 0, y: 0, width: 341, height: 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.white
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
    
    fileprivate func invokePreferenceService(){
        
        self.addViewLoad()
        
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:[String:Any]) in
            self.userPreferences.addEntries(from: result as! [String:Any])
            let acceptConsent = result["receiveInfoEmail"] as! Bool
            let promoEmail = result["receiveInfoEmail"] as! Bool
            self.promoEmail?.isSelected = promoEmail
            self.acceptSharePersonal?.isSelected = acceptConsent
            self.declineSharePersonal?.isSelected = !acceptConsent
            self.removeViewLoad()
        }, errorBlock: { (error:NSError) in
            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"alert_ups"),imageDone:UIImage(named:"alert_ups"),imageError:UIImage(named:"alert_ups"))
            alertView!.setMessage(NSLocalizedString("preferences.message.errorLoad", comment:""))
            alertView!.showErrorIcon("Ok")
            self.removeViewLoad()
            print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    fileprivate func invokeSavepeferences(){
        
        // TODO preguntar por valor:: acceptConsent
        
        let peferencesService = SetPreferencesService()
        let params = peferencesService.buildParams(self.userPreferences["userPreferences"] as! NSArray, onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as! String, abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.promoEmail!.isSelected ? "Si" : "No", forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: self.acceptSharePersonal!.isSelected, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
        peferencesService.jsonFromObject(params)
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"icon_alert_saving"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"alert_ups"))
        self.alertView!.setMessage(NSLocalizedString("preferences.message.saving", comment:""))
        
        peferencesService.callService(requestParams:params , successBlock: { (result:[String:Any]) in
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
        controller.titleText = NSLocalizedString(name, comment: "") as NSString!
        controller.resource = "privacy"
        controller.type = "pdf"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
}
