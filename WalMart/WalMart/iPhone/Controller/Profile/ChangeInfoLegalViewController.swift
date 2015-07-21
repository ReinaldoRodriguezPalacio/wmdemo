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
    
    var errorView: FormFieldErrorView?
    var alertView: IPOWMAlertViewController?
    
    var labelTerms : UILabel? = nil
    var acceptTerms : UIButton? = nil
    var promoAccept : UIButton? = nil
    var acceptSharePersonal : UIButton? = nil
    var declineSharePersonal : UIButton? = nil
    var registryButton: UIButton?
    var contentTerms: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel!.text = NSLocalizedString("profile.change.legalinfo", comment: "")
        
        
        self.promoAccept = UIButton(frame: CGRectMake(16,self.header!.frame.maxY + 8.0,  self.view.frame.width, 16))
        self.promoAccept?.setTitle(NSLocalizedString("signup.info.pub", comment: ""), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.promoAccept!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
        self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.promoAccept!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.promoAccept!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.contentTerms = UIView()
        self.contentTerms!.frame = CGRectMake(0 ,  self.promoAccept!.frame.maxY + 24.0 , self.view.bounds.width ,30)
        
        acceptTerms = UIButton()
        acceptTerms!.frame = CGRectMake(10, -4, 30, 30 )
        acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
        acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        acceptTerms!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        labelTerms = UILabel()
        labelTerms?.frame =  CGRectMake(acceptTerms!.frame.maxX + 4, 0 ,  self.view!.frame.width - (acceptTerms!.frame.width + 15 )  , 30 )
        labelTerms!.numberOfLines = 0
        labelTerms!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        var valueItem = NSMutableAttributedString()
        var valuesDescItem = NSMutableAttributedString()
        var attrStringLab = NSAttributedString(string: NSLocalizedString("signup.info.provacity", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName:UIColor.whiteColor()])
        valuesDescItem.appendAttributedString(attrStringLab)
        var attrStringVal = NSAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName:UIColor.whiteColor()])
        valuesDescItem.appendAttributedString(attrStringVal)
        valuesDescItem.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, valuesDescItem.length))
        labelTerms!.attributedText = valuesDescItem
        labelTerms!.textColor = UIColor.whiteColor()
        
        //viewTap = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:"noticePrivacy:")
        labelTerms?.userInteractionEnabled = true
        labelTerms?.addGestureRecognizer(tapGestureRecognizer)
        
        
        self.contentTerms!.addSubview(acceptTerms!)
        self.contentTerms!.addSubview(labelTerms!)
        
        
        let lblPersonalData = UILabel(frame: CGRectMake(16, self.contentTerms!.frame.maxY + 24.0, self.view.frame.width - 32, 84))
        lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
        lblPersonalData.textColor = UIColor.whiteColor()
        lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(12)
        lblPersonalData.numberOfLines = 0
        
        
        self.acceptSharePersonal = UIButton(frame: CGRectMake(45, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.acceptSharePersonal!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
        self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.acceptSharePersonal!.addTarget(self, action: "changeCons:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.declineSharePersonal = UIButton(frame: CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16))
        self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.declineSharePersonal!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
        self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        self.declineSharePersonal!.addTarget(self, action: "changeCons:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.saveButton = UIButton()
        self.saveButton!.setImage(iconImage, forState: UIControlState.Normal)
        self.saveButton!.setImage(iconSelected, forState: UIControlState.Highlighted)
        self.saveButton!.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton?.tintColor = WMColor.navigationFilterTextColor
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.saveButton?.titleLabel!.textColor = WMColor.navigationFilterTextColor
        self.saveButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, -iconImage!.size.width, 0, 0.0);
        self.saveButton!.imageEdgeInsets = UIEdgeInsetsMake(0, (77 - iconImage!.size.width) / 2 , 0.0, 0.0)
        self.saveButton!.hidden = true
        self.saveButton!.tag = 0
        self.header?.addSubview(self.saveButton!)

        
        
        self.view.addSubview(lblTitle)
        self.view.addSubview(promoAccept!)
        self.view.addSubview(contentTerms!)
        self.view.addSubview(lblPersonalData)
        self.view.addSubview(acceptSharePersonal!)
        self.view.addSubview(declineSharePersonal!)
        self.view.addSubview(registryButton!)
        
        
        
        
    }

    
    
    
    
    func save(sender:UIButton) {
        
        let service = UpdateUserProfileService()
       
        
        if let user = UserCurrentSession.sharedInstance().userSigned {
            let name = user.profile.name
            let mail = user.email
            let lastMame = user.profile.lastName
            let birthDate = user.profile.birthDate
            let gender = user.profile.sex
            
            
            let params  = service.buildParamsWithMembership(mail, password: "", newPassword: "", name: name, lastName: lastMame,birthdate:birthDate,gender:gender)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
            
            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.navigationController!.popViewControllerAnimated(true)
                }
                , {(error: NSError) in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
            
        }
    }

    
}