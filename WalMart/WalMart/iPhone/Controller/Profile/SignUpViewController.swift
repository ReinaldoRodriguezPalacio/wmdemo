//
//  SignUpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class SignUpViewController : UIViewController, UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate {
    
    var close: UIButton?
    var content: TPKeyboardAvoidingScrollView!
    var name : FormFieldView? = nil
    var lastName : FormFieldView? = nil
    var email : FormFieldView? = nil
    var password : FormFieldView? = nil
    var confirmPassword : FormFieldView? = nil
    var birthDate : FormFieldView? = nil
    var inputBirthdateView: UIDatePicker?
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
    
    var maleButton: UIButton?
    var femaleButton: UIButton?
    
    var dateFmt: NSDateFormatter?
    
    var dateVal : NSDate? = nil
    
    var closeModal : (() -> Void)? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_SIGNUP.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.scrollDelegate = self
        self.content.delegate = self
        let checkTermOff = UIImage(named:"checkTermOff")
        let checkTermOn = UIImage(named:"checkTermOn")
        
        self.name = FormFieldView()
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.isRequired = true
        self.name!.typeField = TypeField.Name
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        self.name!.minLength = 2
        self.name!.maxLength = 25
        
        self.lastName = FormFieldView()
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.isRequired = true
        self.lastName!.typeField = TypeField.String
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
       
        self.email = FormFieldView()
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.isRequired = true
        self.email!.typeField = TypeField.Email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.maxLength = 45
        self.email!.autocapitalizationType = UITextAutocapitalizationType.None
        
        self.password = FormFieldView()
        self.password!.setCustomPlaceholder(NSLocalizedString("profile.password",comment:""))
        self.password!.secureTextEntry = true
        self.password!.isRequired = true
        self.password!.typeField = TypeField.Password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.minLength = 8
        self.password!.maxLength = 20
        
        self.confirmPassword = FormFieldView()
        self.confirmPassword!.setCustomPlaceholder(NSLocalizedString("profile.confirmpassword",comment:""))
        self.confirmPassword!.secureTextEntry = true
        self.confirmPassword!.isRequired = true
        self.confirmPassword!.typeField = TypeField.Password
        self.confirmPassword!.nameField = NSLocalizedString("profile.confirmpassword",comment:"")
        self.confirmPassword!.minLength = 8
        self.confirmPassword!.maxLength = 20
        
        
        self.birthDate = FormFieldView()
        self.birthDate!.setCustomPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
        self.birthDate!.typeField = .None
        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")
        self.birthDate!.isRequired = true
        self.birthDate!.disablePaste = true
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                self.dateChanged()
                field?.resignFirstResponder()
            }
        })
        
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let currentDate = NSDate()
        var comps = NSDateComponents()
        //comps.year = -18
        //var maxDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions.allZeros)
        comps.year = -100
        var minDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions.allZeros)

        self.inputBirthdateView = UIDatePicker()
        self.inputBirthdateView!.datePickerMode = .Date
        self.inputBirthdateView!.date = NSDate()
        self.inputBirthdateView!.maximumDate = NSDate()
        self.inputBirthdateView!.minimumDate = minDate
        self.inputBirthdateView!.addTarget(self, action: "dateChanged", forControlEvents: .ValueChanged)
        self.birthDate!.inputView = self.inputBirthdateView!
        self.birthDate!.inputAccessoryView = viewAccess
//        self.dateChanged()
        
        
        
        self.maleButton = UIButton()
        self.maleButton?.setTitle(NSLocalizedString("signup.male", comment: ""), forState: UIControlState.Normal)
        self.maleButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.maleButton!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
        self.maleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.maleButton?.addTarget(self, action: "changeMF:", forControlEvents: UIControlEvents.TouchUpInside)
        self.maleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.maleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        
        self.femaleButton = UIButton()
        self.femaleButton?.setTitle(NSLocalizedString("signup.female", comment: ""), forState: UIControlState.Normal)
        self.femaleButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.femaleButton!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
        self.femaleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.femaleButton?.addTarget(self, action: "changeMF:", forControlEvents: UIControlEvents.TouchUpInside)
        self.femaleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.femaleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        

        
        
        
