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
    
    var saveButton: WMRoundButton?
    var changePasswordButton: UIButton?
    var legalInformation: UIButton?
    
    var dateFmt: NSDateFormatter?
    var parseFmt: NSDateFormatter?
    var delegate: EditProfileViewControllerDelegate!
    
    var maleButton: UIButton?
    var femaleButton: UIButton?
    
    var dateSelected : NSDate!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_EDITPROFILE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel!.text = NSLocalizedString("profile.title", comment: "")
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setValues", name: ProfileNotification.updateProfile.rawValue, object: nil)
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_EDITPROFILE.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"

        self.parseFmt = NSDateFormatter()
        self.parseFmt!.dateFormat = "dd/MM/yyyy"

        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self

        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.typeField = TypeField.Name
        self.name!.minLength = 2
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.typeField = TypeField.String
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.typeField = TypeField.Email
        self.email!.maxLength = 45
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.enabled = false

        self.birthDate = FormFieldView()
        self.birthDate!.isRequired = true
        self.birthDate!.setCustomPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
        self.birthDate!.typeField = .None
        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")
        self.birthDate!.disablePaste = true
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                self.dateChanged()
                field?.resignFirstResponder()
            }
        })
        
        
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let currentDate = NSDate()
        let comps = NSDateComponents()
        comps.year = -18
        let maxDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions())
        comps.year = -100
        let minDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions())
        
        self.inputBirthdateView = UIDatePicker()
        self.inputBirthdateView!.datePickerMode = .Date
        self.inputBirthdateView!.date = NSDate()
        self.inputBirthdateView!.maximumDate = maxDate
        self.inputBirthdateView!.minimumDate = minDate

        self.inputBirthdateView!.addTarget(self, action: "dateChanged", forControlEvents: .ValueChanged)
        self.birthDate!.inputView = self.inputBirthdateView!
        self.birthDate!.inputAccessoryView = viewAccess
        self.dateChanged()
        
        
        //boton hombre
        self.maleButton = UIButton()
        self.maleButton?.setTitle(NSLocalizedString("signup.male", comment: ""), forState: UIControlState.Normal)
        self.maleButton!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.maleButton!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        self.maleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.maleButton!.setTitleColor(WMColor.regular_gray, forState: UIControlState.Normal)
        self.maleButton?.addTarget(self, action: "changeMF:", forControlEvents: UIControlEvents.TouchUpInside)
        self.maleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.maleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        
        self.femaleButton = UIButton()
        self.femaleButton?.setTitle(NSLocalizedString("signup.female", comment: ""), forState: UIControlState.Normal)
        self.femaleButton!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.femaleButton!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        self.femaleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.femaleButton?.addTarget(self, action: "changeMF:", forControlEvents: UIControlEvents.TouchUpInside)
        self.femaleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.femaleButton!.setTitleColor(WMColor.regular_gray, forState: UIControlState.Normal)
        self.femaleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    

        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attrString = NSMutableAttributedString(string: NSLocalizedString("profile.terms", comment: ""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.saveButton = WMRoundButton()
        self.saveButton!.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton?.tintColor = WMColor.navigationFilterTextColor
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.saveButton?.titleLabel!.textColor = WMColor.navigationFilterTextColor
        self.saveButton?.setBackgroundColor(WMColor.UIColorFromRGB(0x8EBB36), size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.saveButton!.hidden = true
        self.saveButton!.tag = 0
        self.header?.addSubview(self.saveButton!)
        
        changePasswordButton = UIButton()
        changePasswordButton!.setTitle(NSLocalizedString("profile.change.password", comment: ""), forState: UIControlState.Normal)
        changePasswordButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        changePasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.changePasswordButton!.backgroundColor = WMColor.loginProfileSaveBGColor
        changePasswordButton!.layer.cornerRadius = 20.0
        changePasswordButton?.addTarget(self, action: "changePassword", forControlEvents: .TouchUpInside)
        
        
        legalInformation = UIButton()
        legalInformation!.setTitle(NSLocalizedString("profile.change.legalinfo", comment: ""), forState: UIControlState.Normal)
        legalInformation!.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        legalInformation!.addTarget(self, action: "infolegal", forControlEvents: .TouchUpInside)
        legalInformation!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.content.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.content)
        self.content?.addSubview(self.name!)
        self.content?.addSubview(self.lastName!)
        self.content?.addSubview(self.email!)
        //self.content?.addSubview(self.birthDate!)
        self.content?.addSubview(self.birthDate!)
        self.content?.addSubview(self.maleButton!)
        self.content?.addSubview(self.femaleButton!)
        self.content?.addSubview(self.changePasswordButton!)
        self.content?.addSubview(self.legalInformation!)
        
        self.content.clipsToBounds = false
        self.view.bringSubviewToFront(self.header!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setValues()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        self.saveButton!.frame = CGRectMake( self.view.bounds.maxX - 87, 0 , 71, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(80 , 0, self.view.bounds.width - 160, self.header!.frame.maxY)
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - self.header!.frame.height )
        
        let topSpace: CGFloat = 8.0
        let horSpace: CGFloat = 15.0
        let fieldWidth = self.view.bounds.width - (horSpace*2)
        let fieldHeight: CGFloat = 40.0
        self.name?.frame = CGRectMake(horSpace,  topSpace, fieldWidth, fieldHeight)
        self.lastName?.frame = CGRectMake(horSpace,  self.name!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.email?.frame = CGRectMake(horSpace, self.lastName!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.birthDate?.frame = CGRectMake(horSpace,  self.email!.frame.maxY + 8, self.view.bounds.width - (horSpace*2), fieldHeight)
        self.femaleButton!.frame = CGRectMake(84,  birthDate!.frame.maxY + 8,  76 , fieldHeight)
        self.maleButton!.frame = CGRectMake(self.femaleButton!.frame.maxX,  birthDate!.frame.maxY + 8, 76 , fieldHeight)
        
        //self.birthDate?.frame = CGRectMake(horSpace, self.email!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.changePasswordButton?.frame = CGRectMake(horSpace,  self.femaleButton!.frame.maxY + topSpace,  fieldWidth, fieldHeight)
        self.legalInformation!.frame = CGRectMake(horSpace,  self.changePasswordButton!.frame.maxY + 8,  fieldWidth, 20)
        
        self.content.contentSize = CGSize(width: bounds.width, height:  self.changePasswordButton!.frame.maxY + 40)
    }
    
    //MARK: - Actions
    
    func setValues() {
        if let user = UserCurrentSession.sharedInstance().userSigned {
            self.name!.text = user.profile.name as String
            self.email!.text = user.email as String
            self.lastName!.text = user.profile.lastName as String
            if let date = self.parseFmt!.dateFromString(user.profile.birthDate as String) {
                self.birthDate!.text = self.dateFmt!.stringFromDate(date)
                self.dateSelected = date
                self.inputBirthdateView!.date = date
                if user.profile.sex == "Female" {
                    self.femaleButton!.selected = true
                    self.maleButton!.selected = false
                } else {
                    self.maleButton!.selected = true
                    self.femaleButton!.selected = false
                }
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
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_OPEN_FORM_CHANGE_PASSWORD.rawValue , label:"")
        let changePassword = ChangePasswordViewController()
        self.navigationController!.pushViewController(changePassword, animated: true)
    }
    
    func dateChanged() {
        let date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.stringFromDate(date)
        self.dateSelected = date
        if self.saveButton != nil {
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label: "")
            let service = UpdateUserProfileService()
            let passCurrent = (self.passworCurrent==nil ? "" : self.passworCurrent!.text)
            let passNew = (self.password==nil ? "" : self.password!.text)
            
            let dateSlectedStr = self.parseFmt!.stringFromDate(self.dateSelected)
            let gender = self.femaleButton!.selected ? "Female" : "Male"
           
            UserCurrentSession.sharedInstance().userSigned!.profile.birthDate = dateSlectedStr
            UserCurrentSession.sharedInstance().userSigned!.profile.sex = gender
            
            let allowMarketing =  UserCurrentSession.sharedInstance().userSigned?.profile.allowMarketingEmail
            let allowTransfer = UserCurrentSession.sharedInstance().userSigned?.profile.allowTransfer
            
            let params  = service.buildParamsWithMembership(self.email!.text!, password: passCurrent!, newPassword:passNew!, name: self.name!.text!, lastName: self.lastName!.text!,birthdate:dateSlectedStr,gender:gender,allowTransfer:allowTransfer! as String,allowMarketingEmail:allowMarketing! as String)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
           
            
            if self.passworCurrent != nil{
                // Evente change password
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action: WMGAIUtils.ACTION_CHANGE_PASSWORD.rawValue, label: "")
                
            }
            
            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.saveButton!.hidden = true
                
                if self.delegate == nil {
                    self.navigationController!.popViewControllerAnimated(true)
                }
                else{
                    
                    if self.passworCurrent != nil{
                        self.content?.addSubview(self.changePasswordButton!)
                        self.passworCurrent!.removeFromSuperview()
                        self.password!.removeFromSuperview()
                        self.confirmPassword!.removeFromSuperview()
                    }
                    self.delegate.finishSave()
                }
                }
                , errorBlock: {(error: NSError) in
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
            
            if self.passworCurrent!.text!.characters.count > 0 ||
                self.password!.text!.characters.count > 0 ||
                self.confirmPassword!.text!.characters.count > 0 {
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
        let message = field.validate()
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
    
    
    func changeMF(sender:UIButton) {
        if sender == self.maleButton {
            self.maleButton?.selected = true
            self.femaleButton?.selected = false
        } else if sender == self.femaleButton  {
            self.maleButton?.selected = false
            self.femaleButton?.selected = true
        }
        self.saveButton!.hidden = false
        UIView.animateWithDuration(0.4, animations: {
            self.saveButton!.alpha = 1.0
            }, completion: {(bool : Bool) in
                if bool {
                    self.saveButton!.alpha = 1.0
                }
        })
    
    }

    func infolegal() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_OPEN_LEGAL_INFORMATION.rawValue , label:"")
        let changeInfoLegal = ChangeInfoLegalViewController()
        self.navigationController!.pushViewController(changeInfoLegal, animated: true)

    }
    
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
    
}
