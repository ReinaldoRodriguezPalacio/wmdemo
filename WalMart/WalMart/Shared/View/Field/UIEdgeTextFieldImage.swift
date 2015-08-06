//
//  UIEdgeTextFieldImage.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol UIEdgeTextFieldImageProtocol {
    func fieldChangeValue(value:String)
}

class UIEdgeTextFieldImage : UITextField {
    
    var valueDelegate : UIEdgeTextFieldImageProtocol? = nil
    var imageNotSelected : UIImage?
    var imageSelected : UIImage?
    var imageIcon : UIImageView?
    var customRightView = false
    var typeField : TypeField = TypeField.None
    var nameField : String!
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func setup(){
        self.layer.cornerRadius = 5
        self.backgroundColor =  WMColor.loginFieldBgColor
        self.font = WMFont.fontMyriadProRegularOfSize(14)
        imageIcon = UIImageView()
        imageIcon?.frame = CGRectMake (0 ,0, 45, 45 )
        self.addSubview(imageIcon!)
    }
    
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 45, 11);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 45 , 11);
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        if self.customRightView {
            return CGRectMake(bounds.size.width - 30, 12, 20, 20)
        }
        return bounds
    }
    
    override func becomeFirstResponder() -> Bool {
        if self.secureTextEntry {
            self.font = UIFont.systemFontOfSize(14)
        }
        imageIcon?.image = imageSelected
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if self.secureTextEntry {
           self.font = UIFont.systemFontOfSize(14)
        }
        if  countElements(self.text) == 0 {
            self.font = WMFont.fontMyriadProRegularOfSize(14)
        }
        imageIcon?.image = imageNotSelected
        let resign =  super.resignFirstResponder()
        if valueDelegate != nil {
            valueDelegate!.fieldChangeValue(self.text)
        }
        return resign;
    }
    
    func setPlaceholder(placeholder : String){
        imageIcon?.image = imageNotSelected
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName:WMColor.loginFieldTextPlaceHolderColor , NSFontAttributeName:WMFont.fontMyriadProLightOfSize(14)])
    }
    
    func validate() -> String {
        var isValid = true
        var message : String = ""
       
        if self.text == "" {
            isValid = false
            message =  NSLocalizedString("field.validate.required",comment:"")
        }
        
        if isValid {
            switch (typeField) {
            case .Email:
                isValid =  SignUpViewController.isValidEmail(self.text)
                if !isValid{
                    message = NSLocalizedString("field.validate.text.invalid",comment:"")
                }
            case .Password:
                if countElements(self.text) == 0
                {
                    isValid = false
                    message = NSLocalizedString("field.validate.password.empty",comment:"")
                    //isValid = false
                    //message = NSLocalizedString("field.validate.password",comment:"")
                }
                if countElements(self.text) < 5 || countElements(self.text) > 20
                {
                    isValid = false
                    message = NSLocalizedString("field.validate.password.length",comment:"")
                    //isValid = false
                    //message = NSLocalizedString("field.validate.password",comment:"")
                }
                
                var error: NSError?
                var regExVal = NSRegularExpression(pattern: validatePass(), options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
                let matches = regExVal!.numberOfMatchesInString(self.text, options: nil, range: NSMakeRange(0, countElements(self.text)))
                
                if matches > 0 {
                    isValid = true
                }else{
                    isValid = false
                    message = NSLocalizedString("field.validate.password.length",comment:"")
                }
                
            case .None:
                isValid = true
            default:
                break
            }
        }
        
        return message
    }
    
    func validatePass()-> NSString {
        let regString : String = "^[A-Za-z0-9]{5,20}$";
        return regString
    }

    
}

