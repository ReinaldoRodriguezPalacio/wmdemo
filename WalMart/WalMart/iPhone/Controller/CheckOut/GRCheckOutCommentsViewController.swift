//
//  GRCheckOutCommentsViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

class GRCheckOutCommentsViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate,UITextViewDelegate, UITextFieldDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    var comments: UITextView?
    var sectionTitleWine : UILabel!
    var phoneField: FormFieldView?
    var sectionTitle: UILabel?
    var sectionTitleComments: UILabel?
    var confirmCallButton: UIButton?
    var notConfirmCallButton: UIButton?
    var confirmCallOptionButton: UIButton?
    var paramsToOrder : [String:Any]?
    var paramsToConfirm : [String:Any]?
    var confirmSelected: Int! = 3
    var confirmText: String! = ""
    var savePhoneButton: UIButton?
    var phoneFieldSpace: CGFloat! = 0
    var defaultPhone: String! = ""
    var defaultPhoneType: Int! = 0
    var errorView: FormFieldErrorView?
    var showPhoneField: Bool = true
    
    var messageInCommens = ""
    var commentsString : NSMutableAttributedString?
    var showMessageInCommens =  false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = NSLocalizedString("checkout.title.commentsview", comment: "")
        self.view.backgroundColor = UIColor.white
        
        if IS_IPAD {
            self.backButton?.isHidden = true
        }
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            self.savePhone()
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
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "2 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.confirm", comment: ""), frame: CGRect(x: margin, y: margin, width: width, height: lheight))
        self.content.addSubview(self.sectionTitle!)
        
        self.confirmCallButton = UIButton()
        self.confirmCallButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.confirmCallButton!.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
        self.confirmCallButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:)), for: UIControlEvents.touchUpInside)
        self.confirmCallButton!.setTitle(NSLocalizedString("gr.confirmacall", comment: ""), for: UIControlState())
        self.confirmCallButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.confirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.confirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.confirmCallButton!.isSelected = true
        self.confirmCallButton!.tag = 3
        self.content.addSubview(self.confirmCallButton!)

        self.phoneField = FormFieldView(frame: CGRect(x: margin, y: confirmCallButton!.frame.maxY + 8.0, width: width, height: fheight))
        let phone = self.getDefaultPhone()
        //self.phoneField!.setCustomPlaceholder("Teléfono: \(phone)")
        self.phoneField!.isRequired = true
        self.phoneField!.typeField = TypeField.phone
        self.phoneField!.nameField = "Teléfono"
        self.phoneField!.maxLength = 10
        self.phoneField!.minLength = 10
        self.phoneField!.disablePaste = true
        self.phoneField!.text = phone
        self.phoneField!.keyboardType = UIKeyboardType.numberPad
        self.phoneField!.inputAccessoryView = viewAccess
        self.phoneField!.delegate = self
        self.content.addSubview(self.phoneField!)
        
        self.savePhoneButton = UIButton(type: .custom)
        self.savePhoneButton!.setTitle("Guardar", for: UIControlState())
        self.savePhoneButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
        self.savePhoneButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.savePhoneButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.savePhone), for: UIControlEvents.touchUpInside)
        self.savePhoneButton!.alpha = 0.0
        self.content!.addSubview(self.savePhoneButton!)
        
        self.confirmCallOptionButton = UIButton()
        self.confirmCallOptionButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.confirmCallOptionButton!.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
        self.confirmCallOptionButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:)), for: UIControlEvents.touchUpInside)
        self.confirmCallOptionButton!.setTitle(NSLocalizedString("gr.not.confirmacall.detal", comment: ""), for: UIControlState())
        self.confirmCallOptionButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.confirmCallOptionButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallOptionButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.confirmCallOptionButton!.titleLabel?.numberOfLines = 3
        self.confirmCallOptionButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.confirmCallOptionButton!.tag = 1
        self.content.addSubview(self.confirmCallOptionButton!)
        
        self.notConfirmCallButton = UIButton()
        self.notConfirmCallButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.notConfirmCallButton!.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
        self.notConfirmCallButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:)), for: UIControlEvents.touchUpInside)
        self.notConfirmCallButton!.setTitle(NSLocalizedString("gr.not.confirmacall.option.detail", comment: ""), for: UIControlState())
        self.notConfirmCallButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.notConfirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.notConfirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.notConfirmCallButton!.titleLabel?.numberOfLines = 3
        self.notConfirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
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
        self.content.addSubview(self.comments!)

        self.sectionTitleWine = self.buildSectionTitle(NSLocalizedString("checkout.title.wine", comment: ""), frame: CGRect(x: margin, y: notConfirmCallButton!.frame.maxY + 28.0, width: width, height: lheight))
        self.sectionTitleWine.textColor = UIColor.darkGray
        self.sectionTitleWine.numberOfLines = 4
        self.sectionTitleWine.font = WMFont.fontMyriadProRegularOfSize(12)
        self.content.addSubview(self.sectionTitleWine!)








        
        
        
        let  commentsDefault = NSMutableAttributedString(string: UserCurrentSession.sharedInstance.messageInCommens )
        commentsDefault.addAttribute(NSForegroundColorAttributeName, value: WMColor.light_blue, range:NSMakeRange(0,commentsDefault.length))
        commentsDefault.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProItOfSize(12), range:NSMakeRange(0,commentsDefault.length))
        
        commentsString = NSMutableAttributedString(string: NSLocalizedString("checkout.field.comments", comment:""))
        commentsString!.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range:NSMakeRange(0,commentsString!.length))
        commentsString!.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProItOfSize(12), range:NSMakeRange(0,commentsString!.length))
        commentsString!.append(commentsDefault)
        
        
        if UserCurrentSession.sharedInstance.activeCommens {
            self.findproductInCar()
            if self.showMessageInCommens {
                self.comments?.attributedText = commentsString
            }
        }
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLine, at: 1000)

        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: Selector("back"), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.nextStep), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)

        self.confirmText = "\(NSLocalizedString("gr.confirmacall", comment: ""))\n\(self.phoneField!.text!)"
        
        self.content?.contentOffset = CGPoint.zero
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.buildSubViews()
    }
    
    /**
     Build view components
     */
    func buildSubViews() {
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 15.0
        let checkImageBottom: CGFloat = 14//IS_IPAD && !IS_IPAD_MINI ? 28 : 14
        let checkButtonHeight: CGFloat = 30//IS_IPAD && !IS_IPAD_MINI ? 45 : 30
        let widthButton = (self.view.bounds.width / 2) - (margin * 1.5)
        
        self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 8.0, width: self.titleLabel!.bounds.height, height: 35)
        self.sectionTitle!.frame = CGRect(x: margin, y: margin, width: width, height: lheight)
        self.confirmCallButton!.frame = CGRect(x: margin,y: self.sectionTitle!.frame.maxY + margin,width: width,height: 20)
        if self.showPhoneField {
            self.phoneField!.frame = CGRect(x: margin, y: confirmCallButton!.frame.maxY + 8.0, width: width, height: fheight)
            self.savePhoneButton!.frame = CGRect(x: self.view.frame.width - self.phoneFieldSpace, y: confirmCallButton!.frame.maxY + 8.0, width: 55, height: 40)
            self.notConfirmCallButton!.frame = CGRect(x: margin,y: phoneField!.frame.maxY + margin,width: width,height: checkButtonHeight)
        }else{
            self.notConfirmCallButton!.frame = CGRect(x: margin,y: confirmCallButton!.frame.maxY + margin,width: width,height: checkButtonHeight)
        }
        self.confirmCallOptionButton!.frame = CGRect(x: margin,y: notConfirmCallButton!.frame.maxY + margin,width: width,height: checkButtonHeight)
        self.sectionTitleComments!.frame = CGRect(x: margin, y: confirmCallOptionButton!.frame.maxY + 28.0, width: width, height: lheight)
        self.comments!.frame = CGRect(x: margin,y: self.sectionTitleComments!.frame.maxY + margin,width: width,height: 65)
        self.sectionTitleWine!.frame = CGRect(x: margin,y: self.comments!.frame.maxY + margin,width: width,height: 50)

        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height - 154)
        self.content!.contentSize = CGSize(width: self.view.frame.width, height: self.comments!.frame.maxY + 88)
        self.layerLine.frame = CGRect(x: 0, y: self.content.frame.maxY,  width: self.view.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - (8 + widthButton), y: self.content!.frame.maxY + 16, width: widthButton, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8, y: self.content!.frame.maxY + 16, width: widthButton, height: 34)
        self.confirmCallOptionButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: checkImageBottom, right:0 )
        self.notConfirmCallButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: checkImageBottom, right:0 )
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
    func nextStep(){
        self.comments!.resignFirstResponder()
        let commentsText = self.comments!.text ==  NSLocalizedString("checkout.field.comments", comment:"") ? "" : self.comments!.text
        self.paramsToOrder!["comments"] = commentsText
        self.paramsToOrder!["pickingInstruction"] = self.confirmSelected
        self.paramsToConfirm!["pickingInstruction"] = self.confirmText
        let nextController = GRCheckOutPymentViewController()
        nextController.paramsToOrder = self.paramsToOrder
        nextController.paramsToConfirm = self.paramsToConfirm
        self.navigationController?.pushViewController(nextController, animated: true)
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
    func confirmCallSelected(_ button:UIButton){
        if self.confirmSelected != button.tag {
            self.confirmCallButton?.isSelected = (self.confirmCallButton == button)
            self.notConfirmCallButton?.isSelected = (self.notConfirmCallButton == button)
            self.confirmCallOptionButton?.isSelected = (self.confirmCallOptionButton == button)
            self.confirmSelected = button.tag
            self.confirmText = button.titleLabel!.text!
        
            if confirmSelected == 3{
                self.confirmText = "\(self.confirmText)\n\(self.phoneField!.text!)"
                self.phoneField?.isEnabled = true
                self.phoneField?.textColor = UIColor.black
                self.showPhoneField = true
            }else{
                self.phoneField?.isEnabled = false
                self.phoneField?.textColor = WMColor.gray
                self.showPhoneField = false
            }
        
            self.showPhoneFieldAnimated()
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
        if UserCurrentSession.sharedInstance.userSigned?.profile.phoneHomeNumber == "" {
            if UserCurrentSession.sharedInstance.userSigned?.profile.cellPhone == "" {
                phone =  UserCurrentSession.sharedInstance.userSigned?.profile.phoneWorkNumber as! String
                self.defaultPhoneType = 2
                self.defaultPhone = phone
            }else{
              phone =  UserCurrentSession.sharedInstance.userSigned?.profile.cellPhone as! String
              self.defaultPhoneType = 1
              self.defaultPhone = phone
            }
        }else{
            phone = UserCurrentSession.sharedInstance.userSigned?.profile.phoneHomeNumber as! String
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
    
    /**
     Saves new phone in user profile
     */
    func savePhone(){
        
        if !self.validatePhone() {
            return
        }
        
        let phoneDefault = self.phoneField!.text!
        let home = self.defaultPhoneType == 0 ? phoneDefault : UserCurrentSession.sharedInstance.userSigned?.profile.phoneHomeNumber as! String
        let work = self.defaultPhoneType == 2 ? phoneDefault :UserCurrentSession.sharedInstance.userSigned?.profile.phoneWorkNumber as! String
        let cellphone = self.defaultPhoneType == 1 ? phoneDefault :UserCurrentSession.sharedInstance.userSigned?.profile.cellPhone as! String
        
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"userProfile"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"userProfile"))
        alert?.showicon(UIImage(named:"userProfile"))
        alert?.setMessage(NSLocalizedString("gr.alert.phone", comment: ""))
            alert?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel", comment: ""), leftAction: {
            self.resetPhoneField()
            alert?.close()
            }, rightText: NSLocalizedString("invoice.message.continue", comment: ""), rightAction: {
                UserCurrentSession.sharedInstance.setMustUpdatePhoneProfile(home, work: work, cellPhone: cellphone)
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
      let products =  UserCurrentSession.sharedInstance.itemsGR
        let upcsIncart : NSMutableArray =  []
        let itemsInShoppingCart = products!["items"] as? [[String:Any]]
        for items in itemsInShoppingCart! {
            upcsIncart.add(items["upc"] as! String)
        }
        for upc in UserCurrentSession.sharedInstance.upcSearch {
            if upcsIncart.contains(upc) {
                showMessageInCommens =  true
                break
            }
        }
        print(showMessageInCommens)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.comments!.frame.maxY + 10)
    }
    
    //MARK: -TextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if NSString(string:textView.text).length + (NSString(string:text).length - range.length) ==  0{
            textView.text = NSLocalizedString("checkout.field.comments", comment:"")
            textView.resignFirstResponder()
            textView.textColor = UIColor.gray
            
            if self.showMessageInCommens && UserCurrentSession.sharedInstance.activeCommens {
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
            if self.showMessageInCommens && UserCurrentSession.sharedInstance.activeCommens {
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.comments!.resignFirstResponder()
        let _ = self.phoneField!.resignFirstResponder()
    }
}
