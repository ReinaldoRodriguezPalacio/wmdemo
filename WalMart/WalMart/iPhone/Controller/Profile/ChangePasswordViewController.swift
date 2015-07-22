//
//  ChangePasswordViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ChangePasswordViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate {
    
    var content: TPKeyboardAvoidingScrollView!
    
    var passworCurrent: FormFieldView?
    var password: FormFieldView?
    var confirmPassword: FormFieldView?
    
    var errorView: FormFieldErrorView?
    var alertView: IPOWMAlertViewController?
    
    var saveButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.titleLabel!.text = NSLocalizedString("profile.change.password", comment: "")
        
        
        self.content = TPKeyboardAvoidingScrollView()
        //self.content.delegate = self
        self.content.scrollDelegate = self
        
        
        self.passworCurrent = FormFieldView()
        self.passworCurrent!.setPlaceholder(NSLocalizedString("profile.password.current",comment:""))
        self.passworCurrent!.secureTextEntry = true
        self.passworCurrent!.isRequired = true
        self.passworCurrent!.typeField = TypeField.None
        self.passworCurrent!.nameField = NSLocalizedString("profile.password.current",comment:"")
        
        self.password = FormFieldView()
        self.password!.setPlaceholder(NSLocalizedString("profile.password",comment:""))
        self.password!.secureTextEntry = true
        self.password!.isRequired = true
        self.password!.typeField = TypeField.Password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.minLength = 8
        self.password!.maxLength = 16
        
        self.confirmPassword = FormFieldView()
        self.confirmPassword!.setPlaceholder(NSLocalizedString("profile.confirmpassword",comment:""))
        self.confirmPassword!.secureTextEntry = true
        self.confirmPassword!.isRequired = true
        self.confirmPassword!.typeField = TypeField.Password
        self.confirmPassword!.nameField = NSLocalizedString("profile.confirmpassword",comment:"")
        self.confirmPassword!.minLength = 8
        self.confirmPassword!.maxLength = 16
        
        self.content?.addSubview(passworCurrent!)
        self.content?.addSubview(password!)
        self.content?.addSubview(confirmPassword!)
        
        let fieldHeight  : CGFloat = CGFloat(40)
        let leftRightPadding  : CGFloat = CGFloat(15)
        
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        let iconImage = UIImage(named:"button_bg")
        let iconSelected = UIImage(named:"button_bg_active")
        
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

        
        
        self.passworCurrent?.frame = CGRectMake(leftRightPadding,  self.header!.frame.maxY + 8,  self.view.frame.width - (leftRightPadding * 2), fieldHeight)
        self.password?.frame = CGRectMake(leftRightPadding,  passworCurrent!.frame.maxY + 8, self.view.frame.width - (leftRightPadding * 2), fieldHeight)
        self.confirmPassword?.frame = CGRectMake(leftRightPadding,  password!.frame.maxY + 8,  self.view.frame.width - (leftRightPadding * 2), fieldHeight)
        
        self.content.contentSize = CGSize(width: self.view.bounds.width, height:  self.confirmPassword!.frame.maxY + 40)
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
        
        self.saveButton!.frame = CGRectMake( self.view.bounds.maxX - 87, 0 , 87, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(80 , 0, self.view.bounds.width - 160, self.header!.frame.maxY)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func textFieldDidEndEditing(textField: UITextField!) {
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
                self.content.frame = CGRectMake(0, self.header!.frame.maxY  , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
            }
        }
    }
    
    func textModify(textField: UITextField!) {
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
    
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.view.frame.width, content.contentSize.height)
    }
    
    //MARK: Save action
    
    func save(sender:UIButton) {
        
        let service = UpdateUserProfileService()
        var passCurrent = (self.passworCurrent==nil ? "" : self.passworCurrent!.text) as String
        var passNew = (self.password==nil ? "" : self.password!.text) as String
        
        
        if let user = UserCurrentSession.sharedInstance().userSigned {
            let name = user.profile.name
            let mail = user.email
            let lastMame = user.profile.lastName
            let birthDate = user.profile.birthDate
            let gender = user.profile.sex
            
            
            
            let allowMarketing =  UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail
            let allowTransfer = UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer
            
            let params  = service.buildParamsWithMembership(mail, password: passCurrent, newPassword:passNew, name: name, lastName: lastMame,birthdate:birthDate,gender:gender,allowTransfer:allowTransfer!,allowMarketingEmail:allowMarketing!)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
            
            
            if self.passworCurrent != nil{
                // Evente change password
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_EDITPROFILE.rawValue,
                        action:WMGAIUtils.EVENT_PROFILE_CHANGEPASSWORD.rawValue,
                        label: nil,
                        value: nil).build())
                }
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
