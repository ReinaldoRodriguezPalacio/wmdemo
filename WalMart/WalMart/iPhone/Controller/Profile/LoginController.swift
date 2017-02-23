//
//  LoginController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/17/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import FBSDKLoginKit
import Foundation
import FBSDKCoreKit
//import Tune

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
	var isMGLogin =  false
    var fbLoginMannager: FBSDKLoginManager!
    var isOnlyLogin =  true
    
    var okCancelCallBack : (() -> Void)? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LOGIN.rawValue
    }

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
        //self.password!.minLength = 5
        //self.password!.maxLength = 15
        
        self.viewbg = UIView()
        self.viewbg!.backgroundColor = WMColor.light_light_gray
       
        //Login button setup
        registryButton = UIButton()
        registryButton!.setTitle(NSLocalizedString("profile.create.an.account", comment: ""), for: UIControlState())
        registryButton!.setTitleColor(UIColor.white, for: UIControlState())
        registryButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        registryButton!.backgroundColor = WMColor.blue
        registryButton!.layer.cornerRadius = 20.0
        registryButton?.addTarget(self, action: #selector(LoginController.registryUser), for: .touchUpInside)
  
        signInButton = UIButton()
        signInButton!.setTitle(NSLocalizedString("profile.signIn", comment: ""), for: UIControlState())
        signInButton!.setTitleColor(UIColor.white, for: UIControlState())
        signInButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        signInButton!.backgroundColor = WMColor.green
        signInButton!.addTarget(self, action: #selector(LoginController.signIn(_:)), for: .touchUpInside)
        signInButton!.layer.cornerRadius = 20.0

        //Button forgot password setup
        forgotPasswordButton = UIButton()
        forgotPasswordButton!.setTitle(NSLocalizedString("profile.forgot.password", comment: ""), for: UIControlState())
        forgotPasswordButton!.setTitleColor(UIColor.white, for: UIControlState())
        forgotPasswordButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        forgotPasswordButton!.titleLabel!.textAlignment = .right
        forgotPasswordButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        forgotPasswordButton?.addTarget(self, action: #selector(LoginController.forgot(_:)), for: .touchUpInside)
       
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
        self.titleLabel!.text = "Ingresa a tu cuenta"
        self.titleLabel!.textAlignment = NSTextAlignment.center
        
        viewLine = UIView()
        viewLine!.backgroundColor = WMColor.light_gray
        
        self.content!.addSubview(self.titleLabel!)
        self.content.backgroundColor = UIColor.clear
      
        self.content!.addSubview(forgotPasswordButton!)
        self.content?.addSubview(viewbg!)
        self.content?.addSubview(email!)
        self.content?.addSubview(password!)
        self.content?.addSubview(signInButton!)
        self.content?.addSubview(registryButton!)
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if valueEmail != nil {
            self.email?.text = valueEmail
            let _ = self.password?.becomeFirstResponder()
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
                //self.generateBlurImage()
            }
        
            self.viewCenter!.frame = CGRect(x: (self.view.bounds.width / 2) - (456 / 2) ,y: 0, width: 456, height: self.view.bounds.height)
            self.content.frame = CGRect( x: (self.viewCenter!.frame.width / 2) - (320 / 2) , y: 50 , width: 320 , height: bounds.height - 50)
            self.titleLabel!.frame =  CGRect(x: 0 , y: 0, width: self.content.frame.width , height: 16)
            self.email?.frame = CGRect(x: leftRightPadding,  y: 40 , width: self.content.frame.width-(leftRightPadding*2), height: fieldHeight)
            self.password?.frame = CGRect(x: leftRightPadding, y: email!.frame.maxY+1, width: self.email!.frame.width , height: fieldHeight)
            self.viewLine?.frame = CGRect(x: leftRightPadding, y: email!.frame.maxY, width: self.email!.frame.width, height: 1)
            self.viewbg?.frame = CGRect(x: leftRightPadding, y: email!.frame.maxY-5, width: self.email!.frame.width, height: 10)
            
            self.forgotPasswordButton?.frame = CGRect(x: self.content.frame.width - 150 , y: password!.frame.maxY+15, width: 150 - leftRightPadding, height: 28)
            
            if UserCurrentSession.hasLoggedUser(){
                self.signInButton?.frame = CGRect(x: leftRightPadding, y: password!.frame.maxY+56, width: self.password!.frame.width, height: 40)
                self.noAccount?.frame = CGRect(x: leftRightPadding, y: signInButton!.frame.maxY + 20, width: self.password!.frame.width, height: 20)
            }else{
                self.signInButton?.frame = CGRect(x: leftRightPadding, y: password!.frame.maxY+56, width: self.password!.frame.width, height: 40)
                //self.loginFacebookButton?.frame = CGRectMake(leftRightPadding,  self.signInButton!.frame.maxY + 24 , self.password!.frame.width, 40)
                self.noAccount?.frame = CGRect(x: leftRightPadding, y: self.signInButton!.frame.maxY + 20, width: self.password!.frame.width, height: 20)
            }
            
            self.bgView!.frame = self.view.bounds
            self.registryButton?.frame = CGRect(x: self.password!.frame.minX,  y: self.noAccount!.frame.maxY + 20 , width: self.password!.frame.width, height: 40)
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

    func contentSizeForScrollView(_ sender:Any) -> CGSize{
         return CGSize( width: content.contentSize.width, height: content.contentSize.height)
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
    
    func registryUser() {
        self.isOnlyLogin = false
        
        if self.signUp == nil{
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CREATE_ACOUNT.rawValue, action:WMGAIUtils.ACTION_OPEN_CREATE_ACOUNT.rawValue , label: "")
            
            // Event -- Intent Registration
            BaseController.sendAnalyticsIntentRegistration()
            
            self.signUp =  isMGLogin ? SignUpMGViewController() : SignUpViewController()
            
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
                              
                let service = LoginService()//--
                let params  = service.buildParams(self.signUp.email!.text!, password: self.signUp.password!.text!)
                self.alertView = self.signUp.alertView!
                self.callService(params, alertViewService:self.signUp.alertView!)
                
                //
                //

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
        self.imageblur?.image = nil
        self.removeFromParentViewController()
        self.successCallBack = nil
        self.okCancelCallBack  = nil
        self.view.removeFromSuperview()
    }
    
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
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LOGIN.rawValue, action:WMGAIUtils.ACTION_LOGIN_USER.rawValue, label:"")
        
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
    
    func callService(_ params:[String:Any], alertViewService : IPOWMAlertViewController?) {
        
        let service = LoginService()
        if self.isOnlyLogin {
            service.callService(params, successBlock:{ (resultCall:[String:Any]?) in
                //call success service
                self.callInSuccesLoginsService(alertViewService: alertViewService!)
                //end call succes service
            },errorBlock: {(error: NSError) in
                print("error callService : \(error.localizedDescription)")
                //call in error service
                self.callInErrorLoginsService(error: error, alertViewService: alertViewService!, params: params)
                //end call in error
            })
        }else{
            service.callServiceByEmail(params: params, successBlock:{ (resultCall:[String:Any]?) in
                //call success service
                self.callInSuccesLoginsService(alertViewService: alertViewService!)
                //end call succes service
            },errorBlock: {(error: NSError) in
                print("error callServiceByEmail \(error.localizedDescription)")
                //call in error service
                self.callInErrorLoginsService(error: error, alertViewService: alertViewService!, params: params)
                //end call in error
            })
        }
      
    }
    
    //Call succes Login -Loginemail service
    func callInSuccesLoginsService(alertViewService:IPOWMAlertViewController?) {
        
        let caroService = CarouselService()
        let caroparams = Dictionary<String, String>()
        caroService.callService(caroparams, successBlock: { (result:[String:Any]) -> Void in
            print("Call service caroService success")
        }) { (error:NSError) -> Void in
            print("Call service caroService error \(error)")
        }
        
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
                    alertViewService?.setMessage(NSLocalizedString("profile.login.welcome",comment:""))
                    alertViewService?.showDoneIcon()
                }
            }
            self.successCallBack!()
        }
    }
    
    //Call erroraction Login -Loginemail service
    func callInErrorLoginsService(error:NSError,alertViewService:IPOWMAlertViewController?,params:[String:Any]){
        
        if error.code == -300 {
            self.signInButton!.isEnabled = true
            let addressService = AddressByUserService()
            addressService.setManagerTempHeader()
            addressService.callService({ (address:[String:Any]) -> Void in
                if let shippingAddress = address["shippingAddresses"] as? [[String:Any]]
                {
                    if shippingAddress.count > 0 {
                        let alertAddress = GRFormAddressAlertView.initAddressAlert()!
                        for dictAddress in shippingAddress {
                            if let pref = dictAddress["preferred"] as? NSNumber{
                                if pref == 1{
                                    alertAddress.setData(dictAddress )
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
                            alertAddress.removeFromSuperview()
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
        
    }
    
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
    
    func forgot(_ sender:UIButton) {
        self.textFieldDidEndEditing(self.email!)
        let error = viewError(self.email!)
        if !error {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_FORGOT_PASSWORD.rawValue, action: WMGAIUtils.ACTION_RECOVER_PASSWORD.rawValue, label:"")
            
            self.view.endEditing(true)
            if sender.tag == 100 {
                 self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"forgot_waiting"),imageDone:UIImage(named:"forgot_passwordOk"),imageError:UIImage(named:"forgot_passwordError"))
            }else{
                 self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"forgot_waiting"),imageDone:UIImage(named:"forgot_passwordOk"),imageError:UIImage(named:"forgot_passwordError"))
            }

            self.alertView!.setMessage(NSLocalizedString("profile.message.sending",comment:""))
            let service = ForgotPasswordService()
            service.callService(self.email!.text!, successBlock: { (result: [String:Any]) -> Void in
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
           let _ = password!.becomeFirstResponder()
        }
        if textField == password {
            self.signIn(signInButton!)
        }
        return true
    }
    
    
}
