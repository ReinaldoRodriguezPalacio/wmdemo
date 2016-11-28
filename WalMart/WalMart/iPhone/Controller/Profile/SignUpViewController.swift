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
    var viewClose : ((_ hidden: Bool ) -> Void)? = nil
    var titleLabel: UILabel? = nil
    var errorView : FormFieldErrorView? = nil
    var previewHelp : PreviewHelpViewController? = nil
    var alertView : IPOWMAlertViewController? = nil
    var alertAddress : GRFormAddressAlertView? = nil
    
    var maleButton: UIButton?
    var femaleButton: UIButton?
    var dateFmt: DateFormatter?
    var dateVal : Date? = nil
    var closeModal : (() -> Void)? = nil
    
    var gPhoneNumber = "";
    
    var sAddredssForm : FormSuperAddressView!

    var aPhoneHomeNumber:String = ""
    var aPhoneWorkNumber:String = ""
    var aCellPhone:String = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SIGNUP.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sAddredssForm = GRFormSuperAddressView()
        
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.scrollDelegate = self
        self.content.delegate = self
        //let checkTermOff = UIImage(named:"checkTermOff")
        //let checkTermOn = UIImage(named:"checkTermOn")
        
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
        self.inputBirthdateView!.addTarget(self, action: #selector(SignUpViewController.dateChanged), for: .valueChanged)
        self.birthDate!.inputView = self.inputBirthdateView!
        self.birthDate!.inputAccessoryView = viewAccess
//        self.dateChanged()
        
        
        
        self.maleButton = UIButton()
        self.maleButton?.setTitle(NSLocalizedString("signup.male", comment: ""), for: UIControlState())
        self.maleButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.maleButton!.setImage(UIImage(named:"checkTermOn"), for: UIControlState.selected)
        self.maleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.maleButton?.addTarget(self, action: #selector(SignUpViewController.changeMF(_:)), for: UIControlEvents.touchUpInside)
        self.maleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.maleButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        
        self.femaleButton = UIButton()
        self.femaleButton?.setTitle(NSLocalizedString("signup.female", comment: ""), for: UIControlState())
        self.femaleButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.femaleButton!.setImage(UIImage(named:"checkTermOn"), for: UIControlState.selected)
        self.femaleButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.femaleButton?.addTarget(self, action: #selector(SignUpViewController.changeMF(_:)), for: UIControlEvents.touchUpInside)
        self.femaleButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
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
        
        //labelTerms!.textColor = UIColor.whiteColor()
        
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
        self.birthDate?.frame = CGRect(x: leftRightPadding,  y: confirmPassword!.frame.maxY + 8, width: self.view.bounds.width - (leftRightPadding*2), height: fieldHeight)
        
        
        
        
        self.femaleButton!.frame = CGRect(x: 84,  y: birthDate!.frame.maxY + 15,  width: 76 , height: fieldHeight)
        self.maleButton!.frame = CGRect(x: self.femaleButton!.frame.maxX,  y: birthDate!.frame.maxY + 15, width: 76 , height: fieldHeight)
        
        self.cancelButton!.frame = CGRect(x: leftRightPadding,  y: maleButton!.frame.maxY + 15,  width: (self.email!.frame.width / 2) - 5 , height: fieldHeight)
        self.continueButton!.frame = CGRect(x: self.cancelButton!.frame.maxX + 10 , y: self.cancelButton!.frame.minY ,  width: self.cancelButton!.frame.width, height: fieldHeight)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.continueButton!.frame.maxY + 40)
    }
    
    func changeMF(_ sender:UIButton) {
        if sender == self.maleButton {
            self.maleButton?.isSelected = true
            self.femaleButton?.isSelected = false
        } else if sender == self.femaleButton  {
            self.maleButton?.isSelected = false
            self.femaleButton?.isSelected = true
        }
        
    }
    
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = !(sender.isSelected)
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
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
          return CGSize(width: self.view.frame.width, height: content.contentSize.height)
    }
    
    func textFieldDidEndEditingSW(_ textField: UITextField!) {
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
    
    func textFieldDidBeginEditingSW(_ textField: UITextView!) {
        if errorView != nil && errorView!.focusError == nil {
            errorView?.removeFromSuperview()
            errorView!.focusError = nil
            errorView = nil
        }
//        acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//        acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
    }
    
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
    
    func closeNoticePrivacy() {
        self.previewHelp!.view.removeFromSuperview()
        self.close!.removeFromSuperview()
        self.viewClose!(false)
        self.continueButton!.isHidden = false
        self.cancelButton!.isHidden = false

    }
    
    func cancelRegistry(_ sender:UIButton) {
        self.cancelSignUp!()
    }
    
    func continueToInfo() {
        self.view.endEditing(true)
        birthDate!.resignFirstResponder()
        
        if validateUser() {
            let infoView = self.generateInfoView(self.content.frame)
            self.content.alpha = 0
            infoView.alpha = 1
        } else {
            // Event -- Error Registration
            if let errorView = self.errorView {
                BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(errorView.errorLabel.text!, stepError: "Datos personales")
            }
        }
     
    }
    
    func registryUser() {
        
        self.view.endEditing(true)
        if validateTerms() {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SIGNUP.rawValue,action: WMGAIUtils.ACTION_SAVE_SIGNUP.rawValue, label: "")
            
            let service = SignUpService()
            
            let dateFmtBD = DateFormatter()
            dateFmtBD.dateFormat = "dd/MM/yyyy"
            
            let dateOfBirth = dateFmtBD.string(from: self.dateVal!)
            let gender = femaleButton!.isSelected ? "Female" : "Male"
            let allowTransfer = "\(self.acceptSharePersonal!.isSelected)"
            let allowPub = "\(self.promoAccept!.isSelected)"

            if alertAddress == nil {
                alertAddress = GRFormAddressAlertView.initAddressAlert()!
            }
            
            alertAddress?.showAddressAlert()
            alertAddress?.sAddredssForm.isSignUp = true
            alertAddress?.beforeAddAddress = {(dictSend:[String:Any]?) in
                
                self.view.endEditing(true)
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))

                
                self.aPhoneHomeNumber =  self.alertAddress!.sAddredssForm.getPhoneHomeNumber()
                self.aPhoneWorkNumber =  self.alertAddress!.sAddredssForm.getPhoneWorkNumber()
                self.aCellPhone       =  self.alertAddress!.sAddredssForm.getCellPhone()
                
                let params = service.buildParamsWithMembership(self.email!.text!, password:  self.password!.text!, name: self.name!.text!, lastName: self.lastName!.text!,allowMarketingEmail:allowPub,birthdate:dateOfBirth,gender:gender,allowTransfer:allowTransfer,phoneHomeNumber:self.aPhoneHomeNumber,phoneWorkNumber:self.aPhoneWorkNumber,cellPhone:self.aCellPhone)

                service.callService(params,  successBlock:{ (resultCall:[String:Any]?) in
                   
                    // Event -- Succesful Registration
                    BaseController.sendAnalyticsSuccesfulRegistration()
                    
                    let login = LoginService()
                    login.callService(login.buildParams(self.email!.text!, password: self.password!.text!), successBlock: { (dict:[String:Any]) -> Void in
                        
                        self.alertAddress?.registryAddress(dictSend)
                        
                    }, errorBlock: { (error:NSError) -> Void in
                        self.alertView!.close()
                        self.alertAddress?.registryAddress(dictSend)
                        //BaseController.sendTuneAnalytics(TUNE_EVENT_REGISTRATION, email:self.email!.text!, userName: self.email!.text!, gender:gender, idUser: "", itesShop: nil,total:0,refId:"")
                        // Event -- Error Registration
                        BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(error.localizedDescription, stepError: "Datos personales")
                    })
                    
                }, errorBlock: {(error: NSError) in
                    self.backRegistry(self.backButton!)
                    self.alertAddress?.removeFromSuperview()
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    
                    // Event -- Error Registration
                    BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(error.localizedDescription, stepError: "Datos personales")
                    
                })
            }
                
            alertAddress?.alertSaveSuccess = {() in
                self.alertAddress?.removeFromSuperview()
                self.alertView!.showDoneIcon()
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
                self.successCallBack?()
            }
            
            alertAddress?.cancelPress = {() in
                print("")
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
        if !maleButton!.isSelected && !femaleButton!.isSelected {
            if self.errorView == nil {
                self.errorView = FormFieldErrorView()
            }
            self.presentMessageTerms(self.femaleButton!, message: NSLocalizedString("field.validate.minmaxlength.gender", comment: ""), errorView: self.errorView!)
            return false
        }
        if !error{

            self.errorView?.removeFromSuperview()
        return true
        }
        
        return true
    }
    
    func validateTerms() -> Bool {
        
        if !acceptSharePersonal!.isSelected && !declineSharePersonal!.isSelected {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"user_error"))
            let msgInventory = "Para poder continuar, es necesario nos indique si está, o no, de acuerdo en transferir sus datos personales a terceros"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("Ok",comment:""))
            
            // Event -- Error Registration
            BaseController.sendAnalyticsUnsuccesfulRegistrationWithError("Datos personales a terceros, no indicado", stepError: "Información legal")
            
            return false
        }
        if !acceptTerms!.isSelected {
            if self.errorView == nil {
                self.errorView = FormFieldErrorView()
            }
            self.presentMessageTerms(self.acceptTerms!, message: NSLocalizedString("signup.validate.terms.conditions", comment: ""), errorView: self.errorView!)
            
            // Event -- Error Registration
            BaseController.sendAnalyticsUnsuccesfulRegistrationWithError("Términos y condiciones no aceptados", stepError: "Información legal")
            
            return false

        }
        return true
    }
    
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
//                if bool {
//                    self.acceptTerms!.setImage(UIImage(named:"checkTermError"), forState: UIControlState.Normal)
//                }
        })
    }
    
    class func presentMessage(_ field: UITextField, nameField:String,  message: String , errorView : FormFieldErrorView, becomeFirstResponder: Bool){
        errorView.frame = CGRect(x: field.frame.minX - 5, y: 0, width: field.frame.width, height: field.frame.height )
        errorView.focusError = field
        if field.frame.minX < 20 {
            //errorView.setValues(280, strLabel:nameField, strValue: message)
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
    
    class func isValidEmail(_ email: String ) -> Bool{

        let alphanumericset = CharacterSet(charactersIn: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890._%+-@").inverted
        if email.rangeOfCharacter(from: alphanumericset) != nil {
            return false
        }
        
        let regExEmailPattern : String = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"//"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
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

//    func isValidName (name: String) -> Bool{
//    
//        
//        let alphanumericset = NSCharacterSet(charactersInString: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ").invertedSet
//        if let contains = name.rangeOfCharacterFromSet(alphanumericset) {
//        }
//        
//        let regExEmailPattern : String = "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ"
//        var regExVal: NSRegularExpression?
//        do {
//            regExVal = try NSRegularExpression(pattern: regExEmailPattern, options: NSRegularExpressionOptions.CaseInsensitive)
//        } catch {
//            regExVal = nil
//        }
//        let matches = regExVal!.numberOfMatchesInString(name, options: [], range: NSMakeRange(0, name.characters.count))
//        
//        if matches > 0 {
//            return true
//        }
//        return false
//    }

    func dateChanged() {
        let date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.string(from: date)
        self.dateVal = date
    }
    
    //MARK: Info view
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
            
//            self.acceptTerms = UIButton(frame: CGRectMake(16, self.promoAccept!.frame.maxY + 24.0, frame.width, 27))
//            self.acceptTerms?.setTitle(NSLocalizedString("signup.info.provacity", comment: ""), forState: UIControlState.Normal)
//            self.acceptTerms!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
//            self.acceptTerms!.setImage(UIImage(named:"checkTermOn"), forState: UIControlState.Selected)
//            self.acceptTerms!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
//            self.acceptTerms!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//            self.acceptTerms!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            
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
            
            //var valueItem = NSMutableAttributedString()
            let valuesDescItem = NSMutableAttributedString()
            let attrStringLab = NSAttributedString(string: NSLocalizedString("signup.info.provacity", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName:UIColor.white])
            valuesDescItem.append(attrStringLab)
            let attrStringVal = NSAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName:UIColor.white])
            valuesDescItem.append(attrStringVal)
            valuesDescItem.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, valuesDescItem.length))
            labelTerms!.attributedText = valuesDescItem
            labelTerms!.textColor = UIColor.white
            
            //viewTap = UIView()
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
    
    func backRegistry(_ sender:AnyObject) {
        let infoView = self.generateInfoView(self.content.frame)
        self.content.alpha = 1
        infoView.alpha = 0
        
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


