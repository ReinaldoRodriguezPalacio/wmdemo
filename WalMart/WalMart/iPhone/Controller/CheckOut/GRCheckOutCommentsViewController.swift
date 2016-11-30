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
    var paramsToOrder : NSMutableDictionary?
    var paramsToConfirm : NSMutableDictionary?
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
        self.view.backgroundColor = UIColor.whiteColor()
        
        if IS_IPAD {
            self.backButton?.hidden = true
        }
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            self.savePhone()
        })
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
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
        
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.confirm", comment: ""), frame: CGRectMake(margin, margin, width, lheight))
        self.content.addSubview(self.sectionTitle!)
        
        self.confirmCallButton = UIButton()
        self.confirmCallButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.confirmCallButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.confirmCallButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.confirmCallButton!.setTitle(NSLocalizedString("gr.confirmacall", comment: ""), forState: .Normal)
        self.confirmCallButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.confirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.confirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.confirmCallButton!.selected = true
        self.confirmCallButton!.tag = 3
        self.content.addSubview(self.confirmCallButton!)

        self.phoneField = FormFieldView(frame: CGRectMake(margin, confirmCallButton!.frame.maxY + 8.0, width, fheight))
        let phone = self.getDefaultPhone()
        //self.phoneField!.setCustomPlaceholder("Teléfono: \(phone)")
        self.phoneField!.isRequired = true
        self.phoneField!.typeField = TypeField.Phone
        self.phoneField!.nameField = "Teléfono"
        self.phoneField!.maxLength = 10
        self.phoneField!.minLength = 10
        self.phoneField!.disablePaste = true
        self.phoneField!.text = phone
        self.phoneField!.keyboardType = UIKeyboardType.NumberPad
        self.phoneField!.inputAccessoryView = viewAccess
        self.phoneField!.delegate = self
        self.content.addSubview(self.phoneField!)
        
        self.savePhoneButton = UIButton(type: .Custom)
        self.savePhoneButton!.setTitle("Guardar", forState: .Normal)
        self.savePhoneButton!.setTitleColor(WMColor.light_blue, forState: .Normal)
        self.savePhoneButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.savePhoneButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.savePhone), forControlEvents: UIControlEvents.TouchUpInside)
        self.savePhoneButton!.alpha = 0.0
        self.content!.addSubview(self.savePhoneButton!)
        
        self.confirmCallOptionButton = UIButton()
        self.confirmCallOptionButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.confirmCallOptionButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.confirmCallOptionButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.confirmCallOptionButton!.setTitle(NSLocalizedString("gr.not.confirmacall.detal", comment: ""), forState: .Normal)
        self.confirmCallOptionButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.confirmCallOptionButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallOptionButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.confirmCallOptionButton!.titleLabel?.numberOfLines = 3
        self.confirmCallOptionButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.confirmCallOptionButton!.tag = 1
        self.content.addSubview(self.confirmCallOptionButton!)
        
        self.notConfirmCallButton = UIButton()
        self.notConfirmCallButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.notConfirmCallButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.notConfirmCallButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.confirmCallSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.notConfirmCallButton!.setTitle(NSLocalizedString("gr.not.confirmacall.option.detail", comment: ""), forState: .Normal)
        self.notConfirmCallButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.notConfirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.notConfirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.notConfirmCallButton!.titleLabel?.numberOfLines = 3
        self.notConfirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.notConfirmCallButton!.tag = 2
        self.content.addSubview(self.notConfirmCallButton!)
        
        self.sectionTitleComments = self.buildSectionTitle(NSLocalizedString("checkout.title.comments", comment: ""), frame: CGRectMake(margin, notConfirmCallButton!.frame.maxY + 28.0, width, lheight))
        self.content.addSubview(self.sectionTitleComments!)
        
        self.comments = UITextView()
        self.comments!.layer.cornerRadius = 5.0
        self.comments!.returnKeyType = .Default
        self.comments!.autocapitalizationType = .None
        self.comments!.autocorrectionType = .No
        self.comments!.enablesReturnKeyAutomatically = true
        self.comments!.font = WMFont.fontMyriadProItOfSize(12)
        self.comments!.text = NSLocalizedString("checkout.field.comments", comment:"")
        self.comments!.textColor = UIColor.grayColor()
        self.comments!.backgroundColor = WMColor.light_light_gray
        self.comments!.delegate = self
        self.content.addSubview(self.comments!)

        self.sectionTitleWine = self.buildSectionTitle(NSLocalizedString("checkout.title.wine", comment: ""), frame: CGRectMake(margin, notConfirmCallButton!.frame.maxY + 28.0, width, lheight))
        self.sectionTitleWine.textColor = UIColor.darkGrayColor()
        self.sectionTitleWine.numberOfLines = 4
        self.sectionTitleWine.font = WMFont.fontMyriadProRegularOfSize(12)
        self.content.addSubview(self.sectionTitleWine!)








        
        
        
        let  commentsDefault = NSMutableAttributedString(string: UserCurrentSession.sharedInstance().messageInCommens )
        commentsDefault.addAttribute(NSForegroundColorAttributeName, value: WMColor.light_blue, range:NSMakeRange(0,commentsDefault.length))
        commentsDefault.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProItOfSize(12), range:NSMakeRange(0,commentsDefault.length))
        
        commentsString = NSMutableAttributedString(string: NSLocalizedString("checkout.field.comments", comment:""))
        commentsString!.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range:NSMakeRange(0,commentsString!.length))
        commentsString!.addAttribute(NSFontAttributeName, value: WMFont.fontMyriadProItOfSize(12), range:NSMakeRange(0,commentsString!.length))
        commentsString!.appendAttributedString(commentsDefault)
        
        
        if UserCurrentSession.sharedInstance().activeCommens {
            self.findproductInCar()
            if self.showMessageInCommens {
                self.comments?.attributedText = commentsString
            }
        }
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)

        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: Selector("back"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRCheckOutCommentsViewController.next), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)

        self.confirmText = "\(NSLocalizedString("gr.confirmacall", comment: ""))\n\(self.phoneField!.text!)"
        self.content?.contentOffset = CGPointZero
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
        
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)
        self.sectionTitle!.frame = CGRectMake(margin, margin, width, lheight)
        self.confirmCallButton!.frame = CGRectMake(margin,self.sectionTitle!.frame.maxY + margin,width,20)
        if self.showPhoneField {
            self.phoneField!.frame = CGRectMake(margin, confirmCallButton!.frame.maxY + 8.0, width, fheight)
            self.savePhoneButton!.frame = CGRectMake(self.view.frame.width - self.phoneFieldSpace, confirmCallButton!.frame.maxY + 8.0, 55, 40)
            self.notConfirmCallButton!.frame = CGRectMake(margin,phoneField!.frame.maxY + margin,width,checkButtonHeight)
        }else{
            self.notConfirmCallButton!.frame = CGRectMake(margin,confirmCallButton!.frame.maxY + margin,width,checkButtonHeight)
        }
        self.confirmCallOptionButton!.frame = CGRectMake(margin,notConfirmCallButton!.frame.maxY + margin,width,checkButtonHeight)
        self.sectionTitleComments!.frame = CGRectMake(margin, confirmCallOptionButton!.frame.maxY + 28.0, width, lheight)
        self.comments!.frame = CGRectMake(margin,self.sectionTitleComments!.frame.maxY + margin,width,65)
        self.sectionTitleWine!.frame = CGRectMake(margin,self.comments!.frame.maxY + margin,width,50)

        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - 111)
        self.content!.contentSize = CGSizeMake(self.view.frame.width, self.comments!.frame.maxY + 10)
        self.layerLine.frame = CGRectMake(0, self.view.bounds.height - 65,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
        self.confirmCallOptionButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: checkImageBottom, right:0 )
        self.notConfirmCallButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: checkImageBottom, right:0 )
    }
    
    /**
     Builds an UILabel with the title of section
     
     - parameter title: title of section
     - parameter frame: frame of UILabel
     
     - returns: UILabel
     */
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    /**
     Sends to the next checkout page
     */
    func next(){
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
            viewLoad.backgroundColor = UIColor.whiteColor()
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
    func confirmCallSelected(button:UIButton){
        if self.confirmSelected != button.tag {
            self.confirmCallButton?.selected = (self.confirmCallButton == button)
            self.notConfirmCallButton?.selected = (self.notConfirmCallButton == button)
            self.confirmCallOptionButton?.selected = (self.confirmCallOptionButton == button)
            self.confirmSelected = button.tag
            self.confirmText = button.titleLabel!.text!
        
            if confirmSelected == 3{
                self.confirmText = "\(self.confirmText)\n\(self.phoneField!.text!)"
                self.phoneField?.enabled = true
                self.phoneField?.textColor = UIColor.blackColor()
                self.showPhoneField = true
            }else{
                self.phoneField?.enabled = false
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
    func showSavePhoneButton(didShow:Bool){
        if didShow{
            self.phoneFieldSpace = 71
            UIView.animateWithDuration(0.3, animations: {() in
                self.savePhoneButton!.alpha = 1.0
                self.savePhoneButton!.frame = CGRectMake(self.view.frame.width - self.phoneFieldSpace, self.confirmCallButton!.frame.maxY + 8.0, 55, 40)
                self.phoneField!.frame = CGRectMake(16, self.confirmCallButton!.frame.maxY + 8.0, self.view.frame.width - (self.phoneFieldSpace + 32), 40.0)
            })
        }else{
            self.phoneFieldSpace = 0
            UIView.animateWithDuration(0.3, animations: {() in
                self.savePhoneButton!.alpha = 0.0
                self.savePhoneButton!.frame = CGRectMake(self.view.frame.width - self.phoneFieldSpace, self.confirmCallButton!.frame.maxY + 8.0, 55, 40)
                self.phoneField!.frame = CGRectMake(16, self.confirmCallButton!.frame.maxY + 8.0, self.view.frame.width - (self.phoneFieldSpace + 32), 40.0)
            })
        }
        
    }
    
    /**
     Shows or hide PhoneField
     */
    
    func showPhoneFieldAnimated(){
        if self.showPhoneField{
            UIView.animateWithDuration(0.3, animations: {() in
                self.phoneField!.alpha = 1.0
                self.savePhoneButton!.alpha = 1.0
                self.buildSubViews()
            })
        }else{
            UIView.animateWithDuration(0.3, animations: {() in
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
            if UserCurrentSession.sharedInstance().userSigned?.profile.cellPhone == "" {
                phone =  UserCurrentSession.sharedInstance().userSigned?.profile.phoneWorkNumber as! String
                self.defaultPhoneType = 2
                self.defaultPhone = phone
            }else{
              phone =  UserCurrentSession.sharedInstance().userSigned?.profile.cellPhone as! String
              self.defaultPhoneType = 1
              self.defaultPhone = phone
            }
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
    
    /**
     Saves new phone in user profile
     */
    func savePhone(){
        
        if !self.validatePhone() {
            return
        }
        
        let phoneDefault = self.phoneField!.text!
        let home = self.defaultPhoneType == 0 ? phoneDefault : UserCurrentSession.sharedInstance().userSigned?.profile.phoneHomeNumber as! String
        let work = self.defaultPhoneType == 2 ? phoneDefault :UserCurrentSession.sharedInstance().userSigned?.profile.phoneWorkNumber as! String
        let cellphone = self.defaultPhoneType == 1 ? phoneDefault :UserCurrentSession.sharedInstance().userSigned?.profile.cellPhone as! String
        
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"userProfile"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"userProfile"))
        alert?.showicon(UIImage(named:"userProfile"))
        alert?.setMessage(NSLocalizedString("gr.alert.phone", comment: ""))
            alert?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel", comment: ""), leftAction: {
            self.resetPhoneField()
            alert?.close()
            }, rightText: NSLocalizedString("invoice.message.continue", comment: ""), rightAction: {
                UserCurrentSession.sharedInstance().setMustUpdatePhoneProfile(home, work: work, cellPhone: cellphone)
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
            upcsIncart.addObject(items["upc"] as! String)
        }
        for upc in UserCurrentSession.sharedInstance().upcSearch {
            if upcsIncart.containsObject(upc) {
                showMessageInCommens =  true
                break
            }
        }
        print(showMessageInCommens)
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.view.frame.width, self.comments!.frame.maxY + 10)
    }
    
    //MARK: -TextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if NSString(string:textView.text).length + (NSString(string:text).length - range.length) ==  0{
            textView.text = NSLocalizedString("checkout.field.comments", comment:"")
            textView.resignFirstResponder()
            textView.textColor = UIColor.grayColor()
            
            if self.showMessageInCommens && UserCurrentSession.sharedInstance().activeCommens {
                textView.attributedText =  commentsString
            }
            
        }
        
        return NSString(string:textView.text).length + (NSString(string:text).length - range.length) <= 200
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if textView.text ==  NSLocalizedString("checkout.field.comments", comment:"") || textView.text == self.commentsString?.string {
            textView.text = ""
            textView.textColor = WMColor.dark_gray
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        //let offset = self.content!.contentOffset.y + 150
        var offset = abs((self.content.contentSize.height - self.content.frame.height) + 150)
        if IS_IPAD {
            offset = 120
        }
        self.content!.contentOffset = CGPointMake(0, offset)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text =  NSLocalizedString("checkout.field.comments", comment:"")
            textView.textColor = UIColor.grayColor()
            if self.showMessageInCommens && UserCurrentSession.sharedInstance().activeCommens {
                textView.attributedText =  commentsString
            }
        }
        self.content!.contentOffset = CGPointZero
    }
    
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        
        if txtAfterUpdate.length >= 11 {
            return false
        }
        
        self.showSavePhoneButton((txtAfterUpdate != self.defaultPhone))
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.phoneField!.layer.borderColor = WMColor.light_blue.CGColor
        self.phoneField!.layer.borderWidth = 0.5
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.phoneField!.layer.borderColor = WMColor.light_light_gray.CGColor
        self.phoneField!.layer.borderWidth = 0.0
        self.resetPhoneField()
    }
    
    //MARK: -Scroll

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        self.comments!.resignFirstResponder()
        self.phoneField!.resignFirstResponder()
    }
}