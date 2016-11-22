//
//  LoginController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/17/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import TwitterKit

class LoginController : IPOBaseController, UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate, UITextFieldDelegate, GIDSignInUIDelegate,GIDSignInDelegate {
    var close: UIButton?
    var viewCenter : UIView!
    var content: TPKeyboardAvoidingScrollView!
    var titleLabel: UILabel? = nil
    var valueEmail : String? = nil
    var email : UIEdgeTextFieldImage? = nil
    var password : UIEdgeTextFieldImage? = nil
    var viewLine : UIView? = nil
    var viewbg : UIView? = nil
    var registryButton: UIButton?
    var signInButton: UIButton?
    var forgotPasswordButton: UIButton?
    var noAccount : UILabel? = nil
    var controllerTo: String!
    var viewLoad : WMLoadingView!

    var errorView : FormFieldErrorView? = nil
    var closeAlertOnSuccess : Bool = true
    var alertView : IPOWMAlertViewController? = nil
    var successCallBack : (() -> Void)? = nil
    var signUp : SignUpViewController!
    var imageblur : UIImageView? = nil
    var viewAnimated : Bool = false
    var bgView : UIView!
    var fbLoginMannager: FBSDKLoginManager!
    var loginFacebookButton: UIButton!
    var loginGoogleButton: UIButton!
    var loginTwitterButton: UIButton!
    
    var okCancelCallBack : (() -> Void)? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LOGIN.rawValue
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView = UIView()
        self.bgView.backgroundColor = WMColor.light_blue
        self.view.addSubview(bgView)
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self
        
