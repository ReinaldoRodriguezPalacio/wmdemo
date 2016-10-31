//
//  GRCheckOutCommentsViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

class GRCheckOutCommentsViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    //let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var alertView: IPOWMAlertViewController?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    var comments: UITextView?
    var phoneField: FormFieldView?
    var sectionTitle: UILabel?
    var sectionTitleComments: UILabel?
    var confirmCallButton: UIButton?
    var notConfirmCallButton: UIButton?
    var confirmCallOptionButton: UIButton?
    var paramsToOrder : NSMutableDictionary?
    var confirmSelected: Int! = 3
    var confirmText: String! = ""
    var savePhoneButton: UIButton?
    var phoneFieldSpace: CGFloat! = 0
    var defaultPhone: String! = ""
    var defaultPhoneType: Int! = 0
    var errorView: FormFieldErrorView?
    var showPhoneField: Bool = true
    var isPreferencesView:Bool = false
    
    var messageInCommens = ""
    var commentsString : NSMutableAttributedString?
    var showMessageInCommens =  false
    var userPreferences : NSMutableDictionary = [:]
    var changePreferences : Bool = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButton!.isHidden =  IS_IPAD && !isPreferencesView
        
        self.titleLabel?.text = NSLocalizedString("checkout.title.commentsview", comment: "")
        self.view.backgroundColor = UIColor.white
        
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            self.savePhone()
        })
        
        let viewAccessComments = FieldInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), inputViewStyle: .keyboard , titleSave:"Ok", saveText: { (field:UITextView?) -> Void in
            self.saveComments()
        })
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.white
        self.view.addSubview(self.content)
        
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 15.0
        
        if !isPreferencesView {
            self.stepLabel = UILabel()
            self.stepLabel.textColor = WMColor.reg_gray
            self.stepLabel.text = "3 de 4"
            self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
            self.header?.addSubview(self.stepLabel)
            self.showPhoneField = false
        }
        
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.confirm", comment: ""), frame: CGRect(x: margin, y: margin, width: width, height: lheight))
        self.content.addSubview(self.sectionTitle!)
        
        self.confirmCallButton = UIButton()
        self.confirmCallButton!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.confirmCallButton!.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
        self.confirmCallButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:changePrefeered:) ), for: UIControlEvents.touchUpInside)
        self.confirmCallButton!.setTitle(NSLocalizedString("gr.confirmacall", comment: ""), for: UIControlState())
        self.confirmCallButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        self.confirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.confirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        if IS_IPAD && isPreferencesView {
            self.confirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 0, right: 0)
        } else {
            self.confirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        
        self.confirmCallButton!.isSelected = true
        self.confirmCallButton!.tag = 3
        self.content.addSubview(self.confirmCallButton!)
        
        self.phoneField = FormFieldView(frame: CGRect(x: margin, y: confirmCallButton!.frame.maxY + 8.0, width: width, height: fheight))
        let phone = self.getDefaultPhone()
        //self.phoneField!.setCustomPlaceholder("Teléfono: \(phone)")
        self.phoneField!.isRequired = isPreferencesView ? false : true
        self.phoneField!.typeField = TypeField.phone
        self.phoneField!.nameField = "Teléfono"
        self.phoneField!.maxLength = 10
        self.phoneField!.minLength = 10
        self.phoneField!.disablePaste = true
        self.phoneField!.text = phone
        self.phoneField!.keyboardType = UIKeyboardType.numberPad
        self.phoneField!.inputAccessoryView = viewAccess
        self.phoneField!.delegate = self
        self.phoneField?.alpha = self.showPhoneField ? 1.0 : 0.0
        self.content.addSubview(self.phoneField!)
        
        self.savePhoneButton = UIButton(type: .custom)
        self.savePhoneButton!.setTitle("Guardar", for: UIControlState())
        self.savePhoneButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
        self.savePhoneButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.savePhoneButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.savePhone), for: UIControlEvents.touchUpInside)
        self.savePhoneButton!.alpha = 0.0
        self.content!.addSubview(self.savePhoneButton!)
        
        self.confirmCallOptionButton = UIButton()
        self.confirmCallOptionButton!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.confirmCallOptionButton!.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
        self.confirmCallOptionButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:changePrefeered:)), for: UIControlEvents.touchUpInside)
        self.confirmCallOptionButton!.setTitle(NSLocalizedString("gr.not.confirmacall.detal", comment: ""), for: UIControlState())
        self.confirmCallOptionButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        self.confirmCallOptionButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallOptionButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.confirmCallOptionButton!.titleLabel?.numberOfLines = 3
        self.confirmCallOptionButton!.titleEdgeInsets = UIEdgeInsets(top: (IS_IPAD && isPreferencesView) ? 14 : (IS_IPAD) ? 28 : 22, left: 8, bottom: 0, right: 0)
        self.confirmCallOptionButton!.tag = 1
        self.content.addSubview(self.confirmCallOptionButton!)
        
        self.notConfirmCallButton = UIButton()
        self.notConfirmCallButton!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.notConfirmCallButton!.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
        self.notConfirmCallButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:changePrefeered:)), for: UIControlEvents.touchUpInside)
        self.notConfirmCallButton!.setTitle(NSLocalizedString("gr.not.confirmacall.option.detail", comment: ""), for: UIControlState())
        self.notConfirmCallButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        self.notConfirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.notConfirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        self.notConfirmCallButton!.titleLabel?.numberOfLines = 3
        self.notConfirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: (IS_IPAD && isPreferencesView) ? 14 : (IS_IPAD) ? 28 : 22, left: 8, bottom: 0, right: 0)
        self.notConfirmCallButton!.tag = 2
        self.content.addSubview(self.notConfirmCallButton!)
        
        self.sectionTitleComments = self.buildSectionTitle(NSLocalizedString("checkout.title.comments", comment: ""), frame: CGRect(x: margin, y: notConfirmCallButton!.frame.maxY + 28.0, width: width, height: lheight))
        self.content.addSubview(self.sectionTitleComments!)
        
        self.comments = UITextView()
        self.comments!.layer.cornerRadius = 5.0
        self.comments!.returnKeyType = .default
        self.comments!.autocapitalizationType = .none
        self.comments!.autocorrectionType = .no
        self.comments!.enablesReturnKeyAutomatically = true
        self.comments!.font = WMFont.fontMyriadProItOfSize(12)
        self.comments!.text = NSLocalizedString("checkout.field.comments", comment:"")
        self.comments!.textColor = UIColor.gray
        self.comments!.backgroundColor = WMColor.light_light_gray
        self.comments!.delegate = self
        self.comments!.inputAccessoryView = viewAccessComments
        self.content.addSubview(self.comments!)
        let  commentsDefault = NSMutableAttributedString(string: UserCurrentSession.sharedInstance().messageInCommens )
        commentsDefault.addAttribute(NSForegroundColorAttributeName, value: WMColor.light_blue, range:NSMakeRange(0,commentsDefault.length))
        commentsDefault.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProItOfSize(12), range:NSMakeRange(0,commentsDefault.length))
        
        commentsString = NSMutableAttributedString(string: NSLocalizedString("checkout.field.comments", comment:""))
        commentsString!.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range:NSMakeRange(0,commentsString!.length))
        commentsString!.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProItOfSize(12), range:NSMakeRange(0,commentsString!.length))
        commentsString!.append(commentsDefault)
        
        if UserCurrentSession.sharedInstance().activeCommens {
            self.findproductInCar()
            if self.showMessageInCommens {
                self.comments?.attributedText = commentsString
            }
        }
        
        self.invokePreferenceService()
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLine, at: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        
        if isPreferencesView {
            self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), for:UIControlState())
            self.saveButton!.backgroundColor = WMColor.green
            self.saveButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.savePreferences), for: UIControlEvents.touchUpInside)
        } else {
            self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), for:UIControlState())
            self.saveButton!.backgroundColor = WMColor.light_blue
            self.saveButton!.addTarget(self, action: #selector(getter: GRCheckOutCommentsViewController.next), for: UIControlEvents.touchUpInside)
        }
        
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.layer.cornerRadius = 17
        self.view.addSubview(saveButton!)

        self.confirmText = "\(NSLocalizedString("gr.confirmacall", comment: ""))\n\(self.phoneField!.text!)"
        self.content?.contentOffset = CGPoint.zero
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.buildSubViews()
        if userPreferences.count > 0 {
            if  userPreferences["onlyTelephonicAlert"] != nil {
                switch userPreferences["onlyTelephonicAlert"] as!  String {
                    
                case OnlyAlertPreferences.receiveCallConfirmation.rawValue:
                    self.confirmCallSelected(self.confirmCallOptionButton!,changePrefeered: true)
                    print("receiveCallConfirmation")
                    break
                    
                case OnlyAlertPreferences.onlySubstituteAvailable.rawValue:
                    print("onlySubstituteAvailable")
                    self.confirmCallSelected(self.notConfirmCallButton!,changePrefeered: true)
                    break
                    
                case OnlyAlertPreferences.onlyOrderedProducts.rawValue:
                    print("onlyOrderedProducts")
                    self.confirmCallSelected(self.confirmCallButton!,changePrefeered: true)
                    
                    break
                default:
                    break
                }
            }
        }
        
    }
    
    override func willShowTabbar() {
        if isPreferencesView {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 112,  width: self.view.frame.width, height: 1)
                self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 96, width: 140, height: 34)
                self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 96, width: 140, height: 34)
            })
        }
    }
    
    override func willHideTabbar() {
        if isPreferencesView {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 66,  width: self.view.frame.width, height: 1)
                self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 50, width: 140, height: 34)
                self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 50, width: 140, height: 34)
            })

        }
    }

    /**
     Build view components
     */
    func buildSubViews() {
        
        let margin: CGFloat = 16.0
        let width = (IS_IPAD && isPreferencesView) ? self.view.frame.width - ( 10 * margin) : self.view.frame.width - ( 2 * margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 15.0
        let checkImageBottom: CGFloat = IS_IPAD && !isPreferencesView ? 28 : 6
        let checkButtonHeight: CGFloat = 45//IS_IPAD && !IS_IPAD_MINI ? 45 : 30
        
        if !isPreferencesView {
            self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 0.0, width: 46, height: self.titleLabel!.bounds.height)
        }
        
        self.sectionTitle!.frame = CGRect(x: margin, y: margin, width: width, height: lheight)
        self.confirmCallButton!.frame = CGRect(x: margin,y: self.sectionTitle!.frame.maxY + margin,width: width,height: 20)
        
        if self.showPhoneField {
            self.phoneField!.frame = CGRect(x: margin, y: confirmCallButton!.frame.maxY + 8.0, width: width, height: fheight)
            self.savePhoneButton!.frame = CGRect(x: self.view.frame.width - self.phoneFieldSpace, y: confirmCallButton!.frame.maxY + 8.0, width: 55, height: 40)
            self.notConfirmCallButton!.frame = CGRect(x: margin, y: phoneField!.frame.maxY + (IS_IPAD && isPreferencesView ? margin : 8), width: width, height: checkButtonHeight)
        }else{
            self.phoneField!.frame = CGRect(x: margin, y: confirmCallButton!.frame.maxY + 8.0, width: width, height: fheight)
            self.notConfirmCallButton!.frame = CGRect(x: margin, y: confirmCallButton!.frame.maxY + (IS_IPAD && isPreferencesView ? margin : 8), width: width, height: checkButtonHeight)
            self.savePhoneButton!.frame = CGRect(x: self.view.frame.width - self.phoneFieldSpace, y: confirmCallButton!.frame.maxY + 8.0, width: 55, height: 40)
        }
        
        self.confirmCallOptionButton!.frame = CGRect(x: margin,y: notConfirmCallButton!.frame.maxY + margin, width: width, height: checkButtonHeight)
        
        self.sectionTitleComments!.frame = CGRect(x: margin, y: confirmCallOptionButton!.frame.maxY + 28.0, width: width, height: lheight)
        self.comments!.frame = CGRect(x: margin,y: self.sectionTitleComments!.frame.maxY + margin,width: width,height: 95)
        
        if isPreferencesView {
            sectionTitleComments?.isHidden = true
            sectionTitleComments?.isUserInteractionEnabled = false
            comments?.isHidden = true
            comments?.isUserInteractionEnabled = false
            phoneField?.isUserInteractionEnabled = false
            phoneField?.isHidden = true
        }
        
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height - 111)
        self.content!.contentSize = CGSize(width: self.view.frame.width, height: self.comments!.frame.maxY + 10)
        
        if isPreferencesView {
            
            if TabBarHidden.isTabBarHidden || IS_IPAD {
                self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 66,  width: self.view.frame.width, height: 1)
                self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 50, width: 140, height: 34)
                self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 50, width: 140, height: 34)
            } else {
                self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 112,  width: self.view.frame.width, height: 1)
                self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 96, width: 140, height: 34)
                self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 96, width: 140, height: 34)
            }
            
        } else {
            self.layerLine.frame = CGRect(x: 0, y: self.view.bounds.height - 66,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148,y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
        }
        
        self.confirmCallOptionButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: IS_IPAD ? 0 : checkImageBottom, right:0 )
        self.notConfirmCallButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: IS_IPAD ? 0 : checkImageBottom, right:0 )
    }
    
    /**
     Builds an UILabel with the title of section
     
     - parameter title: title of section
     - parameter frame: frame of UILabel
     
     - returns: UILabel
     */
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    /**
     Sends to the next checkout page
     */
    func next(){
        
        self.comments!.resignFirstResponder()
        if self.changePreferences {
                self.invokeSavepeferences()
        }
        
        let nextController = GRCheckOutConfirmViewController()
        nextController.paramsToOrder = self.paramsToOrder
        self.navigationController?.pushViewController(nextController, animated: true)
        
    }
    
    func savePreferences() {
        self.invokeSavepeferences()
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    /**
     Confirm call buttons action
     
     - parameter button: selected button
     */
    func confirmCallSelected(_ button:UIButton,changePrefeered:Bool){
        self.changePreferences = !changePrefeered
        
        if self.confirmSelected != button.tag {
            
            // 2 = only Substitute Available
            // 3 = onlyOrderedProducts
            // 1 = receiveCallConfirmation
            
            self.confirmCallButton?.isSelected = (self.confirmCallButton == button)
            self.notConfirmCallButton?.isSelected = (self.notConfirmCallButton == button)
            self.confirmCallOptionButton?.isSelected = (self.confirmCallOptionButton == button)
            self.confirmSelected = button.tag
            self.confirmText = button.titleLabel!.text!
        
            if confirmSelected == 3 {
           
                self.userPreferences.setObject(OnlyAlertPreferences.receiveCallConfirmation.rawValue, forKey:"onlyTelephonicAlert" as NSCopying)
                
                self.confirmText = "\(self.confirmText)\n\(self.phoneField!.text!)"
                self.phoneField?.isEnabled = true
                self.phoneField?.textColor = UIColor.black
                self.showPhoneField = true
                
            } else {
                
                self.phoneField?.isEnabled = false
                self.phoneField?.textColor = WMColor.reg_gray
                self.showPhoneField = false
                
                self.userPreferences.setObject(confirmSelected == 1 ? OnlyAlertPreferences.onlyOrderedProducts.rawValue : OnlyAlertPreferences.onlySubstituteAvailable.rawValue , forKey:"onlyTelephonicAlert" as NSCopying)
            }
            
            isPreferencesView ? self.showPhoneField = false : self.showPhoneFieldAnimated()
            
        }
        
    }
    
    /**
     Shows or hides cancel button in searchView
     
     - parameter didShow: Bool
     */
    func showSavePhoneButton(_ didShow:Bool){
        if didShow{
            self.phoneFieldSpace = 71
            UIView.animate(withDuration: 0.3, animations: {() in
                self.savePhoneButton!.alpha = 1.0
                self.savePhoneButton!.frame = CGRect(x: self.view.frame.width - self.phoneFieldSpace, y: self.confirmCallButton!.frame.maxY + 8.0, width: 55, height: 40)
                self.phoneField!.frame = CGRect(x: 16, y: self.confirmCallButton!.frame.maxY + 8.0, width: self.view.frame.width - (self.phoneFieldSpace + 32), height: 40.0)
            })
        }else{
            self.phoneFieldSpace = 0
            UIView.animate(withDuration: 0.3, animations: {() in
                self.savePhoneButton!.alpha = 0.0
                self.savePhoneButton!.frame = CGRect(x: self.view.frame.width - self.phoneFieldSpace, y: self.confirmCallButton!.frame.maxY + 8.0, width: 55, height: 40)
                self.phoneField!.frame = CGRect(x: 16, y: self.confirmCallButton!.frame.maxY + 8.0, width: self.view.frame.width - (self.phoneFieldSpace + 32), height: 40.0)
            })
        }
        
    }
    
    /**
     Shows or hide PhoneField
     */
    
    func showPhoneFieldAnimated(){
        if self.showPhoneField{
            UIView.animate(withDuration: 0.3, animations: {() in
                self.phoneField!.alpha = 1.0
                self.savePhoneButton!.alpha = 1.0
                self.buildSubViews()
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {() in
                self.phoneField!.alpha = 0.0
                self.savePhoneButton!.alpha = 0.0
                self.buildSubViews()
            })
        }
    }
    
    /**
     Set default phone numbre
     */
    
    func getDefaultPhone() -> String{
        var phone = ""
        if UserCurrentSession.sharedInstance().userSigned?.profile.phoneHomeNumber == "" {
            phone =  UserCurrentSession.sharedInstance().userSigned?.profile.cellPhone as! String
            self.defaultPhoneType = 1
            self.defaultPhone = phone
        }else{
            phone = UserCurrentSession.sharedInstance().userSigned?.profile.phoneHomeNumber as! String
            self.defaultPhoneType = 0
            self.defaultPhone = phone
        }
        return phone
    }
    
    /**
     Reset phone field
     */
    func resetPhoneField(){
        self.phoneField?.text = self.defaultPhone
        if self.errorView?.superview != nil {
            self.errorView?.removeFromSuperview()
        }
        self.errorView?.focusError = nil
        self.errorView = nil
        self.showSavePhoneButton(false)
    }
    
    /**
     Validathe phone datda
     
     - returns: bool
     */
    func validatePhone() -> Bool {
        
        let message = self.phoneField!.validate()
        if message == nil {
            if self.errorView?.superview != nil {
                self.errorView?.removeFromSuperview()
            }
            self.errorView?.focusError = nil
            self.errorView = nil
            return true
        }
        
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        SignUpViewController.presentMessage(self.phoneField!, nameField:self.phoneField!.nameField, message: message! , errorView:self.errorView! , becomeFirstResponder: true)
        return false
    }
    
    //MARK: Services
    
   
    func invokePreferenceService(){
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:NSDictionary) in
                self.userPreferences.addEntries(from: result as [AnyHashable: Any])
            
        }, errorBlock: { (error:NSError) in
                print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    func invokeSavepeferences(){
        
        //TODO preguntar por valor:: acceptConsent
        
        let peferencesService =  SetPreferencesService()
        let  params = peferencesService.buildParams(self.userPreferences["userPreferences"] as! NSArray, onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as! String, abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.userPreferences["receivePromoEmail"] as! String, forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: true, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
        peferencesService.jsonFromObject(params)
        
        if isPreferencesView {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"icon_alert_saving"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"alert_ups"))
            self.alertView!.setMessage(NSLocalizedString("preferences.message.saving", comment:""))
        }
        
        peferencesService.callService(requestParams:params , successBlock: { (result:NSDictionary) in
            print("Preferencias Guardadas")
            
            if self.isPreferencesView {
                self.alertView!.setMessage(NSLocalizedString("preferences.message.saved", comment:""))
                self.alertView!.showDoneIcon()
            }
            
            self.invokePreferenceService()
            
        }, errorBlock: { (error:NSError) in
            print("Hubo un error al guardar las Preferencias")
            
            if self.isPreferencesView {
                self.alertView!.setMessage(NSLocalizedString("preferences.message.errorSave", comment:""))
                self.alertView!.showErrorIcon("Ok")
            }
            
        })
    
    }
    
    
    /**
     Saves de user comments
     */
    func saveComments(){
        self.comments?.resignFirstResponder()
        
        if self.comments!.text == commentsString!.string || self.comments!.text.trim() == ""{
            return
        }
        
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"userProfile"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"userProfile"))
        //alert?.showicon(UIImage(named:"userProfile"))
        alert?.setMessage("Guardando comentario ...")
        let updateCommentService = UpdateCommentsService()
        let updateCommentParams = updateCommentService.buildParameterOrder(self.comments!.text)
        updateCommentService.callService(requestParams: updateCommentParams, succesBlock: {(result) -> Void in
            let codeMessage = result["codeMessage"] as! NSNumber
            if codeMessage.int32Value == 0 {
                alert?.setMessage("Guardado")
                alert?.showDoneIcon()
            }else{
                alert?.setMessage("Intenta nuevamente")
                alert?.showErrorIcon("Aceptar")
            }
            }, errorBlock: {(error) -> Void in
                alert?.setMessage("Intenta nuevamente")
                alert?.showErrorIcon("Aceptar")
        })
    }
    
    /**
     Saves new phone in user profile
     */
    func savePhone(){
        
        if !self.validatePhone() {
            return
        }
        
        let phoneDefault = self.phoneField!.text!
        let home = self.defaultPhoneType == 0 ? phoneDefault : UserCurrentSession.sharedInstance().userSigned?.profile.phoneHomeNumber as! String
        let cellphone = self.defaultPhoneType == 1 ? phoneDefault :UserCurrentSession.sharedInstance().userSigned?.profile.cellPhone as! String
        
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"userProfile"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"userProfile"))
        alert?.showicon(UIImage(named:"userProfile"))
        alert?.setMessage(NSLocalizedString("gr.alert.phone", comment: ""))
            alert?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel", comment: ""), leftAction: {
            self.resetPhoneField()
            alert?.close()
            }, rightText: NSLocalizedString("invoice.message.continue", comment: ""), rightAction: {
                UserCurrentSession.sharedInstance().setMustUpdatePhoneProfile(home, cellPhone: cellphone)
                self.defaultPhone = phoneDefault
                self.phoneField?.text = phoneDefault
                
                if self.confirmSelected == 3{
                    self.confirmText = "\(self.confirmCallButton!.titleLabel!.text!)\n\(phoneDefault)"
                }
                
                alert?.showDoneIcon()
                alert?.close()
            }, isNewFrame: false)
    }
    
    
    /**
        Find products in car for paint promotions in commens
     */
    func findproductInCar(){
      let products =  UserCurrentSession.sharedInstance().itemsGR
        let upcsIncart : NSMutableArray =  []
        let itemsInShoppingCart = products!["items"] as? NSArray
        for items in itemsInShoppingCart! {
            upcsIncart.add(items["upc"] as! String)
        }
        for upc in UserCurrentSession.sharedInstance().upcSearch {
            if upcsIncart.contains(upc) {
                showMessageInCommens =  true
                break
            }
        }
        print(showMessageInCommens)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.comments!.frame.maxY + 10)
    }
    
    //MARK: -TextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if NSString(string:textView.text).length + (NSString(string:text).length - range.length) ==  0{
            textView.text = NSLocalizedString("checkout.field.comments", comment:"")
            textView.resignFirstResponder()
            textView.textColor = UIColor.gray
            
            if self.showMessageInCommens && UserCurrentSession.sharedInstance().activeCommens {
                textView.attributedText =  commentsString
            }
            
        }
        
        return NSString(string:textView.text).length + (NSString(string:text).length - range.length) <= 200
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.text ==  NSLocalizedString("checkout.field.comments", comment:"") || textView.text == self.commentsString?.string {
            textView.text = ""
            textView.textColor = WMColor.dark_gray
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //let offset = self.content!.contentOffset.y + 150
        var offset = abs((self.content.contentSize.height - self.content.frame.height) + 150)
        if IS_IPAD {
            offset = 120
        }
        self.content!.contentOffset = CGPoint(x: 0, y: offset)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text =  NSLocalizedString("checkout.field.comments", comment:"")
            textView.textColor = UIColor.gray
            if self.showMessageInCommens && UserCurrentSession.sharedInstance().activeCommens {
                textView.attributedText =  commentsString
            }
        }
        self.content!.contentOffset = CGPoint.zero
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : NSString = textField.text! as String as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
        if txtAfterUpdate.length >= 11 {
            return false
        }
        
        self.showSavePhoneButton((txtAfterUpdate as String != self.defaultPhone))
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.phoneField!.layer.borderColor = WMColor.light_blue.cgColor
        self.phoneField!.layer.borderWidth = 0.5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.phoneField!.layer.borderColor = WMColor.light_light_gray.cgColor
        self.phoneField!.layer.borderWidth = 0.0
        self.resetPhoneField()
    }
    
    //MARK: -Scroll

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        self.comments!.resignFirstResponder()
        self.phoneField!.resignFirstResponder()
    }
    
}
