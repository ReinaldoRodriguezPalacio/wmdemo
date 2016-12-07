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
    case number
    case name
    case numAddress
    case string
    case alphanumeric
    case password
    case rfc
    case rfcm
    case email
    case list
    case check
    case none
    case phone
}

class FormFieldView : UIEdgeTextField {
    
    let textBorderOn = WMColor.light_blue.cgColor
    let textBorderOff = UIColor.white.cgColor
    let textBorderError = WMColor.red.cgColor
    
    var isRequired : Bool = false 
    var nameField : String!
    var validMessageText : String!
    var typeField : TypeField = TypeField.none
    var isValid : Bool = true
    var minLength : Int! = 0
    var maxLength : Int! = 0
    var disablePaste : Bool = false
    var imageList : UIImageView? = nil
    var imageCheck : UIImageView? = nil
    var onBecomeFirstResponder : (() -> Void)? = nil
    
    var delegateCustom : CustomFormFIeldDelegate!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        delegateCustom = CustomFormFIeldDelegate()
        
        self.clipsToBounds = false
        self.layer.borderWidth = 1
        self.layer.borderColor = textBorderOff
        self.layer.cornerRadius = 5
        self.backgroundColor =  WMColor.light_light_gray
        self.font = WMFont.fontMyriadProRegularOfSize(14)
        self.isValid = true
    }
   
    func setCustomAttributedPlaceholder(_ placeholder : NSMutableAttributedString){
        var str = placeholder
        if(self.isRequired){
           let attrStr = NSMutableAttributedString()
            attrStr.append(NSAttributedString(string: "*"))
            attrStr.append(placeholder)
            str = attrStr
        }
        
        self.attributedPlaceholder = str
    }
    
    func setCustomPlaceholder(_ placeholder : String){
        var str = placeholder
        if(self.isRequired){
            str = "*" + placeholder
        }
        
        self.attributedPlaceholder = NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:WMColor.gray , NSFontAttributeName:WMFont.fontMyriadProLightOfSize(14)])
    }
    
    func setCustomPlaceholderRegular(_ placeholder : String){
        var str = placeholder
        if(self.isRequired){
            str = "*" + placeholder
        }
        self.attributedPlaceholder = NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:WMColor.empty_gray , NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14)])
    }
    
    func setSelectedCheck( _ isCheck: Bool){
        if typeField == TypeField.check{
            //self.setCustomPlaceholderRegular(self.placeholder!)
            if self.imageCheck == nil {
                self.imageCheck = UIImageView()
                self.addSubview(self.imageCheck!)
            }
            let imageName = isCheck ? "checkAddressOn" : "checkTermOff"
            self.imageCheck!.image = UIImage(named: imageName)
            self.imageCheck!.frame = CGRect(x: 2  , y: (self.frame.height - 20 ) / 2  ,width: 16,height: 16)
        }
    }
    
    func setImageTypeField(){
        if typeField == TypeField.list{
            if self.imageList == nil {
                self.imageList = UIImageView()
                self.addSubview(self.imageList!)
                self.imageList!.image = UIImage(named: "fieldListOpen")
                self.imageList!.frame = CGRect(x: self.frame.width - 30  , y: (self.frame.height - 16 ) / 2  ,width: 16,height: 16)
            }
        }
        if typeField == TypeField.check{
            self.borderStyle = UITextBorderStyle.none
            self.backgroundColor = UIColor.white
            if self.imageCheck == nil {
                self.imageCheck = UIImageView()
                self.addSubview(self.imageCheck!)
                self.imageCheck!.image = UIImage(named: "checkTermOff")
                self.imageCheck!.frame = CGRect(x: 2  , y: (self.frame.height - 20 ) / 2  ,width: 16,height: 16)
            }
        }
    }
    
    
    override func becomeFirstResponder() -> Bool {
        if (onBecomeFirstResponder != nil) {
            onBecomeFirstResponder!()
            return false
        }
        self.layer.borderColor =  textBorderOn
        if typeField == TypeField.list{
            self.imageList!.image = UIImage(named: "fieldListClose")

        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.layer.borderColor =  textBorderOff
        
        if typeField == TypeField.list{
            self.imageList!.image = UIImage(named: "fieldListOpen")
 
        }
        return super.resignFirstResponder()
    }
    
    
    
    func validate() -> String? {
        self.isValid = true
        var message : String? = nil
        self.text = self.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        if isRequired{
            if self.text == "" {
                self.isValid = false
                message =  NSLocalizedString("field.validate.required",comment:"")
            }
        }
        let elementsInText = self.text!.characters.count
        if maxLength > 0 && elementsInText > 0 {
            if elementsInText > maxLength {
                self.isValid = false
                message = NSLocalizedString("field.validate.maxlength",comment:"") + "\(maxLength)"
                
                switch (typeField) {
                    case .number:
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
                case .number:
                    let digits = NSLocalizedString("field.validate.minmaxlength.digit",comment:"")
                    message = "\(message!) \(digits)"
                default:
                    let chars = NSLocalizedString("field.validate.minmaxlength.characters",comment:"")
                    message = "\(message!) \(chars)"
                }
            }
        }
        
        if self.isValid && typeField != .none{
            var validate: String? = nil
            switch (typeField) {
            case .number:
                validate = self.validateNumber()
            case .numAddress:
                validate = self.validateNumAddress()
            case .name:
                let alphanumericset = CharacterSet(charactersIn: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZáéíóúÁÉÍÓÚ ").inverted
                if let contains = self.text!.rangeOfCharacter(from: alphanumericset) {
                    return   NSLocalizedString("field.validate.text.invalid",comment:"")
                }
                validate = self.validateName()
            case .string:
                validate = self.validateString()
            case .alphanumeric:
                validate = self.validateAlphanumeric()
            case .password:
                validate = self.validatePass() as String
            case .rfc:
                validate = self.validateRFC()
            case .rfcm:
                validate = self.validateRFCM()
            case .phone:
                validate = self.validatePhone()
            case .email:
                self.isValid =  SignUpViewController.isValidEmail(self.text!)
            default:
                break
            }
            
            if validate != nil {
                var regExVal: NSRegularExpression?
                do {
                    regExVal = try NSRegularExpression(pattern: validate!, options: NSRegularExpression.Options.caseInsensitive)
                } catch let error as NSError {
                    print(error.localizedDescription)
                    regExVal = nil
                }
                let matches = regExVal!.numberOfMatches(in: self.text!, options: [], range: NSMakeRange(0, self.text!.characters.count))
                
                if matches > 0 {
                    self.isValid = true
                }else{
                    self.isValid = false
                }
            }
            
            if typeField == .password {
                
                let sqlReservedKeys = [ "select", "from", "insert", "update", "delete", "drop", "create", "where", "values", "null", "declare", "script", "xp_", "crlf", "%3A", "%3B", "%3C", "%3D", "%3E", "%3F", "&quot;", "&amp;", "&lt;", "&gt;", "exec", "waitfor", "delay", "onvarchar"]
                
                for sqlReservedkey in sqlReservedKeys {
                    if self.text!.lowercased().contains(sqlReservedkey) {
                        self.isValid = false
                    }
                }
                
            }
           
            if !self.isValid{
                if validMessageText == nil {
                    message = NSLocalizedString("field.validate.text",comment:"")
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
        let regString : String = "^[A-Za-zñÑÁáÉéÍíÓóÚú \\@]{0,100}[._-]{0,2}$";
        return  regString
    }
    
    func validateString() -> String{
        let regString : String = "^[A-Za-zñÑÁáÉéÍíÓóÚú \\@]{0,100}[._-]{0,2}$";
        return  regString
    }
    
    func validateAlphanumeric() -> String{
        let regString : String = "^[A-Z0-9a-zñÑÁáÉéÍíÓóÚú \\@]{0,100}[._-]{0,2}$"
        return  regString
    }
    
    func validatePass()-> NSString{
        let regString : String = "^[a-zA-Z0-9_ ,ÑñÁÉÍÓÚáéíóú./()*-]{8,20}$"//"^[A-Za-z0-9]{5,20}$";
        return regString as NSString
    }

    func validateRFC ()-> String{
        let regString : String = "^[a-zA-Z&]{4}(\\d{6})([A-Z0-9a-z]{3})?$"
        return  regString
    }
    
    func validateRFCM ()-> String{
        let regString : String = "^[a-zA-Z&]{3}(\\d{6})([A-Z0-9a-z]{3})?$"
        return  regString
    }
    
    func validatePhone() -> String{
        let regString : String = "\\(?([0-9]{3})\\)?([ .-]?)([0-9]{3})\\2([0-9]{4})"
        return  regString
    }
    
    
    func setCustomDelegate(_ delegate:UITextFieldDelegate?){
        self.delegateCustom.delegateOnChange = delegate
        super.delegate = delegateCustom
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return !disablePaste
        }
        return super.canPerformAction(action,withSender:sender)
    }
    
    
}

class CustomFormFIeldDelegate : NSObject, UITextFieldDelegate {
    //MARK Delegate UITextField
    
    var delegateOnChange : UITextFieldDelegate?
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.delegateOnChange?.textFieldShouldBeginEditing != nil {
            return self.delegateOnChange!.textFieldShouldBeginEditing!(textField)
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegateOnChange?.textFieldDidBeginEditing?(textField)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
        if self.delegateOnChange?.textFieldShouldEndEditing != nil {
            return self.delegateOnChange!.textFieldShouldEndEditing!(textField)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        self.delegateOnChange?.textFieldDidEndEditing?(textField)
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if self.delegateOnChange?.textFieldShouldClear != nil {
            return self.delegateOnChange!.textFieldShouldClear!(textField)
        }
        return false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.delegateOnChange?.textFieldShouldReturn != nil {
            return self.delegateOnChange!.textFieldShouldReturn!(textField)
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let field = textField as? FormFieldView {
            if field.maxLength > 0 {
                var txtAfterUpdate:NSString = textField.text! as NSString
                txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
                let _ = self.delegateOnChange?.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
                return txtAfterUpdate.length <= field.maxLength
            }
        }
        return self.delegateOnChange!.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
    }

}