//        contentTerms = UIView()
//
//        acceptTerms = UIButton()
//        acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
//        acceptTerms!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
//        
//        labelTerms = UILabel()
//        labelTerms!.numberOfLines = 0
//        labelTerms!.font = WMFont.fontMyriadProRegularOfSize(12)
//        
//        var paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 4
//       
//        var valueItem = NSMutableAttributedString()
//        var valuesDescItem = NSMutableAttributedString()
//        var attrStringLab = NSAttributedString(string: NSLocalizedString("profile.terms", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName:UIColor.whiteColor()])
//        valuesDescItem.appendAttributedString(attrStringLab)
//        var attrStringVal = NSAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName:UIColor.whiteColor()])
//        valuesDescItem.appendAttributedString(attrStringVal)
//        valuesDescItem.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, valuesDescItem.length))
//        labelTerms!.attributedText = valuesDescItem
//        labelTerms!.textColor = UIColor.whiteColor()
//        
//        //viewTap = UIView()
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:"noticePrivacy:")
//        labelTerms?.userInteractionEnabled = true
//        labelTerms?.addGestureRecognizer(tapGestureRecognizer)
        //self.viewTap!.addGestureRecognizer(tapGestureRecognizer)
        
        self.continueButton = UIButton()
        self.continueButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment: ""), forState: UIControlState.Normal)
        self.continueButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.continueButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.continueButton!.backgroundColor = WMColor.loginSignInButonBgColor
        self.continueButton!.layer.cornerRadius = 20.0
        self.continueButton!.addTarget(self, action: "continueToInfo", forControlEvents: .TouchUpInside)
        
        self.content.backgroundColor = UIColor.clearColor()
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("profile.create.an.cancel", comment: ""), forState: UIControlState.Normal)
        self.cancelButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.loginSignOutButonBgColor
        self.cancelButton!.layer.cornerRadius = 20.0
        self.cancelButton!.addTarget(self, action: "cancelRegistry:", forControlEvents: .TouchUpInside)
        
        //labelTerms!.textColor = UIColor.whiteColor()
        
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
        self.content!.addSubview(birthDate!)
        self.content!.addSubview(continueButton!)
        self.content!.addSubview(maleButton!)
        self.content!.addSubview(femaleButton!)
        
        
