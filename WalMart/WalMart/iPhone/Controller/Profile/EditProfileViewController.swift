//
//  EditProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 22/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol EditProfileViewControllerDelegate {
    func finishSave()
}


class EditProfileViewController: NavigationViewController,  UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate  {

    var content: TPKeyboardAvoidingScrollView!
    var name: FormFieldView!
    var lastName: FormFieldView!
    var email: FormFieldView!
    var birthDate: FormFieldView!
    var inputBirthdateView: UIDatePicker?
    
    var passworCurrent: FormFieldView?
    var password: FormFieldView?
    var confirmPassword: FormFieldView?
    var errorView: FormFieldErrorView?
    var alertView: IPOWMAlertViewController?
    
    var saveButton: UIButton?
    var changePasswordButton: UIButton?
    
    var dateFmt: NSDateFormatter?
    var parseFmt: NSDateFormatter?
    var delegate: EditProfileViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel!.text = NSLocalizedString("profile.title", comment: "")
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setValues", name: ProfileNotification.updateProfile.rawValue, object: nil)
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_EDITPROFILE.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"

        self.parseFmt = NSDateFormatter()
        self.parseFmt!.dateFormat = "dd/MM/yyyy"

        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self

        self.name = FormFieldView()
        self.name!.setPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.isRequired = true
        self.name!.typeField = TypeField.Name
        self.name!.minLength = 2
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        
        self.lastName = FormFieldView()
        self.lastName!.setPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.isRequired = true
        self.lastName!.typeField = TypeField.String
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
        
        self.email = FormFieldView()
        self.email!.setPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.isRequired = true
        self.email!.typeField = TypeField.Email
        self.email!.maxLength = 45
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.enabled = false

        self.birthDate = FormFieldView()
        self.birthDate!.setPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
        self.birthDate!.keyboardType = UIKeyboardType.EmailAddress
        self.birthDate!.typeField = .String
        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")

