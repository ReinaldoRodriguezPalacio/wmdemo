//
//  SignUpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class SignUpViewController : BaseController, UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate {
    
    var close: UIButton?
    var content: TPKeyboardAvoidingScrollView!
    var name : FormFieldView? = nil
    var lastName : FormFieldView? = nil
    var email : FormFieldView? = nil
    var password : FormFieldView? = nil
    var confirmPassword : FormFieldView? = nil
    var labelTerms : UILabel? = nil
    var continueButton: UIButton?
    var contentTerms: UIView?
    
    var infoContainer : UIView? = nil
    var acceptTerms : UIButton? = nil
    var promoAccept : UIButton? = nil
    var acceptSharePersonal : UIButton? = nil
    var declineSharePersonal : UIButton? = nil
    var registryButton: UIButton?
    var backButton : UIButton? = nil
    
    var successCallBack : (() -> Void)? = nil
    var cancelButton: UIButton? = nil
    var cancelSignUp : (() -> Void)? = nil
    var viewClose : ((_ hidden: Bool ) -> Void)? = nil
    var titleLabel: UILabel? = nil
    var errorView : FormFieldErrorView? = nil
    var previewHelp : PreviewHelpViewController? = nil
    var alertView : IPOWMAlertViewController? = nil
    var alertAddress : GRFormAddressAlertView? = nil
    
    var birthDate : FormFieldView? = nil
    var inputBirthdateView: UIDatePicker?
    var maleButton: UIButton?
    var femaleButton: UIButton?
    
    var dateFmt: DateFormatter?
    
    var dateVal : Date? = nil
    
    var closeModal : (() -> Void)? = nil
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SIGNUP.rawValue
    }

    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.scrollDelegate = self
        self.content.delegate = self
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.typeField = TypeField.name
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        self.name!.minLength = 3
        self.name!.maxLength = 25
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.typeField = TypeField.name
        self.lastName!.minLength = 3
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
       
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.emailAddress
        self.email!.typeField = TypeField.email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.maxLength = 45
        self.email!.autocapitalizationType = UITextAutocapitalizationType.none
        
        self.password = FormFieldView()
        self.password!.isRequired = true
        self.password!.setCustomPlaceholder(NSLocalizedString("profile.password",comment:""))
        self.password!.isSecureTextEntry = true
        self.password!.typeField = TypeField.password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.minLength = 8
        self.password!.maxLength = 20
        
        self.confirmPassword = FormFieldView()
        self.confirmPassword!.isRequired = true
        self.confirmPassword!.setCustomPlaceholder(NSLocalizedString("profile.confirmpassword",comment:""))
        self.confirmPassword!.isSecureTextEntry = true
        self.confirmPassword!.typeField = TypeField.password
        self.confirmPassword!.nameField = NSLocalizedString("profile.confirmpassword",comment:"")
        self.confirmPassword!.minLength = 8
        self.confirmPassword!.maxLength = 20
        
        
