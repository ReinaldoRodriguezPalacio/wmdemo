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
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.typeField = TypeField.Email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.autocapitalizationType = UITextAutocapitalizationType.None
        self.email!.delegate = self
        self.email!.returnKeyType = .Next
        
        self.password = UIEdgeTextFieldImage()
        self.password?.imageNotSelected = UIImage(named: "fieldPasswordOn")
        self.password?.imageSelected = UIImage(named: "fieldPasswordOn")
        self.password!.setPlaceholderEdge(NSLocalizedString("profile.password",comment:""))
        self.password!.secureTextEntry = true
        self.password!.typeField = TypeField.Password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.delegate = self
        self.password!.returnKeyType = .Done
        
        self.viewbg = UIView()
        self.viewbg!.backgroundColor = WMColor.light_light_gray
       
        //Login button setup
        self.signInButton = UIButton()
        self.signInButton!.setTitle(NSLocalizedString("profile.signIn", comment: ""), forState: UIControlState.Normal)
        self.signInButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.signInButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.signInButton!.backgroundColor = WMColor.green
        self.signInButton!.addTarget(self, action: #selector(LoginController.signIn(_:)), forControlEvents: .TouchUpInside)
        self.signInButton!.layer.cornerRadius = 20.0

        //Button forgot password setup
        self.forgotPasswordButton = UIButton()
        self.forgotPasswordButton!.setTitle(NSLocalizedString("profile.forgot.password", comment: ""), forState: UIControlState.Normal)
        self.forgotPasswordButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.forgotPasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.forgotPasswordButton!.titleLabel!.textAlignment = .Right
        self.forgotPasswordButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        self.forgotPasswordButton?.addTarget(self, action: #selector(LoginController.forgot(_:)), forControlEvents: .TouchUpInside)
       
        self.noAccount = UILabel()
        self.noAccount!.text = NSLocalizedString("profile.no.account",comment:"")
        self.noAccount!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.noAccount!.textColor = WMColor.light_blue
        self.noAccount!.numberOfLines = 0
        self.noAccount!.textAlignment =  .Center
        self.noAccount!.textColor = WMColor.light_light_gray
        
        self.titleLabel = UILabel()
        self.titleLabel!.textColor =  UIColor.whiteColor()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel!.text = "Inicia Sesión"
        self.titleLabel!.textAlignment = NSTextAlignment.Center
        
        self.viewLine = UIView()
        self.viewLine!.backgroundColor = WMColor.light_gray
        
        self.content!.addSubview(self.titleLabel!)
        self.content.backgroundColor = UIColor.clearColor()
      
        self.content!.addSubview(forgotPasswordButton!)
        self.content?.addSubview(viewbg!)
        self.content?.addSubview(email!)
        self.content?.addSubview(password!)
        self.content?.addSubview(signInButton!)
        self.content?.addSubview(noAccount!)
        self.content?.addSubview(viewLine!)
        
        self.content!.backgroundColor = UIColor.clearColor()
        
        self.viewCenter = UIView()
        self.viewCenter!.backgroundColor = UIColor.clearColor()
        self.viewCenter!.clipsToBounds = true
        self.viewCenter.addSubview(self.content!)
        
        self.close = UIButton(type: .Custom)
        self.close!.setImage(UIImage(named: "close"), forState: .Normal)
        self.close!.addTarget(self, action: #selector(LoginController.closeModal), forControlEvents: .TouchUpInside)
        self.close!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.viewCenter!)
        self.view.addSubview(self.close!)
        
        self.loginFacebookButton = UIButton(type: .Custom)
        self.loginFacebookButton.layer.cornerRadius =  20.0
        self.loginFacebookButton!.backgroundColor = UIColor.whiteColor()
        self.loginFacebookButton!.addTarget(self, action: #selector(LoginController.facebookLogin), forControlEvents: .TouchUpInside)
        self.loginFacebookButton!.setImage(UIImage(named: "facebook_login"), forState: .Normal)
        self.content!.addSubview(self.loginFacebookButton)
        
        self.loginGoogleButton = UIButton(type: .Custom)
        self.loginGoogleButton.layer.cornerRadius =  20.0
        self.loginGoogleButton!.backgroundColor = UIColor.whiteColor()
        self.loginGoogleButton!.addTarget(self, action: #selector(LoginController.googleSignIn), forControlEvents: .TouchUpInside)
        self.loginGoogleButton!.setImage(UIImage(named: "google_login"), forState: .Normal)
        self.content!.addSubview(self.loginGoogleButton)
        
        self.loginTwitterButton = UIButton(type: .Custom)
        self.loginTwitterButton.layer.cornerRadius =  20.0
        self.loginTwitterButton!.backgroundColor = UIColor.whiteColor()
        self.loginTwitterButton!.addTarget(self, action: #selector(LoginController.twitterSignIn), forControlEvents: .TouchUpInside)
        self.loginTwitterButton!.setImage(UIImage(named: "twitter_login"), forState: .Normal)
        self.content?.addSubview(loginTwitterButton!)
        
        self.registryButton = UIButton(type: .Custom)
        self.registryButton!.backgroundColor = UIColor.whiteColor()
        self.registryButton!.setImage(UIImage(named: "walmart_login"), forState: .Normal)
        self.registryButton!.addTarget(self, action: #selector(LoginController.registryUser), forControlEvents: .TouchUpInside)
        self.registryButton!.layer.cornerRadius = 20.0
        self.content?.addSubview(registryButton!)
    }
    
    
    override func viewDidAppear(animated: Bool) {
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
        
            self.viewCenter!.frame = CGRectMake((self.view.bounds.width / 2) - (456 / 2) ,0, 456, self.view.bounds.height)
            self.content.frame = CGRectMake( (self.viewCenter!.frame.width / 2) - (320 / 2) , 50 , 320 , bounds.height - 50)
            self.titleLabel!.frame =  CGRectMake(0 , 0, self.content.frame.width , 16)
            self.email?.frame = CGRectMake(leftRightPadding,  40 , self.content.frame.width-(leftRightPadding*2), fieldHeight)
            self.password?.frame = CGRectMake(leftRightPadding, email!.frame.maxY+1, self.email!.frame.width , fieldHeight)
            self.viewLine?.frame = CGRectMake(leftRightPadding, email!.frame.maxY, self.email!.frame.width, 1)
            self.viewbg?.frame = CGRectMake(leftRightPadding, email!.frame.maxY-5, self.email!.frame.width, 10)
            self.forgotPasswordButton?.frame = CGRectMake(self.content.frame.width - 170 , password!.frame.maxY+15, 170 - leftRightPadding, 28)
            self.signInButton?.frame = CGRectMake(leftRightPadding, password!.frame.maxY+56, self.password!.frame.width, 40)
            self.noAccount?.frame = CGRectMake(leftRightPadding, self.signInButton!.frame.maxY + 24, self.password!.frame.width, 20)
            self.loginFacebookButton?.frame = CGRectMake(32,  self.noAccount!.frame.maxY + 24 , 40, 40)
            self.loginGoogleButton?.frame = CGRectMake(self.loginFacebookButton!.frame.maxX + 32,  self.noAccount!.frame.maxY + 24 , 40, 40)
            self.loginTwitterButton?.frame = CGRectMake(self.loginGoogleButton!.frame.maxX + 32,  self.noAccount!.frame.maxY + 24 , 40, 40)
            self.registryButton?.frame = CGRectMake(self.loginTwitterButton!.frame.maxX + 32,  self.noAccount!.frame.maxY + 24 , 40, 40)
            
            self.bgView!.frame = self.view.bounds
            self.close!.frame = CGRectMake(0, 20, 40.0, 40.0)
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserCurrentSession.hasLoggedUser() && self.controllerTo != nil {
            let storyboard = self.loadStoryboardDefinition()
            let vc = storyboard!.instantiateViewControllerWithIdentifier(self.controllerTo)
            self.navigationController!.pushViewController(vc, animated: false)
        }
    }
    
    //MARK: Special functions
    
    /**
     Shows a LoginController on top pf the application view
     
     - returns: new LoginCorntroller
     */
    class func showLogin() -> LoginController! {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = LoginController()
        vc!.addChildViewController(newAlert)
        newAlert.view.frame = vc!.view.bounds
        vc!.view.addSubview(newAlert.view)
        newAlert.didMoveToParentViewController(vc)
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
            self.parentViewController!.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            cloneImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.parentViewController!.view.layer.contents = nil
        }
        let blurredImage = cloneImage!.applyLightEffect()
        self.imageblur = UIImageView()
        self.imageblur!.frame = self.view.bounds
        self.imageblur!.clipsToBounds = true
        self.imageblur!.image = blurredImage
        self.view.addSubview(self.imageblur!)
        self.view.sendSubviewToBack(self.imageblur!)
    }
    
    /**
     Shows SignUpViewController for users registration
     */
    func registryUser() {
        
        if self.signUp == nil{
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CREATE_ACOUNT.rawValue, action:WMGAIUtils.ACTION_OPEN_CREATE_ACOUNT.rawValue , label: "")
            self.signUp = SignUpViewController()
            self.signUp!.view.frame = CGRectMake(self.viewCenter!.frame.width, self.content!.frame.minY, self.content!.frame.width, self.content!.frame.height)
            
            self.signUp.viewClose = {(hidden : Bool) in
                self.close!.hidden = hidden
            }
            
            self.signUp.cancelSignUp = {() in
                self.viewAnimated = true
                UIView.animateWithDuration(0.4, animations: {
                    self.signUp!.view.frame =  CGRectMake(self.viewCenter!.frame.width, self.content!.frame.minY, self.viewCenter!.frame.width, self.view.bounds.height)
                    self.signUp.view.alpha = 0
                    self.content!.frame = CGRectMake((self.viewCenter!.frame.width / 2) - (self.content!.frame.width / 2) , self.content!.frame.minY ,  self.content!.frame.width , self.content!.frame.height)
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
        
        UIView.animateWithDuration(0.4, animations: {
            self.signUp!.view.frame =  CGRectMake((self.viewCenter!.frame.width / 2) - (self.content!.frame.width / 2), self.content!.frame.minY, self.content!.frame.width, self.content!.frame.height)
            self.signUp.view.alpha = 100
            self.content!.frame = CGRectMake(-self.content!.frame.width, 50, self.content!.frame.width ,  self.content!.frame.height)
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
        alertAddress?.beforeAddAddress = {(dictSend:NSDictionary?) in
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
    func signIn(sender:UIButton) {
        signInButton!.enabled = false
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
            signInButton!.enabled = true
        }
    }
    
    /**
     Calls login service
     
     - parameter params:           params to login
     - parameter alertViewService: alert view
     */
    func callService(params:NSDictionary, alertViewService : IPOWMAlertViewController?) {
        let service = LoginService()
        service.callService(params, successBlock:{ (resultCall:NSDictionary?) in
           self.signInButton!.enabled = true
            if self.successCallBack == nil {
                if self.controllerTo != nil  {
                    let storyboard = self.loadStoryboardDefinition()
                    let vc = storyboard!.instantiateViewControllerWithIdentifier(self.controllerTo)
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
                self.signInButton!.enabled = true
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
    func showAddressForm(params:NSDictionary,  alertViewService : IPOWMAlertViewController?) {
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
    func closeAlert(closeModal: Bool, messageSucesss: Bool){
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
        self.view.bringSubviewToFront(self.content)
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
    func viewError(field: UIEdgeTextFieldImage)-> Bool{
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
    func forgot(sender:UIButton) {
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
            
            service.callService(requestParams: service.buildParams(self.email!.text!), successBlock: { (result: NSDictionary) -> Void in
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
    func loginWithEmail(email:String, firstName: String, lastName: String, gender: String, birthDay: String){
        self.email?.text = email
        let service = LoginWithEmailService()
        service.callServiceForSocialApps(service.buildParams(email, password: ""), successBlock:{ (resultCall:NSDictionary?) in
            
            self.signInButton!.enabled = true
            if self.successCallBack == nil {
                if self.controllerTo != nil  {
                    let storyboard = self.loadStoryboardDefinition()
                    let vc = storyboard!.instantiateViewControllerWithIdentifier(self.controllerTo)
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
    func contentSizeForScrollView(sender:AnyObject) -> CGSize{
        return CGSizeMake( content.contentSize.width, content.contentSize.height)
    }
    
    
    //MARK:- TextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let resultingString = text.stringByReplacingCharactersInRange(range, withString: string) as NSString
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if resultingString.rangeOfCharacterFromSet(whitespaceSet).location != NSNotFound {
            return false
        }
        if textField == password {
            return resultingString.length <= 20
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == email { // Switch focus to other text field
            password!.becomeFirstResponder()
        }
        if textField == password {
            self.signIn(signInButton!)
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
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
        if (FBSDKAccessToken.currentAccessToken()) == nil {
            self.view.endEditing(true)
            fbLoginMannager = FBSDKLoginManager()
            fbLoginMannager.logInWithReadPermissions(["public_profile", "email", "user_friends", "user_birthday"], fromViewController: self,  handler: { (result, error) -> Void in
                if error != nil {
                    self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                    self.alertView!.showErrorIcon("Aceptar")
               }else if result.isCancelled {
                    self.fbLoginMannager.logOut()
                    self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                    self.alertView!.showErrorIcon("Aceptar")
                } else {
                    if(result.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
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
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, gender, birthday, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                    self.loginWithEmail(result["email"] as! String, firstName: result["first_name"] as! String, lastName: result["last_name"] as! String, gender: result["gender"] as! String, birthDay:result["birthday"] as? String  == nil ? "" : result["birthday"] as! String)
                }else{
                    self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
                    self.alertView!.showErrorIcon("Aceptar")
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
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            self.loginWithEmail(user.profile.email, firstName: user.profile.givenName, lastName: user.profile.familyName, gender: "", birthDay: "")
        } else {
            self.alertView!.setMessage(NSLocalizedString("Intenta nuevamente",comment:""))
            self.alertView!.showErrorIcon("Aceptar")
        }
    }
    
    //MARK: - Twitter Login
    
    /**
     Twitter Login
     
     - parameter sender: UIButton
     */
    func twitterSignIn(sender: UIButton) {
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
        Twitter.sharedInstance().logInWithMethods([.WebBased]) { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)");
                let client = TWTRAPIClient.clientWithCurrentUser()
                let request = client.URLRequestWithMethod("GET",
                    URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                    parameters: ["include_email": "true", "skip_status": "true"],
                    error: nil)
                
                client.sendTwitterRequest(request) { response, data, connectionError in
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
                        let name = json["name"] as! String
                        let email = json["email"] as? String ?? ""
                        self.loginWithEmail(email, firstName: name, lastName: "", gender: "", birthDay: "")
                    } catch {
                        print("json error: \(error)")
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