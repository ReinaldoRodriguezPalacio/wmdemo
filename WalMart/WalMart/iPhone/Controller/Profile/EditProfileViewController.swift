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
    
    var dateFmt: DateFormatter?
    var parseFmt: DateFormatter?
    var delegate: EditProfileViewControllerDelegate!
    
    var maleButton: UIButton?
    var femaleButton: UIButton?
    
    var dateSelected : Date!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_EDITPROFILE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel!.text = NSLocalizedString("profile.title", comment: "")
        
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.setValues), name: NSNotification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
        
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"

        self.parseFmt = DateFormatter()
        self.parseFmt!.dateFormat = "dd/MM/yyyy"

        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self

        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.typeField = TypeField.name
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.typeField = TypeField.string
        self.lastName!.minLength = 3
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.emailAddress
        self.email!.typeField = TypeField.email
        self.email!.maxLength = 45
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.isEnabled = false

        self.birthDate = FormFieldView()
        self.birthDate!.isRequired = true
        self.birthDate!.setCustomPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
        self.birthDate!.typeField = .none
        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")
        self.birthDate!.disablePaste = true
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                self.dateChanged()
                field?.resignFirstResponder()
            }
        })
        
        
        let calendar = Calendar(identifier: NSGregorianCalendar)
        let currentDate = Date()
        var comps = DateComponents()
        comps.year = -18
        let maxDate = (calendar! as NSCalendar).date(byAdding: comps, to: currentDate, options: NSCalendar.Options())
        comps.year = -100
        let minDate = (calendar! as NSCalendar).date(byAdding: comps, to: currentDate, options: NSCalendar.Options())
        
        self.inputBirthdateView = UIDatePicker()
        self.inputBirthdateView!.datePickerMode = .date
        self.inputBirthdateView!.date = Date()
        self.inputBirthdateView!.maximumDate = maxDate
        self.inputBirthdateView!.minimumDate = minDate

        self.inputBirthdateView!.addTarget(self, action: #selector(EditProfileViewController.dateChanged), for: .valueChanged)
        self.birthDate!.inputView = self.inputBirthdateView!
        self.birthDate!.inputAccessoryView = viewAccess
        self.dateChanged()
        
        
        self.maleButton = UIButton()
        self.maleButton?.setTitle(NSLocalizedString("signup.male", comment: ""), for: UIControlState())
        self.maleButton!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.maleButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.maleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.maleButton!.setTitleColor(WMColor.gray, for: UIControlState())
        self.maleButton?.addTarget(self, action: #selector(EditProfileViewController.changeMF(_:)), for: UIControlEvents.touchUpInside)
        self.maleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.maleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        
        self.femaleButton = UIButton()
        self.femaleButton?.setTitle(NSLocalizedString("signup.female", comment: ""), for: UIControlState())
        self.femaleButton!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.femaleButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.femaleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.femaleButton?.addTarget(self, action: #selector(EditProfileViewController.changeMF(_:)), for: UIControlEvents.touchUpInside)
        self.femaleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.femaleButton!.setTitleColor(WMColor.gray, for: UIControlState())
        self.femaleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    

        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attrString = NSMutableAttributedString(string: NSLocalizedString("profile.terms", comment: ""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.saveButton = WMRoundButton()
        self.saveButton!.addTarget(self, action: #selector(EditProfileViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , for: UIControlState())
        self.saveButton?.tintColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.saveButton?.titleLabel!.textColor = UIColor.white
        self.saveButton?.setBackgroundColor(WMColor.green, size: CGSize(width: 71, height: 22), forUIControlState: UIControlState())
        self.saveButton!.isHidden = true
        self.saveButton!.tag = 0
        self.header?.addSubview(self.saveButton!)
        
        changePasswordButton = UIButton()
        changePasswordButton!.setTitle(NSLocalizedString("profile.change.password", comment: ""), for: UIControlState())
        changePasswordButton!.setTitleColor(UIColor.white, for: UIControlState())
        changePasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.changePasswordButton!.backgroundColor = WMColor.light_blue
        changePasswordButton!.layer.cornerRadius = 20.0
        changePasswordButton?.addTarget(self, action: #selector(EditProfileViewController.changePassword), for: .touchUpInside)
        
        
        legalInformation = UIButton()
        legalInformation!.setTitle(NSLocalizedString("profile.change.legalinfo", comment: ""), for: UIControlState())
        legalInformation!.setTitleColor(WMColor.light_blue, for: UIControlState())
        legalInformation!.addTarget(self, action: #selector(EditProfileViewController.infolegal), for: .touchUpInside)
        legalInformation!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.content.backgroundColor = UIColor.white
        
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
        self.view.bringSubview(toFront: self.header!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setValues()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        self.saveButton!.frame = CGRect( x: self.view.bounds.maxX - 87, y: 0 , width: 71, height: self.header!.frame.height)
        self.titleLabel!.frame = CGRect(x: 80 , y: 0, width: self.view.bounds.width - 160, height: self.header!.frame.maxY)
        self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY , width: self.view.bounds.width , height: self.view.bounds.height - self.header!.frame.height )
        
        let topSpace: CGFloat = 8.0
        let horSpace: CGFloat = 15.0
        let fieldWidth = self.view.bounds.width - (horSpace*2)
        let fieldHeight: CGFloat = 40.0
        self.name?.frame = CGRect(x: horSpace,  y: topSpace, width: fieldWidth, height: fieldHeight)
        self.lastName?.frame = CGRect(x: horSpace,  y: self.name!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.email?.frame = CGRect(x: horSpace, y: self.lastName!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.birthDate?.frame = CGRect(x: horSpace,  y: self.email!.frame.maxY + 8, width: self.view.bounds.width - (horSpace*2), height: fieldHeight)
        self.femaleButton!.frame = CGRect(x: 90,  y: birthDate!.frame.maxY + 8,  width: 76 , height: fieldHeight)
        self.maleButton!.frame = CGRect(x: self.femaleButton!.frame.maxX,  y: birthDate!.frame.maxY + 8, width: 76 , height: fieldHeight)
        let distance: CGFloat = IS_IPHONE_4_OR_LESS ? 10 : 74
        //self.birthDate?.frame = CGRectMake(horSpace, self.email!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.changePasswordButton?.frame = CGRect(x: horSpace,  y: self.femaleButton!.frame.maxY + topSpace,  width: fieldWidth, height: fieldHeight)
        self.legalInformation!.frame = CGRect(x: horSpace,  y: self.changePasswordButton!.frame.maxY + distance,  width: fieldWidth, height: 30)
        
        self.content.contentSize = CGSize(width: bounds.width, height:  self.changePasswordButton!.frame.maxY + 40)
    }
    
    //MARK: - Actions
    
    func setValues() {
        if let user = UserCurrentSession.sharedInstance().userSigned {
            self.name!.text = user.profile.name as String
            self.email!.text = user.email as String
            self.lastName!.text = user.profile.lastName as String
            if let date = self.parseFmt!.date(from: user.profile.birthDate as String) {
                self.birthDate!.text = self.dateFmt!.string(from: date)
                self.dateSelected = date
                self.inputBirthdateView!.date = date
                if user.profile.sex == "Female" {
                    self.femaleButton!.isSelected = true
                    self.maleButton!.isSelected = false
                } else {
                    self.maleButton!.isSelected = true
                    self.femaleButton!.isSelected = false
                }
            }
        }
    }
    
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = !(sender.isSelected)
    }
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
          return CGSize(width: self.view.frame.width, height: content.contentSize.height)
    }
    
    func changePassword() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_OPEN_FORM_CHANGE_PASSWORD.rawValue , label:"")
        let changePassword = ChangePasswordViewController()
        self.navigationController!.pushViewController(changePassword, animated: true)
    }
    
    func dateChanged() {
        let date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.string(from: date)
        self.dateSelected = date
        if self.saveButton != nil {
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
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField!) {
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
                self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY  , width: self.view.bounds.width , height: self.view.bounds.height - self.header!.frame.height )
            }
        }
    }
    
    func textModify(_ textField: UITextField!) {
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

    func save(_ sender:UIButton) {
        if validateUser() {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label: "")
            let service = UpdateUserProfileService()
            let passCurrent = (self.passworCurrent==nil ? "" : self.passworCurrent!.text)
            let passNew = (self.password==nil ? "" : self.password!.text)
            
            let dateSlectedStr = self.parseFmt!.string(from: self.dateSelected)
            let gender = self.femaleButton!.isSelected ? "Female" : "Male"
           
            UserCurrentSession.sharedInstance().userSigned!.profile.birthDate = dateSlectedStr as NSString
            UserCurrentSession.sharedInstance().userSigned!.profile.sex = gender as NSString
            
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
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action: WMGAIUtils.ACTION_CHANGE_PASSWORD.rawValue, label: "")
                
            }
            
            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:[String:Any]?) in
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.saveButton!.isHidden = true
                
                if self.delegate == nil {
                    self.navigationController!.popViewController(animated: true)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "RELOAD_PROFILE"), object: nil)
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
                    //self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.setMessage(NSLocalizedString("conection.error", comment: ""))
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
    
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil{
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField , message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            
            if field == self.name {
                self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY + 25 , width: self.view.bounds.width , height: self.view.bounds.height - self.header!.frame.height )
            }
            return true
        }
        field.resignFirstResponder()
        return false
    }
    
    
    func changeMF(_ sender:UIButton) {
        if sender == self.maleButton {
            self.maleButton?.isSelected = true
            self.femaleButton?.isSelected = false
        } else if sender == self.femaleButton  {
            self.maleButton?.isSelected = false
            self.femaleButton?.isSelected = true
        }
        self.saveButton!.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.saveButton!.alpha = 1.0
            }, completion: {(bool : Bool) in
                if bool {
                    self.saveButton!.alpha = 1.0
                }
        })
    
    }

    func infolegal() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_OPEN_LEGAL_INFORMATION.rawValue , label:"")
        let changeInfoLegal = ChangeInfoLegalViewController()
        self.navigationController!.pushViewController(changeInfoLegal, animated: true)

    }
    
    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
    
}