//        self.birthDate = FormFieldView()
//        self.birthDate!.isRequired = true
//        self.birthDate!.setCustomPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
//        self.birthDate!.typeField = .None
//        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")
//        self.birthDate!.disablePaste = true
//        
//        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
//            if field != nil {
//                self.dateChanged()
//                field?.resignFirstResponder()
//            }
//        })
//        
//        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
//        let currentDate = NSDate()
//        let comps = NSDateComponents()
//        comps.year = -18
//        let maxDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions())
//        comps.year = -100
//        let minDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions())
//
//        self.inputBirthdateView = UIDatePicker()
//        self.inputBirthdateView!.datePickerMode = .Date
//        self.inputBirthdateView!.date = NSDate()
//        self.inputBirthdateView!.maximumDate = maxDate
//        self.inputBirthdateView!.minimumDate = minDate
//        self.inputBirthdateView!.addTarget(self, action: #selector(SignUpViewController.dateChanged), forControlEvents: .ValueChanged)
//        self.birthDate!.inputView = self.inputBirthdateView!
//        self.birthDate!.inputAccessoryView = viewAccess
////        self.dateChanged()
//        
//        
//        
//        self.maleButton = UIButton()
//        self.maleButton?.setTitle(NSLocalizedString("signup.male", comment: ""), forState: UIControlState.Normal)
//        self.maleButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
//        self.maleButton!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        self.maleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
//        self.maleButton?.addTarget(self, action: #selector(SignUpViewController.changeMF(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        self.maleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//        self.maleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
//        
//        self.femaleButton = UIButton()
//        self.femaleButton?.setTitle(NSLocalizedString("signup.female", comment: ""), forState: UIControlState.Normal)
//        self.femaleButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
//        self.femaleButton!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        self.femaleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
//        self.femaleButton?.addTarget(self, action: #selector(SignUpViewController.changeMF(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        self.femaleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//        self.femaleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        
        self.continueButton = UIButton()
        self.continueButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment: ""), for: UIControlState())
        self.continueButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.continueButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.continueButton!.backgroundColor = WMColor.green
        self.continueButton!.layer.cornerRadius = 20.0
        self.continueButton!.addTarget(self, action: #selector(SignUpViewController.continueToInfo), for: .touchUpInside)
        
        self.content.backgroundColor = UIColor.clear
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("profile.create.an.cancel", comment: ""), for: UIControlState())
        self.cancelButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.dark_blue
        self.cancelButton!.layer.cornerRadius = 20.0
        self.cancelButton!.addTarget(self, action: #selector(SignUpViewController.cancelRegistry(_:)), for: .touchUpInside)
        
        self.titleLabel = UILabel()
        self.titleLabel!.textColor =  UIColor.white
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel!.text = NSLocalizedString("profile.create.an.account", comment: "")
        self.titleLabel!.textAlignment = NSTextAlignment.center
        self.content!.addSubview(self.titleLabel!)
        self.content!.addSubview(self.cancelButton!)

        self.view.addSubview(self.content)
        self.content!.addSubview(name!)
        self.content!.addSubview(lastName!)
        self.content!.addSubview(email!)
        self.content!.addSubview(password!)
        self.content!.addSubview(confirmPassword!)
        self.content!.addSubview(continueButton!)
//        self.content!.addSubview(birthDate!)
//        self.content!.addSubview(maleButton!)
//        self.content!.addSubview(femaleButton!)
        
        self.content.clipsToBounds = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        let fieldHeight  : CGFloat = CGFloat(40)
        let leftRightPadding  : CGFloat = CGFloat(15)
        self.content.frame = CGRect(x: 0, y: 0 , width: self.view.bounds.width , height: self.view.bounds.height)
        self.titleLabel!.frame =  CGRect(x: 0 , y: 0, width: self.content.frame.width , height: 16)
        self.name?.frame = CGRect(x: leftRightPadding,  y: 40, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.lastName?.frame = CGRect(x: leftRightPadding,  y: name!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.email?.frame = CGRect(x: leftRightPadding,  y: lastName!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.password?.frame = CGRect(x: leftRightPadding,  y: email!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.confirmPassword?.frame = CGRect(x: leftRightPadding,  y: password!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
//        self.birthDate?.frame = CGRectMake(leftRightPadding,  confirmPassword!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
//        self.femaleButton!.frame = CGRectMake(84,  birthDate!.frame.maxY + 15,  76 , fieldHeight)
//        self.maleButton!.frame = CGRectMake(self.femaleButton!.frame.maxX,  birthDate!.frame.maxY + 15, 76 , fieldHeight)
        
        self.cancelButton!.frame = CGRect(x: leftRightPadding,  y: confirmPassword!.frame.maxY + 30,  width: (self.email!.frame.width / 2) - 5 , height: fieldHeight)
        self.continueButton!.frame = CGRect(x: self.cancelButton!.frame.maxX + 10 , y: self.cancelButton!.frame.minY ,  width: self.cancelButton!.frame.width, height: fieldHeight)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.continueButton!.frame.maxY + 40)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func  contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
          return CGSize(width: self.view.frame.width, height: content.contentSize.height)
    }
    
    //MARK: - TextFieldDelegate
    func textFieldDidEndEditingSW(_ textField: UITextField!) {
        if errorView != nil{
            if (errorView!.focusError == textField || errorView!.focusError == nil ) &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
            }
        }
    }
    
    func textFieldDidBeginEditingSW(_ textField: UITextView!) {
        if errorView != nil && errorView!.focusError == nil {
            errorView?.removeFromSuperview()
            errorView!.focusError = nil
            errorView = nil
        }
    }
    
    //MARK: - Functions
    /**
     Changes the gender between male and female
     
     - parameter sender: UIButton
     */
    func changeMF(_ sender:UIButton) {
        if sender == self.maleButton {
            self.maleButton?.isSelected = true
            self.femaleButton?.isSelected = false
        } else if sender == self.femaleButton  {
            self.maleButton?.isSelected = false
            self.femaleButton?.isSelected = true
        }
        
    }
    
    /**
     Checks selected buttons
     
     - parameter sender: UIButton
     */
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = !(sender.isSelected)
        if errorView != nil{
            if errorView?.superview != nil {
                errorView?.removeFromSuperview()
            }
            errorView!.focusError = nil
            errorView = nil
        }
    }
    
    /**
     Shows Privacy Notice
     
     - parameter recognizer: UITapGestureRecognizer
     */
    func noticePrivacy(_ recognizer:UITapGestureRecognizer) {
        if errorView != nil{
            if errorView?.superview != nil {
                errorView?.removeFromSuperview()
            }
            errorView!.focusError = nil
            errorView = nil
        }
        self.view.endEditing(true)
        if previewHelp == nil {
            previewHelp = PreviewHelpViewController()
            self.previewHelp!.resource = "privacy"
            self.previewHelp!.type = "pdf"
            self.previewHelp!.view.frame =  CGRect(x: self.name!.frame.minX ,  y: 40, width: self.content!.frame.width - (self.name!.frame.minX * 2) , height: self.content!.frame.height - 60 )
            self.close = UIButton(type: .custom)
            self.close!.setImage(UIImage(named: "termsClose"), for: UIControlState())
            self.close!.addTarget(self, action: #selector(SignUpViewController.closeNoticePrivacy), for: .touchUpInside)
            self.close!.backgroundColor = UIColor.clear
            self.close!.frame = CGRect(x: self.content!.frame.width - 40.0, y: 22, width: 40.0, height: 40.0)
        
        } else {
            self.previewHelp!.loadPreview()
        }
        self.infoContainer!.addSubview(self.previewHelp!.view)
        self.infoContainer!.addSubview(self.close!)
        self.viewClose!(true)
        self.continueButton!.isHidden = true
        self.cancelButton!.isHidden = true
    }
    
    /**
     Closes Privacy Notice
     */
    func closeNoticePrivacy() {
        self.previewHelp!.view.removeFromSuperview()
        self.close!.removeFromSuperview()
        self.viewClose!(false)
        self.continueButton!.isHidden = false
        self.cancelButton!.isHidden = false

    }
    
    /**
     Returns to login view
     
     - parameter sender: UIButton
     */
    func cancelRegistry(_ sender:UIButton) {
        self.cancelSignUp!()
        self.view.endEditing(true)
    }
    
    /**
     Shows info view
     */
    func continueToInfo() {
        self.view.endEditing(true)
        //birthDate!.resignFirstResponder()
        
        if validateUser() {
            let infoView = self.generateInfoView(self.content.frame)
            self.content.alpha = 0
            infoView.alpha = 1
        }
     
    }
    
    /**
     Calls registry user service
     */
    func registryUser() {
        self.view.endEditing(true)
        if validateTerms() {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SIGNUP.rawValue,action: WMGAIUtils.ACTION_SAVE_SIGNUP.rawValue, label: "")
            let service = SignUpService()
//            let dateFmtBD = NSDateFormatter()
//            dateFmtBD.dateFormat = "dd/MM/yyyy"
//            let dateOfBirth = dateFmtBD.stringFromDate(self.dateVal!)
//            let gender = femaleButton!.selected ? "Female" : "Male"
            let allowTransfer = "\(self.acceptSharePersonal!.isSelected)"
            let allowPub = "\(self.promoAccept!.isSelected)"
            let params = service.buildParamsWithMembership(email!.text!, password: password!.text!, name: name!.text!, lastName:  lastName!.text!, allowMarketingEmail: allowPub, allowTransfer: allowTransfer)
            self.view.endEditing(true)
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:[String:Any]?) in
                let login = LoginService()
                login.callService(login.buildParams(self.email!.text!, password: self.password!.text!), successBlock: { (dict:[String:Any]) -> Void in
                    let message = "\(NSLocalizedString("profile.login.welcome",comment:""))\n\n\(NSLocalizedString("profile.login.addAddress",comment:""))"
                    self.alertView!.setMessage(message)
                    self.alertView!.showDoneIconWithoutClose()
                    self.alertView!.addActionButtonsWithCustomText(NSLocalizedString("update.later", comment: ""), leftAction: {
                        self.successCallBack?()
                        self.backRegistry(self.backButton!)
                        self.alertView!.rightButton?.removeFromSuperview()
                        self.alertView!.leftButton?.removeFromSuperview()
                        }, rightText: "Crear Dirección", rightAction: {
                            self.showAddressView()
                            self.alertView!.rightButton?.removeFromSuperview()
                            self.alertView!.leftButton?.removeFromSuperview()
                        }, isNewFrame: false)
                    }, errorBlock: { (error:NSError) -> Void in
                        self.backRegistry(self.backButton!)
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                    })
                }, errorBlock: {(error: NSError) in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
        }
    }
    
    /**
     Shows address view form
     */
    func showAddressView() {
        if alertAddress == nil {
            alertAddress = GRFormAddressAlertView.initAddressAlert()!
            alertAddress!.titleLabel.text = NSLocalizedString("profile.address.new.title", comment: "")
        }
        alertAddress?.showAddressAlert()
        alertAddress?.beforeAddAddress = {(dictSend:[String:Any]?) in
            self.alertAddress?.registryAddress(dictSend)
            self.alertView!.close()
        }
        
        alertAddress?.alertSaveSuccess = {() in
            self.alertAddress?.removeFromSuperview()
            self.successCallBack?()
            self.backRegistry(self.backButton!)
        }
        
        alertAddress?.cancelPress = {() in
            print("")
            self.successCallBack?()
            self.backRegistry(self.backButton!)
            self.alertView!.rightButton?.removeFromSuperview()
            self.alertView!.leftButton?.removeFromSuperview()
            self.alertAddress?.closePicker()
        }
    }
    
    /**
     Validates user data
     
     - returns: Bool
     */
    func validateUser () -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(lastName!)
        }
        if !error{
            error = viewError(email!)
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
                SignUpViewController.presentMessage(self.confirmPassword!,  nameField:self.confirmPassword!.nameField, message: NSLocalizedString("field.validate.confirm.password", comment: ""), errorView:self.errorView!,  becomeFirstResponder: true )
                error = true
            }
        }
        if error{
            return false
        }

        if !error{

            self.errorView?.removeFromSuperview()
        return true
        }
        
        return true
    }
    
    /**
     Validates terms and conditions
     
     - returns: Bool
     */
    func validateTerms() -> Bool {
        if !acceptSharePersonal!.isSelected && !declineSharePersonal!.isSelected {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"user_error"))
            let msgInventory = "Para poder continuar, es necesario nos indique si está, o no, de acuerdo en transferir sus datos personales a terceros"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("Ok",comment:""))
            return false
        }
        if !acceptTerms!.isSelected {
            if self.errorView == nil {
                self.errorView = FormFieldErrorView()
            }

            self.presentMessageTerms(self.acceptTerms!, message: NSLocalizedString("signup.validate.terms.conditions", comment: ""), errorView: self.errorView!)
            return false

        }
        return true
    }
    
    /**
     Shows view error in field
     
     - parameter field: field to show error
     
     - returns: Bool
     */
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil  {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!, becomeFirstResponder: true )
            return true
        }
        return false
    }

    /**
     Shows terms message
     
     - parameter view:      view to show
     - parameter message:   message
     - parameter errorView: erroeView
     */
    func presentMessageTerms(_ view: UIView,  message: String, errorView : FormFieldErrorView){
        errorView.frame =  CGRect(x: 10, y: 0, width: view.frame.width, height: view.frame.height )
        errorView.focusError = nil
        errorView.setValues(280, strLabel:"", strValue: message)
        errorView.frame =  CGRect(x: 10, y: view.frame.minY, width: errorView.frame.width , height: errorView.frame.height)
        let contentView = view.superview!
        contentView.addSubview(errorView)
        contentView.bringSubview(toFront: view)
        UIView.animate(withDuration: 0.2, animations: {
            errorView.frame =  CGRect(x: 10, y: view.frame.minY - errorView.frame.height, width: errorView.frame.width , height: errorView.frame.height)
            contentView.bringSubview(toFront: errorView)
            if self.infoContainer != nil {
                self.infoContainer!.bringSubview(toFront: errorView)
            }
            }, completion: {(bool : Bool) in
        })
    }
    
    /**
     Presents error message and error view
     
     - parameter field:                field to show error
     - parameter nameField:            field name
     - parameter message:              error message
     - parameter errorView:            error view
     - parameter becomeFirstResponder: bool to indicates to become or not first responder
     */
    class func presentMessage(_ field: UITextField, nameField:String,  message: String , errorView : FormFieldErrorView, becomeFirstResponder: Bool){
        errorView.frame = CGRect(x: field.frame.minX - 5, y: 0, width: field.frame.width, height: field.frame.height )
        errorView.focusError = field
        if field.frame.minX < 20 {
            errorView.setValues(field.frame.width, strLabel:nameField, strValue: message)
            errorView.frame =  CGRect(x: field.frame.minX - 5, y: field.frame.minY, width: errorView.frame.width , height: errorView.frame.height)
        }
        else{
            errorView.setValues(field.frame.width, strLabel:nameField, strValue: message)
            errorView.frame =  CGRect(x: field.frame.minX - 5, y: field.frame.minY, width: errorView.frame.width , height: errorView.frame.height)
        }
        let contentView = field.superview!
        contentView.addSubview(errorView)
        contentView.bringSubview(toFront: field)
        UIView.animate(withDuration: 0.2, animations: {
            errorView.frame =  CGRect(x: field.frame.minX - 5 , y: field.frame.minY - errorView.frame.height, width: errorView.frame.width , height: errorView.frame.height)
            }, completion: {(bool : Bool) in
                if bool {
                    contentView.bringSubview(toFront: errorView)
                    if becomeFirstResponder {
                        field.becomeFirstResponder()
                    }
                    field.layer.borderColor =   WMColor.red.cgColor
                }
        })
    }
    
    /**
     Validates  user email
     
     - parameter email: string email
     
     - returns: Bool
     */
    class func isValidEmail(_ email: String ) -> Bool{

        let alphanumericset = CharacterSet(charactersIn: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890._%+-@").inverted
        if email.rangeOfCharacter(from: alphanumericset) != nil {
            return false
        }
        
        let regExEmailPattern : String = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: regExEmailPattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatches(in: email, options: [], range: NSMakeRange(0, email.characters.count))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    /**
     Changes date value
     */
    func dateChanged() {
        let date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.string(from: date)
        self.dateVal = date
    }
    
   
    
    //MARK: Info view
    /**
     Generates and shows info view
     
     - parameter frame: info view frame
     
     - returns: UIView
     */
    func generateInfoView(_ frame:CGRect) -> UIView {
        if infoContainer == nil {
            
            infoContainer = UIView(frame:frame)
            
            let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 16))
            lblTitle.text = NSLocalizedString("signup.info", comment: "")
            lblTitle.font = WMFont.fontMyriadProRegularOfSize(16)
            lblTitle.textColor = UIColor.white
            lblTitle.textAlignment = .center
            
            self.promoAccept = UIButton(frame: CGRect(x: 16, y: lblTitle.frame.maxY + 30.0, width: frame.width, height: 16))
            self.promoAccept?.setTitle(NSLocalizedString("signup.info.pub", comment: ""), for: UIControlState())
            self.promoAccept!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
            self.promoAccept!.setImage(UIImage(named:"checkTermOn"), for: UIControlState.selected)
            self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            self.promoAccept!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
            self.promoAccept!.addTarget(self, action: #selector(SignUpViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
            
            self.contentTerms = UIView()
            self.contentTerms!.frame = CGRect(x: 0 ,  y: self.promoAccept!.frame.maxY + 24.0 , width: self.view.bounds.width ,height: 30)
            
            acceptTerms = UIButton()
            acceptTerms!.frame = CGRect(x: 10, y: -4, width: 30, height: 30 )
            acceptTerms!.setImage(UIImage(named:"checkTermOn"), for: UIControlState.selected)
            acceptTerms!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
            acceptTerms!.addTarget(self, action: #selector(SignUpViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
            
            labelTerms = UILabel()
            labelTerms?.frame =  CGRect(x: acceptTerms!.frame.maxX + 4, y: 0 ,  width: self.content!.frame.width - (acceptTerms!.frame.width + 15 )  , height: 30 )
            labelTerms!.numberOfLines = 0
            labelTerms!.font = WMFont.fontMyriadProRegularOfSize(12)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let valuesDescItem = NSMutableAttributedString()
            let attrStringLab = NSAttributedString(string: NSLocalizedString("signup.info.provacity", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName:UIColor.white])
            valuesDescItem.append(attrStringLab)
            let attrStringVal = NSAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName:UIColor.white])
            valuesDescItem.append(attrStringVal)
            valuesDescItem.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, valuesDescItem.length))
            labelTerms!.attributedText = valuesDescItem
            labelTerms!.textColor = UIColor.white
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(SignUpViewController.noticePrivacy(_:)))
            labelTerms?.isUserInteractionEnabled = true
            labelTerms?.addGestureRecognizer(tapGestureRecognizer)
            
            
            self.contentTerms!.addSubview(acceptTerms!)
            self.contentTerms!.addSubview(labelTerms!)
            
            
            let lblPersonalData = UILabel(frame: CGRect(x: 16, y: self.contentTerms!.frame.maxY + 24.0, width: frame.width - 32, height: 84))
            lblPersonalData.text = NSLocalizedString("signup.info.share", comment: "")
            lblPersonalData.textColor = UIColor.white
            lblPersonalData.font = WMFont.fontMyriadProRegularOfSize(12)
            lblPersonalData.numberOfLines = 0
            
            
            self.acceptSharePersonal = UIButton(frame: CGRect(x: 45, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16))
            self.acceptSharePersonal?.setTitle(NSLocalizedString("signup.info.share.yes", comment: ""), for: UIControlState())
            self.acceptSharePersonal!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
            self.acceptSharePersonal!.setImage(UIImage(named:"checkTermOn"), for: UIControlState.selected)
            self.acceptSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            self.acceptSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            self.acceptSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
            self.acceptSharePersonal!.addTarget(self, action: #selector(SignUpViewController.changeCons(_:)), for: UIControlEvents.touchUpInside)
            
            self.declineSharePersonal = UIButton(frame: CGRect(x: acceptSharePersonal!.frame.maxX, y: lblPersonalData.frame.maxY + 24.0, width: 120, height: 16))
            self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), for: UIControlState())
            self.declineSharePersonal!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
            self.declineSharePersonal!.setImage(UIImage(named:"checkTermOn"), for: UIControlState.selected)
            self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
            self.declineSharePersonal!.addTarget(self, action: #selector(SignUpViewController.changeCons(_:)), for: UIControlEvents.touchUpInside)
            
            
            self.backButton = UIButton(frame: CGRect(x: 16, y: declineSharePersonal!.frame.maxY + 102.0, width: 136, height: 40))
            self.backButton!.setTitle(NSLocalizedString("signup.info.return", comment: ""), for: UIControlState())
            self.backButton!.setTitleColor(UIColor.white, for: UIControlState())
            self.backButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.backButton!.backgroundColor = WMColor.dark_blue
            self.backButton!.layer.cornerRadius = 20.0
            self.backButton!.addTarget(self, action: #selector(SignUpViewController.backRegistry(_:)), for: .touchUpInside)
            
            self.registryButton = UIButton(frame: CGRect(x: self.backButton!.frame.maxX + 16.0, y: declineSharePersonal!.frame.maxY + 102.0, width: 136, height: 40))
            self.registryButton!.setTitle(NSLocalizedString("signup.info.registry", comment: ""), for: UIControlState())
            self.registryButton!.setTitleColor(UIColor.white, for: UIControlState())
            self.registryButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.registryButton!.backgroundColor = WMColor.green
            self.registryButton!.layer.cornerRadius = 20.0
            self.registryButton!.addTarget(self, action: #selector(SignUpViewController.registryUser), for: .touchUpInside)
            
            
            infoContainer?.addSubview(lblTitle)
            infoContainer?.addSubview(promoAccept!)
            infoContainer?.addSubview(contentTerms!)
            infoContainer?.addSubview(lblPersonalData)
            infoContainer?.addSubview(acceptSharePersonal!)
            infoContainer?.addSubview(declineSharePersonal!)
            infoContainer?.addSubview(registryButton!)
            infoContainer?.addSubview(backButton!)
            self.view.addSubview(infoContainer!)
        
        }
        return infoContainer!
    }
    
    /**
     Back to registry
     
     - parameter sender: UIButton
     */
    func backRegistry(_ sender:AnyObject) {
        let infoView = self.generateInfoView(self.content.frame)
        self.content.alpha = 1
        infoView.alpha = 0
        self.view.endEditing(true)
    }
    
    func changeCons(_ sender:UIButton) {
        if sender == self.acceptSharePersonal {
            self.acceptSharePersonal?.isSelected = true
            self.declineSharePersonal?.isSelected = false
        } else if sender == self.declineSharePersonal  {
            self.acceptSharePersonal?.isSelected = false
            self.declineSharePersonal?.isSelected = true
        }
        
    }
    
}


