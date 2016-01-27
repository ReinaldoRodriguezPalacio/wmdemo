//
//  LoginController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/17/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import Tune

class LoginController : IPOBaseController, UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate, UITextFieldDelegate {
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
    var signUpMG : SignUpMGViewController!
    var imageblur : UIImageView? = nil
    var viewAnimated : Bool = false
    var bgView : UIView!
    var addressViewController : AddressViewController!
    var loginFacebookButton: UIButton!
	var isMGLogin =  false
    var fbLoginMannager: FBSDKLoginManager!
    
    var okCancelCallBack : (() -> Void)? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LOGIN.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView = UIView()
        self.bgView.backgroundColor = WMColor.productAddToCartBg
        self.view.addSubview(bgView)
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_LOGIN.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }

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
        //self.password!.minLength = 5
        //self.password!.maxLength = 15
        
        self.viewbg = UIView()
        self.viewbg!.backgroundColor = WMColor.loginFieldBgColor
       
        //Login button setup
        registryButton = UIButton()
        registryButton!.setTitle(NSLocalizedString("profile.create.an.account", comment: ""), forState: UIControlState.Normal)
        registryButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registryButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        registryButton!.backgroundColor = WMColor.loginSignOutButonBgColor
        registryButton!.layer.cornerRadius = 20.0
        registryButton?.addTarget(self, action: "registryUser", forControlEvents: .TouchUpInside)
  
        signInButton = UIButton()
        signInButton!.setTitle(NSLocalizedString("profile.signIn", comment: ""), forState: UIControlState.Normal)
        signInButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signInButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        signInButton!.backgroundColor = WMColor.loginSignInButonBgColor
        signInButton!.addTarget(self, action: "signIn:", forControlEvents: .TouchUpInside)
        signInButton!.layer.cornerRadius = 20.0

        //Button forgot password setup
        forgotPasswordButton = UIButton()
        forgotPasswordButton!.setTitle(NSLocalizedString("profile.forgot.password", comment: ""), forState: UIControlState.Normal)
        forgotPasswordButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        forgotPasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        forgotPasswordButton!.titleLabel!.textAlignment = .Right
        forgotPasswordButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        forgotPasswordButton?.addTarget(self, action: "forgot:", forControlEvents: .TouchUpInside)
       
        self.noAccount = UILabel()
        self.noAccount!.text = NSLocalizedString("profile.no.account",comment:"")
        self.noAccount!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.noAccount!.textColor = WMColor.loginTitleTextColor
        self.noAccount!.numberOfLines = 0
        self.noAccount!.textAlignment =  .Center
        self.noAccount!.textColor = WMColor.loginFieldBgColor
        
        self.titleLabel = UILabel()
        self.titleLabel!.textColor =  UIColor.whiteColor()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel!.text = "Ingresa a tu cuenta"
        self.titleLabel!.textAlignment = NSTextAlignment.Center
        
        viewLine = UIView()
        viewLine!.backgroundColor = WMColor.loginProfileLineColor
        
        self.content!.addSubview(self.titleLabel!)
        self.content.backgroundColor = UIColor.clearColor()
      
        self.content!.addSubview(forgotPasswordButton!)
        self.content?.addSubview(viewbg!)
        self.content?.addSubview(email!)
        self.content?.addSubview(password!)
        self.content?.addSubview(signInButton!)
        self.content?.addSubview(registryButton!)
        self.content?.addSubview(noAccount!)
        self.content?.addSubview(viewLine!)
        
        self.content!.backgroundColor = UIColor.clearColor()
        
        self.viewCenter = UIView()
        self.viewCenter!.backgroundColor = UIColor.clearColor()
        self.viewCenter!.clipsToBounds = true
        self.viewCenter.addSubview(self.content!)
        
        self.close = UIButton(type: .Custom)
        self.close!.setImage(UIImage(named: "close"), forState: .Normal)
        self.close!.addTarget(self, action: "closeModal", forControlEvents: .TouchUpInside)
        self.close!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.viewCenter!)
        self.view.addSubview(self.close!)
        
        self.loginFacebookButton = UIButton(type: .Custom)
        self.loginFacebookButton.layer.cornerRadius =  20.0
        self.loginFacebookButton!.backgroundColor = WMColor.UIColorFromRGB(0x005AA2)
        self.loginFacebookButton!.addTarget(self, action: "facebookLogin", forControlEvents: .TouchUpInside)
        self.loginFacebookButton!.setTitle("Ingresar con Facebook", forState: UIControlState.Normal)
        self.loginFacebookButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.loginFacebookButton!.setImage(UIImage(named: "facebook_login"), forState: .Normal)
        self.loginFacebookButton!.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 2, 16)
        self.loginFacebookButton!.imageView?.sizeThatFits(CGSizeMake(20.0, 20.0))
        self.loginFacebookButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.content!.addSubview(self.loginFacebookButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if valueEmail != nil {
            self.email?.text = valueEmail
            self.password?.becomeFirstResponder()
        }
       /* else {
            self.email?.becomeFirstResponder()
        }*/
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !viewAnimated {
            super.viewWillLayoutSubviews()
            let bounds = self.view.bounds
            let fieldHeight  : CGFloat = CGFloat(44)
            let leftRightPadding  : CGFloat = CGFloat(15)
      
            if self.imageblur == nil {
                self.generateBlurImage()
            }
        
            self.viewCenter!.frame = CGRectMake((self.view.bounds.width / 2) - (456 / 2) ,0, 456, self.view.bounds.height)
            self.content.frame = CGRectMake( (self.viewCenter!.frame.width / 2) - (320 / 2) , 50 , 320 , bounds.height - 50)
            self.titleLabel!.frame =  CGRectMake(0 , 0, self.content.frame.width , 16)
            self.email?.frame = CGRectMake(leftRightPadding,  40 , self.content.frame.width-(leftRightPadding*2), fieldHeight)
            self.password?.frame = CGRectMake(leftRightPadding, email!.frame.maxY+1, self.email!.frame.width , fieldHeight)
            self.viewLine?.frame = CGRectMake(leftRightPadding, email!.frame.maxY, self.email!.frame.width, 1)
            self.viewbg?.frame = CGRectMake(leftRightPadding, email!.frame.maxY-5, self.email!.frame.width, 10)
            
            self.forgotPasswordButton?.frame = CGRectMake(self.content.frame.width - 150 , password!.frame.maxY+15, 150 - leftRightPadding, 28)
            
            if UserCurrentSession.hasLoggedUser(){
                self.signInButton?.frame = CGRectMake(leftRightPadding, password!.frame.maxY+56, self.password!.frame.width, 40)
                self.noAccount?.frame = CGRectMake(leftRightPadding, signInButton!.frame.maxY + 20, self.password!.frame.width, 20)
            }else{
                self.signInButton?.frame = CGRectMake(leftRightPadding, password!.frame.maxY+56, self.password!.frame.width, 40)
                self.loginFacebookButton?.frame = CGRectMake(leftRightPadding,  self.signInButton!.frame.maxY + 24 , self.password!.frame.width, 40)
                self.noAccount?.frame = CGRectMake(leftRightPadding, loginFacebookButton!.frame.maxY + 20, self.password!.frame.width, 20)
            }
            
            self.bgView!.frame = self.view.bounds
            self.registryButton?.frame = CGRectMake(self.password!.frame.minX,  self.noAccount!.frame.maxY + 20 , self.password!.frame.width, 40)
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
    
    class func showLogin() -> LoginController! {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = LoginController()
        vc!.addChildViewController(newAlert)
        newAlert.view.frame = vc!.view.bounds
        vc!.view.addSubview(newAlert.view)
        newAlert.didMoveToParentViewController(vc)
        vc!.addChildViewController(newAlert)
        newAlert.view.tag = 5000
        return newAlert
    }
    
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

    func contentSizeForScrollView(sender:AnyObject) -> CGSize{
         return CGSizeMake( content.contentSize.width, content.contentSize.height)
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
    
    func registryUser() {
        
        if self.signUp == nil{
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CREATE_ACOUNT.rawValue, action:WMGAIUtils.ACTION_OPEN_CREATE_ACOUNT.rawValue , label: "")

            self.signUp =  isMGLogin ? SignUpMGViewController() : SignUpViewController()
            
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
   
    func closeModal() {
        /*UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.alpha = 0.0
            }) { (complete:Bool) -> Void in
                self.imageblur!.image = nil
                self.removeFromParentViewController()
                self.successCallBack = nil
                self.okCancelCallBack  = nil
                self.view.removeFromSuperview()
        }*/
        self.imageblur!.image = nil
        self.removeFromParentViewController()
        self.successCallBack = nil
        self.okCancelCallBack  = nil
        self.view.removeFromSuperview()
    }
    
    func signIn(sender:UIButton) {
        signInButton!.enabled = false
        if validateUser() {
         
            self.view.endEditing(true)
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                if !self.closeAlertOnSuccess {
                  self.alertView?.showOkButton("Cancelar",  colorButton:WMColor.loginSignOutButonBgColor)
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
    
    
    func callService(params:NSDictionary, alertViewService : IPOWMAlertViewController?) {
        let service = LoginService()
        service.callService(params, successBlock:{ (resultCall:NSDictionary?) in
            
            let profile = resultCall!["profile"] as? NSDictionary
            let gender = profile!["gender"] as? String
            let email = resultCall!["email"] as? String
            let idUser = resultCall!["idUser"] as? String
            
            BaseController.sendTuneAnalytics(TUNE_EVENT_LOGIN, email: email!, userName: email!, gender: gender!, idUser: idUser!, itesShop: nil,total:0,refId:"")
            
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
                if error.code == -300 {
                    self.signInButton!.enabled = true
                    let addressService = AddressByUserService()
                    addressService.setManagerTempHeader()
                    addressService.callService({ (address:NSDictionary) -> Void in
                        if let shippingAddress = address["shippingAddresses"] as? NSArray
                        {
                            if shippingAddress.count > 0 {
                                let alertAddress = GRFormAddressAlertView.initAddressAlert()!
                                for dictAddress in shippingAddress {
                                    if let pref = dictAddress["preferred"] as? NSNumber{
                                        if pref == 1{
                                            alertAddress.setData(dictAddress as! NSDictionary)
                                        }
                                    }
                                }
                                alertAddress.showAddressAlert()
                                alertAddress.alertSaveSuccess = {() in
                                    self.callService(params, alertViewService: alertViewService)
                                    
                                    
                                    if self.successCallBack == nil {
                                        self.successCallBack!()
                                        
                                    }
                                    alertAddress.removeFromSuperview()
                                }
                                alertAddress.cancelPress = {() in
                                    if alertViewService != nil {
                                        alertViewService!.setMessage("Es necesario capturar una dirección")
                                        alertViewService!.showErrorIcon("Ok")
                                    }
                                }
                                
                            }else {
                                self.showAddressForm(params, alertViewService: alertViewService)
                            }
                        }else {
                            self.showAddressForm(params, alertViewService: alertViewService)
                        }
                        }, errorBlock: { (error:NSError) -> Void in
                           self.showAddressForm(params, alertViewService: alertViewService)
                    })
                    return
                }
                self.signInButton!.enabled = true
                alertViewService!.okCancelCallBack = nil
                if alertViewService != nil {
                    let strToUse = NSLocalizedString("password.incorrect",comment:"")
                    alertViewService!.setMessage(strToUse)
                    alertViewService!.showErrorIcon("Ok")
                }
        })
    }
    
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
        }
        alertAddress.cancelPress = {() in
            if alertViewService != nil {
                alertViewService!.setMessage("Es necesario capturar una dirección")
                alertViewService!.showErrorIcon("Ok")
            }
        }
    }
    
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
            service.callService(self.email!.text!, successBlock: { (result: NSDictionary) -> Void in
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
    
    //MARK: Facebook
    func facebookLogin(){
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        if !self.closeAlertOnSuccess {
            self.alertView?.showOkButton("Cancelar",  colorButton:WMColor.loginSignOutButonBgColor)
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
                } else if result.isCancelled {
                    self.alertView!.close()
                    self.fbLoginMannager.logOut()
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
    
    func loginWithEmail(email:String, firstName: String, lastName: String, gender: String, birthDay: String){
        self.email?.text = email
        let service = LoginWithEmailService()
        service.callServiceForFacebook(service.buildParams(email, password: ""), successBlock:{ (resultCall:NSDictionary?) in

            self.signInButton!.enabled = true
            if self.successCallBack == nil {
                if self.controllerTo != nil  {
                    let storyboard = self.loadStoryboardDefinition()
                    let vc = storyboard!.instantiateViewControllerWithIdentifier(self.controllerTo)
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }else {
                if self.closeAlertOnSuccess {
                    
                    let idUser = resultCall!["idUser"] as? String
                    
                    BaseController.sendTuneAnalytics(TUNE_EVENT_LOGIN, email: email, userName: email, gender: gender, idUser: idUser!, itesShop: nil,total:0,refId:"")
                    
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
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                if birthDay != ""{
                    let date = dateFormatter.dateFromString(birthDay)
                    self.signUp.inputBirthdateView?.date = date!
                    dateFormatter.dateFormat = "d MMMM yyyy"
                    self.signUp.birthDate!.text = dateFormatter.stringFromDate(date!)
                    self.signUp.dateVal = date
                }
                if(gender == "male"){
                   self.signUp.maleButton?.selected = true
                }else{
                    self.signUp.femaleButton?.selected = true
                }
            })
    }
    
}