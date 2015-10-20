//
//  FiscalAddressPersonF.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 23/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class FiscalAddressPersonF: AddressView {

    var name : FormFieldView!
    var lastName : FormFieldView!
    var lastName2 : FormFieldView!
    var rfc : FormFieldView!
    
    override init(frame: CGRect, isLogin: Bool, isIpad:Bool) {
        super.init(frame: frame, isLogin: isLogin, isIpad: isIpad )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(){
        super.setup()
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.address.person.name",comment:""))
        self.name!.typeField = TypeField.Name
        self.name!.minLength = 2
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.address.person.name",comment:"")
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastName",comment:""))
        self.lastName!.typeField = TypeField.String
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.address.person.lastName",comment:"")
        
        self.lastName2 = FormFieldView()
        self.lastName2!.isRequired = false
        self.lastName2!.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastName2",comment:""))
        self.lastName2!.typeField = TypeField.String
        self.lastName2!.minLength = 2
        self.lastName2!.maxLength = 25
        self.lastName2!.nameField = NSLocalizedString("profile.address.person.lastName2",comment:"")
        
        self.rfc = FormFieldView()
        self.rfc!.isRequired = true
        self.rfc!.setCustomPlaceholder(NSLocalizedString("profile.address.rfc",comment:""))
        self.rfc!.typeField = TypeField.RFC
        self.rfc!.minLength = 10
        self.rfc!.maxLength = 13
        self.rfc!.validMessageText = "field.validate.text.invalid.rfc"
        self.rfc!.nameField = NSLocalizedString("profile.address.rfc",comment:"")
        
        self.ieps = FormFieldView()
        self.ieps!.isRequired = false
        self.ieps!.setCustomPlaceholder(NSLocalizedString("profile.address.ieps",comment:""))
        self.ieps!.typeField = TypeField.Number
        self.ieps!.minLength = 14
        self.ieps!.maxLength = 14
        self.ieps!.keyboardType = UIKeyboardType.NumberPad
        self.ieps!.inputAccessoryView = self.keyboardBar
        self.ieps!.nameField = NSLocalizedString("profile.address.ieps",comment:"")
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.address.email",comment:""))
        self.email!.typeField = TypeField.Email
        self.email!.nameField = NSLocalizedString("profile.address.email",comment:"")
        self.email!.maxLength = 45
        
        self.addSubview(name!)
        self.addSubview(lastName!)
        self.addSubview(lastName2!)
        self.addSubview(rfc!)
        self.addSubview(ieps!)
        self.addSubview(email!)
        self.addSubview(telephone!)

        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.name?.frame = CGRectMake(leftRightPadding,  0, self.bounds.width - (leftRightPadding*2), fieldHeight)
        self.lastName?.frame = CGRectMake(leftRightPadding,  name!.frame.maxY + 8, (self.name!.frame.width / 2) - 5 , fieldHeight)
        self.lastName2?.frame = CGRectMake(self.lastName!.frame.maxX + 10 , self.lastName!.frame.minY,   self.lastName!.frame.width  , fieldHeight)
        self.rfc?.frame = CGRectMake(leftRightPadding,  lastName2!.frame.maxY + 8, self.lastName!.frame.width , fieldHeight)
        self.ieps?.frame = CGRectMake(self.rfc!.frame.maxX + 10 , self.rfc!.frame.minY,   self.rfc!.frame.width  , fieldHeight)
        self.email?.frame = CGRectMake(leftRightPadding, self.ieps!.frame.maxY + 8, self.name!.frame.width , fieldHeight)
        self.telephone?.frame = CGRectMake(leftRightPadding,  email!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.viewAddress.frame = CGRectMake(0, self.telephone!.frame.maxY + 8, self.bounds.width, showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
    }
    
    override func setItemWithDictionary(itemValues: NSDictionary) {
        super.setItemWithDictionary(itemValues)
        if self.item != nil && self.idAddress != nil {
            self.name!.text = self.item!["firstName"] as? String
            self.lastName!.text = self.item!["lastName"] as? String
            self.lastName2!.text = self.item!["lastName2"] as? String
            self.rfc!.text = self.item!["rfc"] as? String
            self.ieps!.text = self.item!["ieps"] as? String
            self.email!.text = self.item!["rfcEmail"] as? String
            self.telephone!.text = self.item!["phoneNumber"] as? String
        }
    }
    
    
    override func validateAddress() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(lastName!)
        }
        if !error{
            error = viewError(lastName2!)
        }
        if !error{
            error = viewError(rfc!)
        }
        if !error{
            error = viewError(ieps!)
        }
        if !error{
            error = viewError(email!)
        }
        if !error{
            error = viewError(telephone!)
            let toValidate : NSString = telephone!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if toValidate.length > 2 {
                if toValidate == "0000000000" || toValidate.substringToIndex(2) == "00" {
                    error = self.viewError(telephone!, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                }
            }
        }
        if error{
            return false
        }
        return super.validateAddress()
    }
    
    override func getParams() -> [String:AnyObject]{
        var paramsAddress : [String:AnyObject] =   super.getParams()
        let userParams = ["profile":["lastName2":self.lastName2!.text! ,"name":self.name!.text! ,"lastName":self.lastName!.text! ]]
        paramsAddress.updateValue(userParams as AnyObject, forKey: "user")
        paramsAddress.updateValue(self.rfc!.text!, forKey: "rfc")
        paramsAddress.updateValue(self.email!.text!, forKey: "rfcEmail")
        paramsAddress.updateValue(self.ieps!.text!, forKey: "ieps")
        paramsAddress.updateValue(self.telephone!.text!, forKey: "TelNumber")
        return paramsAddress
    }
    
}
