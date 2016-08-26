//
//  SignUpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

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
    var viewClose : ((hidden: Bool ) -> Void)? = nil
    var titleLabel: UILabel? = nil
    var errorView : FormFieldErrorView? = nil
    var previewHelp : PreviewHelpViewController? = nil
    var alertView : IPOWMAlertViewController? = nil
    var alertAddress : GRFormAddressAlertView? = nil
    
    var birthDate : FormFieldView? = nil
    var inputBirthdateView: UIDatePicker?
    var maleButton: UIButton?
    var femaleButton: UIButton?
    
    var dateFmt: NSDateFormatter?
    
    var dateVal : NSDate? = nil
    
    var closeModal : (() -> Void)? = nil
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SIGNUP.rawValue
    }

    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.scrollDelegate = self
        self.content.delegate = self
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.typeField = TypeField.Name
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        self.name!.minLength = 3
        self.name!.maxLength = 25
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.typeField = TypeField.Name
        self.lastName!.minLength = 3
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
       
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.typeField = TypeField.Email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.maxLength = 45
        self.email!.autocapitalizationType = UITextAutocapitalizationType.None
        
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
        self.continueButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment: ""), forState: UIControlState.Normal)
        self.continueButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.continueButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.continueButton!.backgroundColor = WMColor.green
        self.continueButton!.layer.cornerRadius = 20.0
        self.continueButton!.addTarget(self, action: #selector(SignUpViewController.continueToInfo), forControlEvents: .TouchUpInside)
        
        self.content.backgroundColor = UIColor.clearColor()
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("profile.create.an.cancel", comment: ""), forState: UIControlState.Normal)
        self.cancelButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.dark_blue
        self.cancelButton!.layer.cornerRadius = 20.0
        self.cancelButton!.addTarget(self, action: #selector(SignUpViewController.cancelRegistry(_:)), forControlEvents: .TouchUpInside)
        
        self.titleLabel = UILabel()
        self.titleLabel!.textColor =  UIColor.whiteColor()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel!.text = NSLocalizedString("profile.create.an.account", comment: "")
        self.titleLabel!.textAlignment = NSTextAlignment.Center
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
        self.content.frame = CGRectMake(0, 0 , self.view.bounds.width , self.view.bounds.height)
        self.titleLabel!.frame =  CGRectMake(0 , 0, self.content.frame.width , 16)
        self.name?.frame = CGRectMake(leftRightPadding,  40, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.lastName?.frame = CGRectMake(leftRightPadding,  name!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.email?.frame = CGRectMake(leftRightPadding,  lastName!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.password?.frame = CGRectMake(leftRightPadding,  email!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.confirmPassword?.frame = CGRectMake(leftRightPadding,  password!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
//        self.birthDate?.frame = CGRectMake(leftRightPadding,  confirmPassword!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
//        self.femaleButton!.frame = CGRectMake(84,  birthDate!.frame.maxY + 15,  76 , fieldHeight)
//        self.maleButton!.frame = CGRectMake(self.femaleButton!.frame.maxX,  birthDate!.frame.maxY + 15, 76 , fieldHeight)
        
        self.cancelButton!.frame = CGRectMake(leftRightPadding,  confirmPassword!.frame.maxY + 30,  (self.email!.frame.width / 2) - 5 , fieldHeight)
        self.continueButton!.frame = CGRectMake(self.cancelButton!.frame.maxX + 10 , self.cancelButton!.frame.minY ,  self.cancelButton!.frame.width, fieldHeight)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.continueButton!.frame.maxY + 40)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func  contentSizeForScrollView(sender:AnyObject) -> CGSize {
          return CGSizeMake(self.view.frame.width, content.contentSize.height)
    }
    
    //MARK: - TextFieldDelegate
    func textFieldDidEndEditingSW(textField: UITextField!) {
        if errorView != nil{
            if (errorView!.focusError == textField || errorView!.focusError == nil ) &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
            }
        }
    }
    
    func textFieldDidBeginEditingSW(textField: UITextView!) {
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
    func changeMF(sender:UIButton) {
        if sender == self.maleButton {
            self.maleButton?.selected = true
            self.femaleButton?.selected = false
        } else if sender == self.femaleButton  {
            self.maleButton?.selected = false
            self.femaleButton?.selected = true
        }
        
    }
    
    /**
     Checks selected buttons
     
     - parameter sender: UIButton
     */
    func checkSelected(sender:UIButton) {
        sender.selected = !(sender.selected)
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
    func noticePrivacy(recognizer:UITapGestureRecognizer) {
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
            self.previewHelp!.view.frame =  CGRectMake(self.name!.frame.minX ,  40, self.content!.frame.width - (self.name!.frame.minX * 2) , self.content!.frame.height - 60 )
            self.close = UIButton(type: .Custom)
            self.close!.setImage(UIImage(named: "termsClose"), forState: .Normal)
            self.close!.addTarget(self, action: #selector(SignUpViewController.closeNoticePrivacy), forControlEvents: .TouchUpInside)
            self.close!.backgroundColor = UIColor.clearColor()
            self.close!.frame = CGRectMake(self.content!.frame.width - 40.0, 22, 40.0, 40.0)
        
        } else {
            self.previewHelp!.loadPreview()
        }
        self.infoContainer!.addSubview(self.previewHelp!.view)
        self.infoContainer!.addSubview(self.close!)
        self.viewClose!(hidden: true)
        self.continueButton!.hidden = true
        self.cancelButton!.hidden = true
    }
    
    /**
     Closes Privacy Notice
     */
    func closeNoticePrivacy() {
        self.previewHelp!.view.removeFromSuperview()
        self.close!.removeFromSuperview()
        self.viewClose!(hidden: false)
        self.continueButton!.hidden = false
        self.cancelButton!.hidden = false

    }
    
    /**
     Returns to login view
     
     - parameter sender: UIButton
     */
    func cancelRegistry(sender:UIButton) {
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
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SIGNUP.rawValue,action: WMGAIUtils.ACTION_SAVE_SIGNUP.rawValue, label: "")
            let service = SignUpService()
//            let dateFmtBD = NSDateFormatter()
//            dateFmtBD.dateFormat = "dd/MM/yyyy"
//            let dateOfBirth = dateFmtBD.stringFromDate(self.dateVal!)
//            let gender = femaleButton!.selected ? "Female" : "Male"
            let allowTransfer = "\(self.acceptSharePersonal!.selected)"
            let allowPub = "\(self.promoAccept!.selected)"
            let params = service.buildParamsWithMembership(email!.text!, password: password!.text!, name: name!.text!, lastName:  lastName!.text!, allowMarketingEmail: allowPub, allowTransfer: allowTransfer)
            self.view.endEditing(true)
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                let login = LoginService()
                login.callService(login.buildParams(self.email!.text!, password: self.password!.text!), successBlock: { (dict:NSDictionary) -> Void in
                    let message = "\(NSLocalizedString("profile.login.welcome",comment:""))\n\n\(NSLocalizedString("profile.login.addAddress",comment:""))"
                    self.alertView!.setMessage(message)
                    self.alertView!.showDoneIconWithoutClose()
                    self.alertView!.addActionButtonsWithCustomText("Más tarde", leftAction: {
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
        }
        alertAddress?.showAddressAlert()
        alertAddress?.beforeAddAddress = {(dictSend:NSDictionary?) in
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
//        if !error{
//            error = viewError(birthDate!)
//        }
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
//        if !maleButton!.selected && !femaleButton!.selected {
//            if self.errorView == nil {
//                self.errorView = FormFieldErrorView()
//            }
//            self.presentMessageTerms(self.femaleButton!, message: NSLocalizedString("field.validate.minmaxlength.gender", comment: ""), errorView: self.errorView!)
//            return false
//        }
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
        if !acceptSharePersonal!.selected && !declineSharePersonal!.selected {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"user_error"))
            let msgInventory = "Para poder continuar, es necesario nos indique si está, o no, de acuerdo en transferir sus datos personales a terceros"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("Ok",comment:""))
            return false
        }
        if !acceptTerms!.selected {
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
    func viewError(field: FormFieldView)-> Bool{
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
    func presentMessageTerms(view: UIView,  message: String, errorView : FormFieldErrorView){
        errorView.frame =  CGRectMake(10, 0, view.frame.width, view.frame.height )
        errorView.focusError = nil
        errorView.setValues(280, strLabel:"", strValue: message)
        errorView.frame =  CGRectMake(10, view.frame.minY, errorView.frame.width , errorView.frame.height)
        let contentView = view.superview!
        contentView.addSubview(errorView)
        contentView.bringSubviewToFront(view)
        UIView.animateWithDuration(0.2, animations: {
            errorView.frame =  CGRectMake(10, view.frame.minY - errorView.frame.height, errorView.frame.width , errorView.frame.height)
            contentView.bringSubviewToFront(errorView)
            if self.infoContainer != nil {
                self.infoContainer!.bringSubviewToFront(errorView)
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
    class func presentMessage(field: UITextField, nameField:String,  message: String , errorView : FormFieldErrorView, becomeFirstResponder: Bool){
        errorView.frame = CGRectMake(field.frame.minX - 5, 0, field.frame.width, field.frame.height )
        errorView.focusError = field
        if field.frame.minX < 20 {
            errorView.setValues(field.frame.width, strLabel:nameField, strValue: message)
            errorView.frame =  CGRectMake(field.frame.minX - 5, field.frame.minY, errorView.frame.width , errorView.frame.height)
        }
        else{
            errorView.setValues(field.frame.width, strLabel:nameField, strValue: message)
            errorView.frame =  CGRectMake(field.frame.minX - 5, field.frame.minY, errorView.frame.width , errorView.frame.height)
        }
        let contentView = field.superview!
        contentView.addSubview(errorView)
        contentView.bringSubviewToFront(field)
        UIView.animateWithDuration(0.2, animations: {
            errorView.frame =  CGRectMake(field.frame.minX - 5 , field.frame.minY - errorView.frame.height, errorView.frame.width , errorView.frame.height)
            }, completion: {(bool : Bool) in
                if bool {
                    contentView.bringSubviewToFront(errorView)
                    if becomeFirstResponder {
                        field.becomeFirstResponder()
                    }
                    field.layer.borderColor =   WMColor.red.CGColor
                }
        })
    }
    
    /**
     Validates  user email
     
     - parameter email: string email
     
     - returns: Bool
     */
    class func isValidEmail(email: String ) -> Bool{

        let alphanumericset = NSCharacterSet(charactersInString: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890._%+-@").invertedSet
        if email.rangeOfCharacterFromSet(alphanumericset) != nil {
            return false
        }
        
        let regExEmailPattern : String = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: regExEmailPattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatchesInString(email, options: [], range: NSMakeRange(0, email.characters.count))
        
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
        self.birthDate!.text = self.dateFmt!.stringFromDate(date)
        self.dateVal = date
    }
    
   
    
    //MARK: Info view
    /**
     Generates and shows info view
     
     - parameter frame: info view frame
     
     - returns: UIView
     */
    func generateInfoView(frame:CGRect) -> UIView {
        if infoContainer == nil {
            
            infoContainer = UIView(frame:frame)
            
            let lblTitle = UILabel(frame: CGRectMake(0, 0, frame.width, 16))
            lblTitle.text = NSLocalizedString("signup.info", comment: "")
            lblTitle.font = WMFont.fontMyriadProRegularOfSize(16)
            lblTitle.textColor = UIColor.whiteColor()
            lblTitle.textAlignment = .Center
            
            self.promoAccept = UIButton(frame: CGRectMake(16, lblTitle.frame.maxY + 30.0, frame.width, 16))
            self.promoAccept?.setTitle(NSLocalizedString("signup.info.pub", comment: ""), forState: UIControlState.Normal)
            self.promoAccept!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
            self.promoAccept!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
            self.promoAccept!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            self.promoAccept!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            self.promoAccept!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
            self.promoAccept!.addTarget(self, action: #selector(SignUpViewController.checkSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.contentTerms = UIView()
            self.contentTerms!.frame = CGRectMake(0 ,  self.promoAccept!.frame.maxY + 24.0 , self.view.bounds.width ,30)
            
            acceptTerms = UIButton()
            acceptTerms!.frame = CGRectMake(10, -4, 30, 30 )
            acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
            acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
            acceptTerms!.addTarget(self, action: #selector(SignUpViewController.checkSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            labelTerms = UILabel()
            labelTerms?.frame =  CGRectMake(acceptTerms!.frame.maxX + 4, 0 ,  self.content!.frame.width - (acceptTerms!.frame.width + 15 )  , 30 )
            labelTerms!.numberOfLines = 0
            labelTerms!.font = WMFont.fontMyriadProRegularOfSize(12)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let valuesDescItem = NSMutableAttributedString()
            let attrStringLab = NSAttributedString(string: NSLocalizedString("signup.info.provacity", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName:UIColor.whiteColor()])
            valuesDescItem.appendAttributedString(attrStringLab)
            let attrStringVal = NSAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName:UIColor.whiteColor()])
            valuesDescItem.appendAttributedString(attrStringVal)
            valuesDescItem.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, valuesDescItem.length))
            labelTerms!.attributedText = valuesDescItem
            labelTerms!.textColor = UIColor.whiteColor()
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(SignUpViewController.noticePrivacy(_:)))
            labelTerms?.userInteractionEnabled = true
            labelTerms?.addGestureRecognizer(tapGestureRecognizer)
            
            
            self.contentTerms!.addSubview(acceptTerms!)
            self.contentTerms!.addSubview(labelTerms!)
            
            
            let lblPersonalData = UILabel(frame: CGRectMake(16, self.contentTerms!.frame.maxY + 24.0, frame.width - 32, 84))
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
            self.acceptSharePersonal!.addTarget(self, action: #selector(SignUpViewController.changeCons(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.declineSharePersonal = UIButton(frame: CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16))
            self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), forState: UIControlState.Normal)
            self.declineSharePersonal!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
            self.declineSharePersonal!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
            self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
            self.declineSharePersonal!.addTarget(self, action: #selector(SignUpViewController.changeCons(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            
            self.backButton = UIButton(frame: CGRectMake(16, declineSharePersonal!.frame.maxY + 102.0, 136, 40))
            self.backButton!.setTitle(NSLocalizedString("signup.info.return", comment: ""), forState: UIControlState.Normal)
            self.backButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.backButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.backButton!.backgroundColor = WMColor.dark_blue
            self.backButton!.layer.cornerRadius = 20.0
            self.backButton!.addTarget(self, action: #selector(SignUpViewController.backRegistry(_:)), forControlEvents: .TouchUpInside)
            
            self.registryButton = UIButton(frame: CGRectMake(self.backButton!.frame.maxX + 16.0, declineSharePersonal!.frame.maxY + 102.0, 136, 40))
            self.registryButton!.setTitle(NSLocalizedString("signup.info.registry", comment: ""), forState: UIControlState.Normal)
            self.registryButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.registryButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.registryButton!.backgroundColor = WMColor.green
            self.registryButton!.layer.cornerRadius = 20.0
            self.registryButton!.addTarget(self, action: #selector(SignUpViewController.registryUser), forControlEvents: .TouchUpInside)
            
            
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
    func backRegistry(sender:AnyObject) {
        let infoView = self.generateInfoView(self.content.frame)
        self.content.alpha = 1
        infoView.alpha = 0
        self.view.endEditing(true)
    }
    
    func changeCons(sender:UIButton) {
        if sender == self.acceptSharePersonal {
            self.acceptSharePersonal?.selected = true
            self.declineSharePersonal?.selected = false
        } else if sender == self.declineSharePersonal  {
            self.acceptSharePersonal?.selected = false
            self.declineSharePersonal?.selected = true
        }
        
    }
    
}