        self.email = UIEdgeTextFieldImage()
        self.email?.imageSelected = UIImage(named: "fieldEmailOn")
        self.email?.imageNotSelected = UIImage(named: "fieldEmailOn")
        self.email!.setPlaceholderEdge(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.emailAddress
        self.email!.typeField = TypeField.email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.autocapitalizationType = UITextAutocapitalizationType.none
        self.email!.delegate = self
        self.email!.returnKeyType = .next
        
        self.password = UIEdgeTextFieldImage()
        self.password?.imageNotSelected = UIImage(named: "fieldPasswordOn")
        self.password?.imageSelected = UIImage(named: "fieldPasswordOn")
        self.password!.setPlaceholderEdge(NSLocalizedString("profile.password",comment:""))
        self.password!.isSecureTextEntry = true
        self.password!.typeField = TypeField.password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.delegate = self
        self.password!.returnKeyType = .done
        
        self.viewbg = UIView()
        self.viewbg!.backgroundColor = WMColor.light_light_gray
       
        //Login button setup
        self.signInButton = UIButton()
        self.signInButton!.setTitle(NSLocalizedString("profile.signIn", comment: ""), for: UIControlState())
        self.signInButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.signInButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.signInButton!.backgroundColor = WMColor.green
        self.signInButton!.addTarget(self, action: #selector(LoginController.signIn(_:)), for: .touchUpInside)
        self.signInButton!.layer.cornerRadius = 20.0

        //Button forgot password setup
        self.forgotPasswordButton = UIButton()
        self.forgotPasswordButton!.setTitle(NSLocalizedString("profile.forgot.password", comment: ""), for: UIControlState())
        self.forgotPasswordButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.forgotPasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.forgotPasswordButton!.titleLabel!.textAlignment = .right
        self.forgotPasswordButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        self.forgotPasswordButton?.addTarget(self, action: #selector(LoginController.forgot(_:)), for: .touchUpInside)
       
        self.noAccount = UILabel()
        self.noAccount!.text = NSLocalizedString("profile.no.account",comment:"")
        self.noAccount!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.noAccount!.textColor = WMColor.light_blue
        self.noAccount!.numberOfLines = 0
        self.noAccount!.textAlignment =  .center
        self.noAccount!.textColor = WMColor.light_light_gray
        
        self.titleLabel = UILabel()
        self.titleLabel!.textColor =  UIColor.white
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel!.text = "Inicia Sesión"
        self.titleLabel!.textAlignment = NSTextAlignment.center
        
        self.viewLine = UIView()
        self.viewLine!.backgroundColor = WMColor.light_gray
        
        self.content!.addSubview(self.titleLabel!)
        self.content.backgroundColor = UIColor.clear
      
        self.content!.addSubview(forgotPasswordButton!)
        self.content?.addSubview(viewbg!)
        self.content?.addSubview(email!)
        self.content?.addSubview(password!)
        self.content?.addSubview(signInButton!)
        self.content?.addSubview(noAccount!)
        self.content?.addSubview(viewLine!)
        
        self.content!.backgroundColor = UIColor.clear
        
        self.viewCenter = UIView()
        self.viewCenter!.backgroundColor = UIColor.clear
        self.viewCenter!.clipsToBounds = true
        self.viewCenter.addSubview(self.content!)
        
        self.close = UIButton(type: .custom)
        self.close!.setImage(UIImage(named: "close"), for: UIControlState())
        self.close!.addTarget(self, action: #selector(LoginController.closeModal), for: .touchUpInside)
        self.close!.backgroundColor = UIColor.clear
        self.view.addSubview(self.viewCenter!)
        self.view.addSubview(self.close!)
        
        self.loginFacebookButton = UIButton(type: .custom)
        self.loginFacebookButton.layer.cornerRadius =  20.0
        self.loginFacebookButton!.backgroundColor = UIColor.white
        self.loginFacebookButton!.addTarget(self, action: #selector(LoginController.facebookLogin), for: .touchUpInside)
        self.loginFacebookButton!.setImage(UIImage(named: "facebook_login"), for: UIControlState())
        self.content!.addSubview(self.loginFacebookButton)
        
        self.loginGoogleButton = UIButton(type: .custom)
        self.loginGoogleButton.layer.cornerRadius =  20.0
        self.loginGoogleButton!.backgroundColor = UIColor.white
        self.loginGoogleButton!.addTarget(self, action: #selector(LoginController.googleSignIn), for: .touchUpInside)
        self.loginGoogleButton!.setImage(UIImage(named: "google_login"), for: UIControlState())
        self.content!.addSubview(self.loginGoogleButton)
        
        self.loginTwitterButton = UIButton(type: .custom)
        self.loginTwitterButton.layer.cornerRadius =  20.0
        self.loginTwitterButton!.backgroundColor = UIColor.white
        self.loginTwitterButton!.addTarget(self, action: #selector(LoginController.twitterSignIn), for: .touchUpInside)
        self.loginTwitterButton!.setImage(UIImage(named: "twitter_login"), for: UIControlState())
        self.content?.addSubview(loginTwitterButton!)
        
        self.registryButton = UIButton(type: .custom)
        self.registryButton!.backgroundColor = UIColor.white
        self.registryButton!.setImage(UIImage(named: "walmart_login"), for: UIControlState())
        self.registryButton!.addTarget(self, action: #selector(LoginController.registryUser), for: .touchUpInside)
        self.registryButton!.layer.cornerRadius = 20.0
        self.content?.addSubview(registryButton!)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if valueEmail != nil {
            self.email?.text = valueEmail
            self.password?.becomeFirstResponder()
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !viewAnimated {
            super.viewWillLayoutSubviews()
            let bounds = self.view.bounds
            let fieldHeight  : CGFloat = CGFloat(44)
            let leftRightPadding  : CGFloat = CGFloat(15)
      
            if self.imageblur == nil {
                //self.generateBlurImage()
            }
        
            self.viewCenter!.frame = CGRect(x: (self.view.bounds.width / 2) - (456 / 2) ,y: 0, width: 456, height: self.view.bounds.height)
            self.content.frame = CGRect( x: (self.viewCenter!.frame.width / 2) - (320 / 2) , y: 50 , width: 320 , height: bounds.height - 50)
            self.titleLabel!.frame =  CGRect(x: 0 , y: 0, width: self.content.frame.width , height: 16)
            self.email?.frame = CGRect(x: leftRightPadding,  y: 40 , width: self.content.frame.width-(leftRightPadding*2), height: fieldHeight)
            self.password?.frame = CGRect(x: leftRightPadding, y: email!.frame.maxY+1, width: self.email!.frame.width , height: fieldHeight)
            self.viewLine?.frame = CGRect(x: leftRightPadding, y: email!.frame.maxY, width: self.email!.frame.width, height: 1)
            self.viewbg?.frame = CGRect(x: leftRightPadding, y: email!.frame.maxY-5, width: self.email!.frame.width, height: 10)
            self.forgotPasswordButton?.frame = CGRect(x: self.content.frame.width - 170 , y: password!.frame.maxY+15, width: 170 - leftRightPadding, height: 28)
            self.signInButton?.frame = CGRect(x: leftRightPadding, y: password!.frame.maxY+56, width: self.password!.frame.width, height: 40)
            self.noAccount?.frame = CGRect(x: leftRightPadding, y: self.signInButton!.frame.maxY + 24, width: self.password!.frame.width, height: 20)
            
            if self.registryButton!.isHidden {
                self.loginFacebookButton?.frame = CGRect(x: 68,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
                self.loginGoogleButton?.frame = CGRect(x: self.loginFacebookButton!.frame.maxX + 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
                self.loginTwitterButton?.frame = CGRect(x: self.loginGoogleButton!.frame.maxX + 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
                self.registryButton?.frame = CGRect(x: self.loginTwitterButton!.frame.maxX + 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
            }else{
                self.loginFacebookButton?.frame = CGRect(x: 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
                self.loginGoogleButton?.frame = CGRect(x: self.loginFacebookButton!.frame.maxX + 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
                self.loginTwitterButton?.frame = CGRect(x: self.loginGoogleButton!.frame.maxX + 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
                self.registryButton?.frame = CGRect(x: self.loginTwitterButton!.frame.maxX + 32,  y: self.noAccount!.frame.maxY + 24 , width: 40, height: 40)
            }
            
            
            self.bgView!.frame = self.view.bounds
            self.close!.frame = CGRect(x: 0, y: 20, width: 40.0, height: 40.0)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserCurrentSession.hasLoggedUser() && self.controllerTo != nil {
            let storyboard = self.loadStoryboardDefinition()
            let vc = storyboard!.instantiateViewController(withIdentifier: self.controllerTo)
            self.navigationController!.pushViewController(vc, animated: false)
        }
    }
    
    //MARK: Special functions
    
    /**
     Shows a LoginController on top pf the application view
     
     - returns: new LoginCorntroller
     */
    class func showLogin() -> LoginController! {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = LoginController()
        vc!.addChildViewController(newAlert)
        newAlert.view.frame = vc!.view.bounds
        vc!.view.addSubview(newAlert.view)
        newAlert.didMove(toParentViewController: vc)
        //vc!.addChildViewController(newAlert)
        newAlert.view.tag = 5000
        return newAlert
    }
    
    /**
     Generates blur image
     */
    func generateBlurImage() {
        var cloneImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 1.0);
            self.parent!.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            cloneImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.parent!.view.layer.contents = nil
        }
        let blurredImage = cloneImage!.applyLightEffect()
        self.imageblur = UIImageView()
        self.imageblur!.frame = self.view.bounds
        self.imageblur!.clipsToBounds = true
        self.imageblur!.image = blurredImage
        self.view.addSubview(self.imageblur!)
        self.view.sendSubview(toBack: self.imageblur!)
    }
    
    /**
     Shows SignUpViewController for users registration
     */
    func registryUser() {
        
        if self.signUp == nil{
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CREATE_ACOUNT.rawValue, action:WMGAIUtils.ACTION_OPEN_CREATE_ACOUNT.rawValue , label: "")
            self.signUp = SignUpViewController()
            self.signUp!.view.frame = CGRect(x: self.viewCenter!.frame.width, y: self.content!.frame.minY, width: self.content!.frame.width, height: self.content!.frame.height)
            
            self.signUp.viewClose = {(hidden : Bool) in
                self.close!.isHidden = hidden
            }
            
            self.signUp.cancelSignUp = {() in
                self.viewAnimated = true
                UIView.animate(withDuration: 0.4, animations: {
                    self.signUp!.view.frame =  CGRect(x: self.viewCenter!.frame.width, y: self.content!.frame.minY, width: self.viewCenter!.frame.width, height: self.view.bounds.height)
                    self.signUp.view.alpha = 0
                    self.content!.frame = CGRect(x: (self.viewCenter!.frame.width / 2) - (self.content!.frame.width / 2) , y: self.content!.frame.minY ,  width: self.content!.frame.width , height: self.content!.frame.height)
                    self.content!.alpha = 100
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.viewAnimated = false
                        }
                })
            }
            self.signUp.successCallBack =  {() in
                let service = LoginService()
                let params  = service.buildParams(self.signUp.email!.text!, password: self.signUp.password!.text!)
                self.alertView = self.signUp.alertView!
                self.callService(params, alertViewService:self.signUp.alertView!)
            }// self.successCallBack
            self.signUp.closeModal = {() in
                self.closeModal()
            }
            self.viewCenter!.addSubview(signUp.view)
        }//if self.signUp == nil{
        
        signUp.view.alpha = 0
        self.viewAnimated = true
        
        UIView.animate(withDuration: 0.4, animations: {
            self.signUp!.view.frame =  CGRect(x: (self.viewCenter!.frame.width / 2) - (self.content!.frame.width / 2), y: self.content!.frame.minY, width: self.content!.frame.width, height: self.content!.frame.height)
            self.signUp.view.alpha = 100
            self.content!.frame = CGRect(x: -self.content!.frame.width, y: 50, width: self.content!.frame.width ,  height: self.content!.frame.height)
            self.content!.alpha = 0
            }, completion: {(bool : Bool) in
                if bool {
                    self.viewAnimated = false
                }
        })
        
    }
   
    
    
    //TODO: Borrar
    func showAddressView() {
        var alertAddress: GRFormAddressAlertView? = nil
        
        if alertAddress == nil {
            alertAddress = GRFormAddressAlertView.initAddressAlert()!
        }
        alertAddress?.showAddressAlert()
        alertAddress?.beforeAddAddress = {(dictSend:[String:Any]?) in
            alertAddress?.registryAddress(dictSend)
            self.alertView!.close()
        }
        
        alertAddress?.alertSaveSuccess = {() in
            alertAddress!.removeFromSuperview()
            self.successCallBack?()
           // backRegistry(self.backButton!)
        }
        
        alertAddress?.cancelPress = {() in
            print("")
            alertAddress!.closePicker()
        }
    }

    
    /**
     Close LoginController and removes it from parent view
     */
    func closeModal() {
        self.imageblur?.image = nil
        self.removeFromParentViewController()
        self.successCallBack = nil
        self.okCancelCallBack  = nil
        self.view.removeFromSuperview()
    }
    
    /**
     Sign user
     
     - parameter sender: UIButton
     */
    func signIn(_ sender:UIButton) {
        signInButton!.isEnabled = false
        if validateUser() {
         
            self.view.endEditing(true)
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                if !self.closeAlertOnSuccess && UserCurrentSession.hasLoggedUser() {
                  self.alertView?.showOkButton("Cancelar",  colorButton:WMColor.blue)
                }
            }
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LOGIN.rawValue, action:WMGAIUtils.ACTION_LOGIN_USER.rawValue, label:"")
        
            self.alertView?.okCancelCallBack = self.okCancelCallBack
            self.alertView!.afterRemove = {() -> Void in
                self.alertView = nil
            }
            self.alertView!.setMessage(NSLocalizedString("profile.message.entering",comment:""))
            
            let service = LoginService()
            let emails = email!.text
            let params  = service.buildParams(emails!.trim(), password: password!.text!)
            self.callService(params, alertViewService: self.alertView)
        }else{
            signInButton!.isEnabled = true
        }
    }
    
    /**
     Calls login service
     
     - parameter params:           params to login
     - parameter alertViewService: alert view
     */
    func callService(_ params:[String:Any], alertViewService : IPOWMAlertViewController?) {
        let service = LoginService()
        service.callService(params, successBlock:{ (resultCall:[String:Any]?) in
           self.signInButton!.isEnabled = true
            if self.successCallBack == nil {
                if self.controllerTo != nil  {
                    let storyboard = self.loadStoryboardDefinition()
                    let vc = storyboard!.instantiateViewController(withIdentifier: self.controllerTo)
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }else {
                self.alertView = alertViewService
                if self.closeAlertOnSuccess {
                    if alertViewService != nil {
                        alertViewService!.setMessage(NSLocalizedString("profile.login.welcome",comment:""))
                        alertViewService!.showDoneIcon()
                    }
                }
                self.successCallBack!()
            }
            }
            , errorBlock: {(error: NSError) in
                print("error")
                var strToUse = NSLocalizedString("password.incorrect",comment:"")
                if error.code == -3 {
                    strToUse = error.localizedDescription
                }
                self.signInButton!.isEnabled = true
                alertViewService!.okCancelCallBack = nil
                if alertViewService != nil {
                    alertViewService!.setMessage(strToUse)
                    alertViewService!.showErrorIcon("Ok")
                }
        })
    }
    
    /**
     Shows address form
     
     - parameter params:           params to login
     - parameter alertViewService: alert view
     */
    func showAddressForm(_ params:[String:Any],  alertViewService : IPOWMAlertViewController?) {
        let alertAddress = GRFormAddressAlertView.initAddressAlert()!
        alertAddress.showAddressAlert()
        alertAddress.alertSaveSuccess = {() in
            self.callService(params, alertViewService: alertViewService)
            if self.successCallBack == nil {
                self.successCallBack!()
            }
            alertAddress.removeFromSuperview()
        }

        alertAddress.alertClose = {() in
            print("Close")
        }
        alertAddress.cancelPress = {() in
            alertAddress.removeFromSuperview()
            if alertViewService != nil {
                alertViewService!.setMessage("Es necesario capturar una dirección")
                alertViewService!.showErrorIcon("Ok")
            }
        }
    }
    
    /**
     Closes alert view and modal view
     
     - parameter closeModal:     Bool
     - parameter messageSucesss: Bool
     */
    func closeAlert(_ closeModal: Bool, messageSucesss: Bool){
        if self.alertView != nil {
            if messageSucesss {
                self.alertView!.setMessage(NSLocalizedString("profile.login.welcome",comment:""))
                self.alertView!.showDoneIcon()
            }
            if closeModal {
                self.closeModal()
            }
        }
    }
    
    /**
     Validates user data
     
     - returns: Bool
     */
    func validateUser () -> Bool{
        self.view.bringSubview(toFront: self.content)
        var error = viewError(self.email!)
        if !error{
            error = viewError(self.password!)
        }
        if error{
            return false
        }
        return true
    }
    
    /**
     Shows view error
     
     - parameter field: field from show error
     
     - returns: Bool
     */
    func viewError(_ field: UIEdgeTextFieldImage)-> Bool{
        let message = field.validate()
        if message.characters.count > 0 {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField ,  message: message ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        }
        return false
    }
    
    /**
     Calls forgot password service
     - parameter sender: UIButton
     */
    func forgot(_ sender:UIButton) {
        self.textFieldDidEndEditing(self.email!)
        let error = viewError(self.email!)
        if !error {
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_FORGOT_PASSWORD.rawValue, action: WMGAIUtils.ACTION_RECOVER_PASSWORD.rawValue, label:"")
            
            self.view.endEditing(true)
            if sender.tag == 100 {
                 self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"forgot_waiting"),imageDone:UIImage(named:"forgot_passwordOk"),imageError:UIImage(named:"forgot_passwordError"))
            }else{
                 self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"forgot_waiting"),imageDone:UIImage(named:"forgot_passwordOk"),imageError:UIImage(named:"forgot_passwordError"))
            }

            self.alertView!.setMessage(NSLocalizedString("profile.message.sending",comment:""))
            let service = ForgotPasswordService()
            
            service.callService(requestParams: service.buildParams(self.email!.text!) as AnyObject, successBlock: { (result: [String:Any]) -> Void in
                if let message = result["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                print("successBlock")
            }) { (error:NSError) -> Void in
                print("error")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        }
        
    }
    
    /**
     Logs user with email
     
     - parameter email:     user email
     - parameter firstName: user first name
     - parameter lastName:  user last name
     - parameter gender:    user gender
     - parameter birthDay:  user birth day
     */
    func loginWithEmail(_ email:String, firstName: String, lastName: String, gender: String, birthDay: String){
        self.email?.text = email
        let service = LoginWithEmailService()
        service.callServiceForSocialApps(service.buildParams(email, password: ""), successBlock:{ (resultCall:[String:Any]?) in
            
            self.signInButton!.isEnabled = true
            if self.successCallBack == nil {
                if self.controllerTo != nil  {
                    let storyboard = self.loadStoryboardDefinition()
                    let vc = storyboard!.instantiateViewController(withIdentifier: self.controllerTo)
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }else {
                if self.closeAlertOnSuccess {
                    if self.alertView != nil {
                        self.alertView!.setMessage(NSLocalizedString("profile.login.welcome",comment:""))
                        self.alertView!.showDoneIcon()
                    }
                }
                self.successCallBack?()
            }
            
            }, errorBlock: {(error: NSError) in
                self.fbLoginMannager = FBSDKLoginManager()
                self.fbLoginMannager.logOut()
                self.alertView!.close()
                self.registryUser()
                self.signUp.email?.text = email
                self.signUp.name?.text = firstName
                self.signUp.lastName?.text = lastName
                //   Se eliminan temporalmente
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "MM/dd/yyyy"
                //                if birthDay != ""{
                //                    let date = dateFormatter.dateFromString(birthDay)
                //                    self.signUp.inputBirthdateView?.date = date!
                //                    dateFormatter.dateFormat = "d MMMM yyyy"
                //                    self.signUp.birthDate!.text = dateFormatter.stringFromDate(date!)
                //                    self.signUp.dateVal = date
                //                }
                //                if(gender == "male"){
                //                   self.signUp.maleButton?.selected = true
                //                }else{
                //                    self.signUp.femaleButton?.selected = true
                //                }
        })
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize{
        return CGSize( width: content.contentSize.width, height: content.contentSize.height)
    }
    
    
    //MARK:- TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let resultingString = text.replacingCharacters(in: range, with: string) as NSString
        let whitespaceSet = CharacterSet.whitespaces
        if resultingString.rangeOfCharacter(from: whitespaceSet).location != NSNotFound {
            return false
        }
        if textField == password {
            return resultingString.length <= 20
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == email { // Switch focus to other text field
            password!.becomeFirstResponder()
        }
        if textField == password {
            self.signIn(signInButton!)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
            }
        }
    }
    //MARK: - Facebook
    
    /**
     Facebook login
     */
    func facebookLogin(){
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        if !self.closeAlertOnSuccess {
            self.alertView?.showOkButton("Cancelar",  colorButton:WMColor.blue)
        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LOGIN.rawValue, action:WMGAIUtils.ACTION_LOGIN_USER.rawValue, label:"")
        
        self.alertView?.okCancelCallBack = self.okCancelCallBack
        self.alertView!.afterRemove = {() -> Void in
            self.alertView = nil
        }
        self.alertView!.setMessage(NSLocalizedString("profile.message.entering",comment:""))
        if (FBSDKAccessToken.current()) == nil {
            self.view.endEditing(true)
            fbLoginMannager = FBSDKLoginManager()
            fbLoginMannager.logIn(withReadPermissions: ["public_profile", "email", "user_friends", "user_birthday"], from: self,  handler: { (result, error) -> Void in
                if error != nil {
                    self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                    self.alertView!.showErrorIcon("Aceptar")
               }else if (result?.isCancelled)! {
                    self.fbLoginMannager.logOut()
                    self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                    self.alertView!.showErrorIcon("Aceptar")
                } else {
                    if(result?.grantedPermissions.contains("email"))!
                    {
                        self.getFBUserData()
                        self.fbLoginMannager.logOut()
                    }else{
                        self.alertView!.setMessage(NSLocalizedString("Para continuar es necesario compartir tu correo",comment:""))
                        self.alertView!.showErrorIcon("Aceptar")
                        self.deleteFacebookPermission()
                        self.fbLoginMannager.logOut()
                    }
                }
            })
        }else {
            self.getFBUserData()
            self.fbLoginMannager = FBSDKLoginManager()
            self.fbLoginMannager.logOut()
        }
    }
    
    /**
     Gets user data from Facebook
     */
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, gender, birthday, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print(result!)
                    let resultDict = result as! [String: Any]
                    self.loginWithEmail(resultDict["email"] as! String, firstName: resultDict["first_name"] as! String, lastName: resultDict["last_name"] as! String, gender: resultDict["gender"] as! String, birthDay:resultDict["birthday"] as? String  == nil ? "" : resultDict["birthday"] as! String)
                }else{
                    self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                    self.alertView!.showErrorIcon("Aceptar")
                }
            })
        }
    }
    
    /**
     Delete Facebook Permissions
     */
    func deleteFacebookPermission(){
        if((FBSDKAccessToken.current()) != nil){
            let facebookRequest: FBSDKGraphRequest! = FBSDKGraphRequest(graphPath: "/me/permissions", parameters: nil, httpMethod: "DELETE")
            facebookRequest.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) -> Void in
                if(error == nil && result != nil){
                    print("Permission successfully revoked. This app will no longer post to Facebook on your behalf.")
                    print("result = \(result)")
                } else {
                    if let error: NSError = error as NSError? {
                        if let errorString = error.userInfo["error"] as? String {
                            print("errorString variable equals: \(errorString)")
                        }
                    } else {
                        print("No value for error key")
                    }
                }
            })
        }
    }
    
    //MARK: - Google SignIn
    
    /**
     Google login
     */
    func googleSignIn(){
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        if !self.closeAlertOnSuccess {
            self.alertView?.showOkButton("Cancelar",  colorButton:WMColor.blue)
        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LOGIN.rawValue, action:WMGAIUtils.ACTION_LOGIN_USER.rawValue, label:"")
        
        self.alertView?.okCancelCallBack = self.okCancelCallBack
        self.alertView!.afterRemove = {() -> Void in
            self.alertView = nil
        }
        self.alertView!.setMessage(NSLocalizedString("profile.message.entering",comment:""))
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!,
                present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
                dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                withError error: Error!) {
        if (error == nil) {
            self.loginWithEmail(user.profile.email, firstName: user.profile.givenName, lastName: user.profile.familyName, gender: "", birthDay: "")
             GIDSignIn.sharedInstance().signOut()
        } else {
            self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
            self.alertView!.showErrorIcon("Aceptar")
             GIDSignIn.sharedInstance().signOut()
        }
    }
    
    //MARK: - Twitter Login
    
    /**
     Twitter Login
     
     - parameter sender: UIButton
     */
    func twitterSignIn(_ sender: UIButton) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        if !self.closeAlertOnSuccess {
            self.alertView?.showOkButton("Cancelar",  colorButton:WMColor.blue)
        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LOGIN.rawValue, action:WMGAIUtils.ACTION_LOGIN_USER.rawValue, label:"")
        
        self.alertView?.okCancelCallBack = self.okCancelCallBack
        self.alertView!.afterRemove = {() -> Void in
            self.alertView = nil
        }
        self.alertView!.setMessage(NSLocalizedString("profile.message.entering",comment:""))
        Twitter.sharedInstance().logIn(withMethods: [.webBased]) { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)");
                let client = TWTRAPIClient.withCurrentUser()
                let request = client.urlRequest(withMethod: "GET",
                    url: "https://api.twitter.com/1.1/account/verify_credentials.json",
                    parameters: ["include_email": "true", "skip_status": "true"],
                    error: nil)
                
                client.sendTwitterRequest(request) { response, data, connectionError in
                    if data != nil {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                            let name = json["name"] as? String ?? ""
                            let email = json["email"] as? String ?? ""
                            self.loginWithEmail(email, firstName: name, lastName: "", gender: "", birthDay: "")
                            //let signedInUserID = TWTRAPIClient.clientWithCurrentUser().userID
                            //Twitter.sharedInstance().sessionStore.logOutUserID(signedInUserID!)
                        } catch {
                            print("json error: \(error)")
                            self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                            self.alertView!.showErrorIcon("Aceptar")
                        }
                    }else{
                        self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                        self.alertView!.showErrorIcon("Aceptar")
                    }
                }
            } else {
                self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                self.alertView!.showErrorIcon("Aceptar")
            }
        }
    }
}
