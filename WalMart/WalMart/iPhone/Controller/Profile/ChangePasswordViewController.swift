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
    
    var saveButton: WMRoundButton?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHANGEPASSWORD.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel!.text = NSLocalizedString("profile.change.password", comment: "")
        
        self.content = TPKeyboardAvoidingScrollView()
        //self.content.delegate = self
        self.content.scrollDelegate = self
        
        
        self.passworCurrent = FormFieldView()
        self.passworCurrent!.isRequired = true
        self.passworCurrent!.setCustomPlaceholder(NSLocalizedString("profile.password.current",comment:""))
        self.passworCurrent!.secureTextEntry = true
        self.passworCurrent!.typeField = TypeField.Password
        self.passworCurrent!.nameField = NSLocalizedString("profile.password.current",comment:"")
        
        self.password = FormFieldView()
        self.password!.isRequired = true
        self.password!.setCustomPlaceholder(NSLocalizedString("profile.password",comment:""))
        self.password!.secureTextEntry = true
        self.password!.typeField = TypeField.Password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.minLength = 8
        self.password!.maxLength = 20
        
        self.confirmPassword = FormFieldView()
        self.confirmPassword!.isRequired = true
        self.confirmPassword!.setCustomPlaceholder(NSLocalizedString("profile.confirmpassword",comment:""))
        self.confirmPassword!.secureTextEntry = true
        self.confirmPassword!.typeField = TypeField.Password
        self.confirmPassword!.nameField = NSLocalizedString("profile.confirmpassword",comment:"")
        self.confirmPassword!.minLength = 8
        self.confirmPassword!.maxLength = 20
        
        self.content?.addSubview(passworCurrent!)
        self.content?.addSubview(password!)
        self.content?.addSubview(confirmPassword!)
       
        
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        self.saveButton = WMRoundButton()
        //self.saveButton!.setImage(iconImage, forState: UIControlState.Normal)
        //self.saveButton!.setImage(iconSelected, forState: UIControlState.Highlighted)
        self.saveButton!.setBackgroundColor(WMColor.green, size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.saveButton!.addTarget(self, action: #selector(ChangePasswordViewController.save(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton!.tintColor = UIColor.whiteColor()
        self.saveButton!.layer.cornerRadius = 11
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.saveButton?.titleLabel!.textColor = UIColor.whiteColor()

        self.saveButton!.hidden = true
        self.saveButton!.tag = 0

        self.header?.addSubview(self.saveButton!)
        
        
        
        
        
        self.content.contentSize = CGSize(width: self.view.bounds.width, height:  self.confirmPassword!.frame.maxY + 40)
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let fieldHeight  : CGFloat = CGFloat(40)
        let leftRightPadding  : CGFloat = CGFloat(15)
        
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
        
        self.saveButton!.frame = CGRectMake( self.view.bounds.maxX - 87, 0 , 71, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(80 , 0, self.view.bounds.width - 160, self.header!.frame.maxY)
        
        self.passworCurrent?.frame = CGRectMake(leftRightPadding, 32,  self.view.frame.width - (leftRightPadding * 2), fieldHeight)
        self.password?.frame = CGRectMake(leftRightPadding,  passworCurrent!.frame.maxY + 8, self.view.frame.width - (leftRightPadding * 2), fieldHeight)
        self.confirmPassword?.frame = CGRectMake(leftRightPadding,  password!.frame.maxY + 8,  self.view.frame.width - (leftRightPadding * 2), fieldHeight)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func textFieldDidEndEditing(textField: UITextField!) {
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
                self.content.frame = CGRectMake(0, self.header!.frame.maxY  , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height)
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
    
    func validateChangePassword() -> Bool{
        var field = FormFieldView()
        var message = ""
        let confirmPasswordMessage = confirmPassword!.validate()
        if !confirmPassword!.isValid
        {
            field = confirmPassword!
            message = confirmPasswordMessage!
        }
        let passwordMessage = password!.validate()
        if !password!.isValid
        {
            field = password!
            message = passwordMessage!
        }
        let passworCurrentMessage = passworCurrent!.validate()
        if !passworCurrent!.isValid
        {
            field = passworCurrent!
            message = passworCurrentMessage!
        }
        if password!.text != confirmPassword!.text{
            field = confirmPassword!
            message = NSLocalizedString("field.validate.confirmpassword.equal", comment: "")
        }
        if message.characters.count > 0 {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField ,  message: message ,errorView:self.errorView!,  becomeFirstResponder: true )
            return false
        }
        return true
    }
    
    //MARK: Save action
    
    func save(sender:UIButton) {
        
        if !validateChangePassword(){
            return
        }
        
        let service = UpdateUserProfileService()
        let passCurrent = (self.passworCurrent==nil ? "" : self.passworCurrent!.text!) as String
        let passNew = (self.password==nil ? "" : self.password!.text!) as String
        
        
        if let user = UserCurrentSession.sharedInstance().userSigned {
            let name = user.profile.name
            let mail = user.email
            let lastMame = user.profile.lastName
            let birthDate = user.profile.birthDate
            let gender = user.profile.sex
            
            
            
            let allowMarketing =  UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail
            let allowTransfer = UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer
            
            let params  = service.buildParamsWithMembership(mail as String, password: passCurrent, newPassword:passNew, name: name as String, lastName: lastMame as String,birthdate:birthDate as String,gender:gender as String,allowTransfer:allowTransfer! as String,allowMarketingEmail:allowMarketing! as String)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
            

            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue , label:"SUCCES")
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.navigationController!.popViewControllerAnimated(true)
                }
                , errorBlock: {(error: NSError) in
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue , label:"FAILED")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
            
        }
    }
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action:WMGAIUtils.ACTION_BACK_TO_EDIT_PROFILE.rawValue , label:"SUCCES")
        super.back()
    }
    
}
