//
//  FormFieldView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import QuartzCore

enum TypeField {
    case Number
    case Name
    case NumAddress
    case String
    case Alphanumeric
    case Password
    case RFC
    case RFCM
    case Email
    case List
    case Check
    case None
}

class FormFieldView : UIEdgeTextField {
    
    let textBorderOn = WMColor.profileTextEditingColor.CGColor
    let textBorderOff = UIColor.whiteColor().CGColor
    let textBorderError = WMColor.profileErrorColor.CGColor
    
    var isRequired : Bool = false
    var nameField : String!
    var validMessageText : String!
    var typeField : TypeField = TypeField.None
    var isValid : Bool = true
    var minLength : Int! = 0
    var maxLength : Int! = 0
    var disablePaste : Bool = false
    var imageList : UIImageView? = nil
    var onBecomeFirstResponder : (() -> Void)? = nil
    
    var delegateCustom : CustomFormFIeldDelegate!
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        delegateCustom = CustomFormFIeldDelegate()
        
        self.clipsToBounds = false
        self.layer.borderWidth = 1
        self.layer.borderColor = textBorderOff
        self.layer.cornerRadius = 5
        self.backgroundColor =  WMColor.loginFieldBgColor
        self.font = WMFont.fontMyriadProRegularOfSize(14)
        self.isValid = true
    }
   
    func setCustomPlaceholder(placeholder : String){
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName:WMColor.loginFieldTextPlaceHolderColor , NSFontAttributeName:WMFont.fontMyriadProLightOfSize(14)])
    }
    
    func setImageTypeField(){
        if typeField == TypeField.List{
            if self.imageList == nil {
                self.imageList = UIImageView()
                self.addSubview(self.imageList!)
                self.imageList!.image = UIImage(named: "fieldListOpen")
                self.imageList!.frame = CGRectMake(self.frame.width - 30  , (self.frame.height - 16 ) / 2  ,16,16)
            }
        }
        if typeField == TypeField.Check{
            self.borderStyle = UITextBorderStyle.None
            self.backgroundColor = UIColor.whiteColor()
            if self.imageList == nil {
                self.imageList = UIImageView()
                self.addSubview(self.imageList!)
                self.imageList!.image = UIImage(named: "checkTerm")
                self.imageList!.frame = CGRectMake(2  , (self.frame.height - 18 ) / 2  ,16,16)
            }
        }
    }
    
    
    override func becomeFirstResponder() -> Bool {
        if (onBecomeFirstResponder != nil) {
            onBecomeFirstResponder!()
            return false
        }
        self.layer.borderColor =  textBorderOn
        if typeField == TypeField.List{
            self.imageList!.image = UIImage(named: "fieldListClose")

        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.layer.borderColor =  textBorderOff
        
        if typeField == TypeField.List{
            self.imageList!.image = UIImage(named: "fieldListOpen")

        }
        return super.resignFirstResponder()
    }
    
    
    
    func validate() -> String? {
        self.isValid = true
        var message : String? = nil
        self.text = self.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if isRequired{
            if self.text == "" {
                self.isValid = false
                message =  NSLocalizedString("field.validate.required",comment:"")
            }
        }
        let elementsInText = count(self.text)
        if maxLength > 0 && elementsInText > 0 {
            if elementsInText > maxLength {
                self.isValid = false
                message = NSLocalizedString("field.validate.maxlength",comment:"") + "\(maxLength)"
                
                switch (typeField) {
                    case .Number:
                        let digits = NSLocalizedString("field.validate.minmaxlength.digit",comment:"")
                        message = "\(message!) \(digits)"
                    default:
                        let chars = NSLocalizedString("field.validate.minmaxlength.characters",comment:"")
                        message = "\(message!) \(chars)"
                }
            }
        }
        
        if minLength > 0 && elementsInText > 0{
            if elementsInText < minLength {
                self.isValid = false
                message = NSLocalizedString("field.validate.minlength",comment:"") + "\(minLength)"
                switch (typeField) {
                case .Number:
                    let digits = NSLocalizedString("field.validate.minmaxlength.digit",comment:"")
                    message = "\(message!) \(digits)"
                default:
                    let chars = NSLocalizedString("field.validate.minmaxlength.characters",comment:"")
                    message = "\(message!) \(chars)"
                }
            }
        }
        
        if self.isValid && typeField != .None{
            var validate: String? = nil
            switch (typeField) {
                case .Number:
                    validate = self.validateNumber()
                case .NumAddress:
                    validate = self.validateNumAddress()
                case .Name:
                    validate = self.validateName()
                case .String:
                    validate = self.validateString()
                case .Alphanumeric:
                    validate = self.validateAlphanumeric()
                case .Password:
                    validate = self.validatePass() as String
                case .RFC:
                    validate = self.validateRFC()
                case .RFCM:
                    validate = self.validateRFCM()
                
                case .Email:
                    self.isValid =  SignUpViewController.isValidEmail(self.text)
                default:
                    break
            }
            
            if validate != nil {
                var error: NSError?
                var regExVal = NSRegularExpression(pattern: validate!, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
                let matches = regExVal!.numberOfMatchesInString(self.text, options: nil, range: NSMakeRange(0, count(self.text)))
                
                if matches > 0 {
                    self.isValid = true
                }else{
                    self.isValid = false
                }
            }

           
            if !self.isValid{
                if validMessageText == nil {
                    message = NSLocalizedString("field.validate.text.invalid",comment:"")
                }else {
                    message = NSLocalizedString(validMessageText,comment:"")
                }
            }
        }
        return message
    }
    
    func validateNumber() -> String{
        let regString : String = "^[0-9]{0,20}$";
        return  regString
    }
    
    func validateNumAddress ()-> String {
        let regString : String = "^[A-Za-z0-9 ]{0,20}$"
        return  regString
    }
    
    func validateName() -> String{
        let regString : String = "^[A-Za-z-ñÑÁáÉéÍíÓóÚú \\@]{0,100}$";
        return  regString
    }
    
    func validateString() -> String{
        let regString : String = "^[A-Za-z-.ñÑÁáÉéÍíÓóÚú \\@]{0,100}$";
        return  regString
    }
    
    func validateAlphanumeric() -> String{
        let regString : String = "^[A-Z0-9a-z-.ñÑÁáÉéÍíÓóÚú \\@]{0,100}$"
        return  regString
    }
    
    func validatePass()-> NSString{
        let regString : String = "^[A-Za-z0-9]{5,20}$";
        return regString
    }

    func validateRFC ()-> String{
        let regString : String = "^[a-zA-Z&]{4}(\\d{6})([A-Z0-9a-z]{3})?$"
        return  regString
    }
    
    func validateRFCM ()-> String{
        let regString : String = "^[a-zA-Z&]{3}(\\d{6})([A-Z0-9a-z]{3})?$"
        return  regString
    }
    
    
    func setCustomDelegate(delegate:UITextFieldDelegate?){
        self.delegateCustom.delegateOnChange = delegate
        super.delegate = delegateCustom
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "paste:" {
            return !disablePaste
        }
        return super.canPerformAction(action,withSender:sender)
    }
    
    
}

class CustomFormFIeldDelegate : NSObject, UITextFieldDelegate {
    //MARK Delegate UITextField
    
    var delegateOnChange : UITextFieldDelegate?
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if self.delegateOnChange?.textFieldShouldBeginEditing != nil {
            return self.delegateOnChange!.textFieldShouldBeginEditing!(textField)
        }
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        self.delegateOnChange?.textFieldDidBeginEditing?(textField)
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
        if self.delegateOnChange?.textFieldShouldEndEditing != nil {
            return self.delegateOnChange!.textFieldShouldEndEditing!(textField)
        }
        return true
    }
    func textFieldDidEndEditing(textField: UITextField){
        self.delegateOnChange?.textFieldDidEndEditing?(textField)
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if self.delegateOnChange?.textFieldShouldClear != nil {
            return self.delegateOnChange!.textFieldShouldClear!(textField)
        }
        return false
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.delegateOnChange?.textFieldShouldReturn != nil {
            return self.delegateOnChange!.textFieldShouldReturn!(textField)
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let field = textField as? FormFieldView {
            if field.maxLength > 0 {
                var txtAfterUpdate:NSString = textField.text as NSString
                txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
                self.delegateOnChange?.textField!(textField, shouldChangeCharactersInRange: range, replacementString: string)
                return txtAfterUpdate.length <= field.maxLength
            }
        }
        return self.delegateOnChange!.textField!(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }

}