//        self.content!.addSubview(self.contentTerms!)
//        self.contentTerms!.addSubview(acceptTerms!)
//        self.contentTerms!.addSubview(labelTerms!)
        //self.contentTerms!.addSubview(viewTap!)
        
        self.content.clipsToBounds = false
    }
    
    
    func changeMF(sender:UIButton) {
        if sender == self.maleButton {
            self.maleButton?.selected = true
            self.femaleButton?.selected = false
        } else if sender == self.femaleButton  {
            self.maleButton?.selected = false
            self.femaleButton?.selected = true
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.bounds
        let fieldHeight  : CGFloat = CGFloat(40)
        let leftRightPadding  : CGFloat = CGFloat(15)
        self.content.frame = CGRectMake(0, 0 , self.view.bounds.width , self.view.bounds.height)
        self.titleLabel!.frame =  CGRectMake(0 , 0, self.content.frame.width , 16)
        self.name?.frame = CGRectMake(leftRightPadding,  40, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.lastName?.frame = CGRectMake(leftRightPadding,  name!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.email?.frame = CGRectMake(leftRightPadding,  lastName!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.password?.frame = CGRectMake(leftRightPadding,  email!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.confirmPassword?.frame = CGRectMake(leftRightPadding,  password!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        self.birthDate?.frame = CGRectMake(leftRightPadding,  confirmPassword!.frame.maxY + 8, self.view.bounds.width - (leftRightPadding*2), fieldHeight)
        
        

        
        self.femaleButton!.frame = CGRectMake(84,  birthDate!.frame.maxY + 15,  76 , fieldHeight)
        self.maleButton!.frame = CGRectMake(self.femaleButton!.frame.maxX,  birthDate!.frame.maxY + 15, 76 , fieldHeight)
        
        self.cancelButton!.frame = CGRectMake(leftRightPadding,  maleButton!.frame.maxY + 15,  (self.email!.frame.width / 2) - 5 , fieldHeight)
        self.continueButton!.frame = CGRectMake(self.cancelButton!.frame.maxX + 10 , self.cancelButton!.frame.minY ,  self.cancelButton!.frame.width, fieldHeight)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.continueButton!.frame.maxY + 40)
    }
    
    func checkSelected(sender:UIButton) {
        sender.selected = !(sender.selected)
        if errorView != nil{
            if errorView?.superview != nil {
                errorView?.removeFromSuperview()
            }
            errorView!.focusError = nil
            errorView = nil
        }
//        acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
    }
    
    func  contentSizeForScrollView(sender:AnyObject) -> CGSize {
          return CGSizeMake(self.view.frame.width, content.contentSize.height)
    }
    
    func textFieldDidEndEditingSW(textField: UITextField!) {
        if errorView != nil{
            if (errorView!.focusError == textField || errorView!.focusError == nil ) &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
            }
        }
//        acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
    }
    
    func textFieldDidBeginEditingSW(textField: UITextView!) {
        if errorView != nil && errorView!.focusError == nil {
            errorView?.removeFromSuperview()
            errorView!.focusError = nil
            errorView = nil
        }
//        acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
    }
    
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
            self.close = UIButton.buttonWithType(.Custom) as? UIButton
            self.close!.setImage(UIImage(named: "termsClose"), forState: .Normal)
            self.close!.addTarget(self, action: "closeNoticePrivacy", forControlEvents: .TouchUpInside)
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
    
    func closeNoticePrivacy() {
        self.previewHelp!.view.removeFromSuperview()
        self.close!.removeFromSuperview()
        self.viewClose!(hidden: false)
        self.continueButton!.hidden = false
        self.cancelButton!.hidden = false

    }
    
    func cancelRegistry(sender:UIButton) {
        self.cancelSignUp!()
    }
    
    
    func continueToInfo() {
        self.view.endEditing(true)
        birthDate!.resignFirstResponder()
        
        if validateUser() {
            let infoView = self.generateInfoView(self.content.frame)
            self.content.alpha = 0
            infoView.alpha = 1
        }
     
    }
    
    func registryUser() {
        if validateTerms() {
            let service = SignUpService()
            
            let dateFmtBD = NSDateFormatter()
            dateFmtBD.dateFormat = "dd/MM/yyyy"
            
            let dateOfBirth = dateFmtBD.stringFromDate(self.dateVal!)
            let gender = femaleButton!.selected ? "Female" : "Male"
            let allowTransfer = "\(self.acceptSharePersonal!.selected)"
            let allowPub = "\(self.promoAccept!.selected)"
            
            let params = service.buildParamsWithMembership(email!.text, password:  password!.text, name: name!.text, lastName: lastName!.text,allowMarketingEmail:allowPub,birthdate:dateOfBirth,gender:gender,allowTransfer:allowTransfer)
            
            if alertAddress == nil {
                alertAddress = GRFormAddressAlertView.initAddressAlert()!
            }
            alertAddress?.showAddressAlert()
            alertAddress?.beforeAddAddress = {(dictSend:NSDictionary?) in
                self.view.endEditing(true)
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
                
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_SIGNUP.rawValue, action: WMGAIUtils.EVENT_SIGNUP_CREATEUSER.rawValue, label: "", value: nil).build() as [NSObject : AnyObject])
                }
                service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                   
                    let login = LoginService()
                    login.callService(login.buildParams(self.email!.text, password: self.password!.text), successBlock: { (dict:NSDictionary) -> Void in
                         println("")
                          self.alertAddress?.registryAddress(dictSend)
                        }, errorBlock: { (error:NSError) -> Void in
                             println("")
                          self.alertAddress?.registryAddress(dictSend)
                    })
                    
                    }
                    , errorBlock: {(error: NSError) in
                        
                        self.backRegistry(self.backButton!)
                        self.alertAddress?.removeFromSuperview()
                        
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                })
            }
                
            alertAddress?.alertSaveSuccess = {() in
                self.successCallBack?()
               
                self.alertAddress?.removeFromSuperview()
            }
            
            alertAddress?.cancelPress = {() in
                println("")
              self.alertAddress?.closePicker()
            }
            
            /*alertAddress?.showMessageCP = {() in
                let alertViewAV = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                alertViewAV?.setMessage("Para crear una cuenta es necesario capturar un C.P. con cobertura, te invitamos a registrar uno diferente")
                alertViewAV?.showicon(alertViewAV?.imageError)
                alertViewAV?.addActionButtonsWithCustomText("Mas tarde", leftAction: { () -> Void in
                    println("")
                    self.alertAddress?.closePicker()
                    self.closeModal?()
                    alertViewAV?.close()
                    }, rightText: "Continuar", rightAction: { () -> Void in
                        println("")
                        alertViewAV?.close()
                })
            }*/
//            alertAddress.cancelPress = {() in
//                if alertViewService != nil {
//                    alertViewService!.setMessage("Es necesario capturar una dirección")
//                    alertViewService!.showErrorIcon("Ok")
//                }
//            }
//            
//            
//            
//           
        }
    }
    
    func createAddress() {
        
    }
    
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
            error = viewError(birthDate!)
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
        if !maleButton!.selected && !femaleButton!.selected {
            if self.errorView == nil {
                self.errorView = FormFieldErrorView()
            }
            self.presentMessageTerms(self.femaleButton!, message: NSLocalizedString("field.validate.minmaxlength.gender", comment: ""), errorView: self.errorView!)
            return false
        }
        
        
        return true
    }
    
    func validateTerms() -> Bool {
        
        if !acceptSharePersonal!.selected && !declineSharePersonal!.selected {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"user_error"))
            let msgInventory = "Para poder continuar, es necesario nos indique si esta, o no, de acuerdo en transferir sus datos personales a terceros"
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
    
    func viewError(field: FormFieldView)-> Bool{
        var message = field.validate()
        if message != nil  {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!, becomeFirstResponder: true )
            return true
        }
        return false
    }

    func presentMessageTerms(view: UIView,  message: String, errorView : FormFieldErrorView){
        errorView.frame =  CGRectMake(10, 0, view.frame.width, view.frame.height )
        errorView.focusError = nil
        errorView.setValues(280, strLabel:"", strValue: message)
        errorView.frame =  CGRectMake(10, view.frame.minY, errorView.frame.width , errorView.frame.height)
        var contentView = view.superview!
        contentView.addSubview(errorView)
        contentView.bringSubviewToFront(view)
        UIView.animateWithDuration(0.2, animations: {
            errorView.frame =  CGRectMake(10, view.frame.minY - errorView.frame.height, errorView.frame.width , errorView.frame.height)
            contentView.bringSubviewToFront(errorView)
            if self.infoContainer != nil {
                self.infoContainer!.bringSubviewToFront(errorView)
            }
            }, completion: {(bool : Bool) in
//                if bool {
//                    self.acceptTerms!.setImage(UIImage(named:"checkTermError"), forState: UIControlState.Normal)
//                }
        })
    }
    
    class func presentMessage(field: UITextField, nameField:String,  message: String , errorView : FormFieldErrorView, becomeFirstResponder: Bool){
        errorView.frame = CGRectMake(field.frame.minX - 5, 0, field.frame.width, field.frame.height )
        errorView.focusError = field
        if field.frame.minX < 20 {
            //errorView.setValues(280, strLabel:nameField, strValue: message)
            errorView.setValues(field.frame.width, strLabel:nameField, strValue: message)
            errorView.frame =  CGRectMake(field.frame.minX - 5, field.frame.minY, errorView.frame.width , errorView.frame.height)
        }
        else{
            errorView.setValues(field.frame.width, strLabel:nameField, strValue: message)
            errorView.frame =  CGRectMake(field.frame.minX - 5, field.frame.minY, errorView.frame.width , errorView.frame.height)
        }
        var contentView = field.superview!
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
                    field.layer.borderColor =   WMColor.profileErrorColor.CGColor
                }
        })
    }
    
    class func isValidEmail(email: String ) -> Bool{
        var error: NSError?
        let regExEmailPattern : String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        var regExVal = NSRegularExpression(pattern: regExEmailPattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let matches = regExVal!.numberOfMatchesInString(email, options: nil, range: NSMakeRange(0, count(email)))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    func dateChanged() {
        var date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.stringFromDate(date)
        self.dateVal = date
    }
    
    
    
    //MARK: Info view
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
            self.promoAccept!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            
//            self.acceptTerms = UIButton(frame: CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, frame.width, 27))
//            self.acceptTerms?.setTitle(NSLocalizedString("signup.info.provacity", comment: ""), forState: UIControlState.Normal)
//            self.acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
//            self.acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//            self.acceptTerms!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
//            self.acceptTerms!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//            self.acceptTerms!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.contentTerms = UIView()
            self.contentTerms!.frame = CGRectMake(0 ,  self.promoAccept!.frame.maxY + 24.0 , self.view.bounds.width ,30)
            
            acceptTerms = UIButton()
            acceptTerms!.frame = CGRectMake(10, -4, 30, 30 )
            acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
            acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
            acceptTerms!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            
            labelTerms = UILabel()
            labelTerms?.frame =  CGRectMake(acceptTerms!.frame.maxX + 4, 0 ,  self.content!.frame.width - (acceptTerms!.frame.width + 15 )  , 30 )
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
            self.acceptSharePersonal!.addTarget(self, action: "changeCons:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.declineSharePersonal = UIButton(frame: CGRectMake(acceptSharePersonal!.frame.maxX, lblPersonalData.frame.maxY + 24.0, 120, 16))
            self.declineSharePersonal?.setTitle(NSLocalizedString("signup.info.share.no", comment: ""), forState: UIControlState.Normal)
            self.declineSharePersonal!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
            self.declineSharePersonal!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
            self.declineSharePersonal!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            self.declineSharePersonal!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            self.declineSharePersonal!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
            self.declineSharePersonal!.addTarget(self, action: "changeCons:", forControlEvents: UIControlEvents.TouchUpInside)
            
            
            self.backButton = UIButton(frame: CGRectMake(16, declineSharePersonal!.frame.maxY + 102.0, 136, 40))
            self.backButton!.setTitle(NSLocalizedString("signup.info.return", comment: ""), forState: UIControlState.Normal)
            self.backButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.backButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.backButton!.backgroundColor = WMColor.loginSignOutButonBgColor
            self.backButton!.layer.cornerRadius = 20.0
            self.backButton!.addTarget(self, action: "backRegistry:", forControlEvents: .TouchUpInside)
            
            self.registryButton = UIButton(frame: CGRectMake(self.backButton!.frame.maxX + 16.0, declineSharePersonal!.frame.maxY + 102.0, 136, 40))
            self.registryButton!.setTitle(NSLocalizedString("signup.info.registry", comment: ""), forState: UIControlState.Normal)
            self.registryButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.registryButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.registryButton!.backgroundColor = WMColor.loginSignInButonBgColor
            self.registryButton!.layer.cornerRadius = 20.0
            self.registryButton!.addTarget(self, action: "registryUser", forControlEvents: .TouchUpInside)
            
            
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
    
    func backRegistry(sender:AnyObject) {
        let infoView = self.generateInfoView(self.content.frame)
        self.content.alpha = 1
        infoView.alpha = 0
        
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