        self.inputBirthdateView = UIDatePicker()
        self.inputBirthdateView!.datePickerMode = .Date
        self.inputBirthdateView!.date = NSDate()
        self.inputBirthdateView!.maximumDate = NSDate()
        self.inputBirthdateView!.addTarget(self, action: "dateChanged", forControlEvents: .ValueChanged)
        //self.birthDate!.inputView = self.inputBirthdateView!
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.bounds.width, 44.0), inputViewStyle: .Keyboard, titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil && field!.isFirstResponder() {
                field!.resignFirstResponder()
            }
        })
        //self.birthDate!.inputAccessoryView = viewAccess

        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        var attrString = NSMutableAttributedString(string: NSLocalizedString("profile.terms", comment: ""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
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
        
        changePasswordButton = UIButton()
        changePasswordButton!.setTitle(NSLocalizedString("profile.change.password", comment: ""), forState: UIControlState.Normal)
        changePasswordButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        changePasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.changePasswordButton!.backgroundColor = WMColor.loginProfileSaveBGColor
        changePasswordButton!.layer.cornerRadius = 4.0
        changePasswordButton?.addTarget(self, action: "changePassword", forControlEvents: .TouchUpInside)
        
        self.content.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.content)
        self.content?.addSubview(self.name!)
        self.content?.addSubview(self.lastName!)
        self.content?.addSubview(self.email!)
        //self.content?.addSubview(self.birthDate!)
        self.content?.addSubview(self.changePasswordButton!)
        self.content.clipsToBounds = false
        self.view.bringSubviewToFront(self.header!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setValues()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.bounds
        self.saveButton!.frame = CGRectMake( self.view.bounds.maxX - 87, 0 , 87, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(80 , 0, self.view.bounds.width - 160, self.header!.frame.maxY)
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
        
        let topSpace: CGFloat = 8.0
        let horSpace: CGFloat = 15.0
        var fieldWidth = self.view.bounds.width - (horSpace*2)
        let fieldHeight: CGFloat = 40.0
        self.name?.frame = CGRectMake(horSpace,  topSpace, fieldWidth, fieldHeight)
        self.lastName?.frame = CGRectMake(horSpace,  self.name!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.email?.frame = CGRectMake(horSpace, self.lastName!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        //self.birthDate?.frame = CGRectMake(horSpace, self.email!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.changePasswordButton?.frame = CGRectMake(horSpace,  self.email!.frame.maxY + topSpace,  fieldWidth, fieldHeight)
        
        self.content.contentSize = CGSize(width: bounds.width, height:  self.changePasswordButton!.frame.maxY + 40)
    }
    
    //MARK: - Actions
    
    func setValues() {
        if let user = UserCurrentSession.sharedInstance().userSigned {
            self.name!.text = user.profile.name
            self.email!.text = user.email
            self.lastName!.text = user.profile.lastName
            if let date = self.parseFmt!.dateFromString(user.profile.birthDate) {
                self.birthDate!.text = self.dateFmt!.stringFromDate(date)
                self.inputBirthdateView!.date = date
            }
        }
    }
    
    func checkSelected(sender:UIButton) {
        sender.selected = !(sender.selected)
    }
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
          return CGSizeMake(self.view.frame.width, content.contentSize.height)
    }
    
    func changePassword() {
        self.changePasswordButton!.removeFromSuperview()
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

        self.passworCurrent?.frame = CGRectMake(leftRightPadding,  self.email!.frame.maxY + 8,  self.email!.frame.width, fieldHeight)
        self.password?.frame = CGRectMake(leftRightPadding,  passworCurrent!.frame.maxY + 8,  self.email!.frame.width, fieldHeight)
        self.confirmPassword?.frame = CGRectMake(leftRightPadding,  password!.frame.maxY + 8,  self.email!.frame.width, fieldHeight)
        
        self.content.contentSize = CGSize(width: self.view.bounds.width, height:  self.confirmPassword!.frame.maxY + 40)
        
    }
    
    func dateChanged() {
        var date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.stringFromDate(date)
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

    func save(sender:UIButton) {
        if validateUser() {
            let service = UpdateUserProfileService()
            var passCurrent = (self.passworCurrent==nil ? "" : self.passworCurrent!.text) as String
            var passNew = (self.password==nil ? "" : self.password!.text) as String
            let params  = service.buildParamsWithMembership(self.email!.text, password: passCurrent, newPassword:passNew, name: self.name!.text, lastName: self.lastName!.text)
            
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
                if self.delegate == nil {
                    self.navigationController!.popViewControllerAnimated(true)
                }
                else{
                    self.saveButton!.hidden = true
                    if self.passworCurrent != nil{
                        self.content?.addSubview(self.changePasswordButton!)
                        self.passworCurrent!.removeFromSuperview()
                        self.password!.removeFromSuperview()
                        self.confirmPassword!.removeFromSuperview()
                    }
                    self.delegate.finishSave()
                }
                }
                , {(error: NSError) in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
        }
    }
    
    
    func validateUser() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(lastName!)
        }
        if !error{
            error = viewError(email!)
        }
        
        if self.passworCurrent != nil{
            
            if countElements(self.passworCurrent!.text) > 0 ||
                countElements(self.password!.text) > 0 ||
                countElements(self.confirmPassword!.text) > 0 {
                if !error{
                    error = viewError(passworCurrent!)
                }
                if !error{
                    error = viewError(password!)
                }
                if !error{
                    error = viewError(confirmPassword!)
                }
                if !error{
                    if self.password!.text !=  self.confirmPassword!.text{
                        if self.errorView == nil{
                            self.errorView = FormFieldErrorView()
                        }
                        SignUpViewController.presentMessage(self.confirmPassword!, nameField:self.confirmPassword!.nameField , message: NSLocalizedString("field.validate.confirm.password", comment: ""), errorView:self.errorView!,  becomeFirstResponder: true )
                        error = true
                    }
                }
            }
        }
        if error{
            return false
        }
        return true
    }
    
    func viewError(field: FormFieldView)-> Bool{
        var message = field.validate()
        if message != nil{
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField , message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            
            if field == self.name {
                self.content.frame = CGRectMake(0, self.header!.frame.maxY + 25 , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
            }
            return true
        }
        field.resignFirstResponder()
        return false
    }
    
}
