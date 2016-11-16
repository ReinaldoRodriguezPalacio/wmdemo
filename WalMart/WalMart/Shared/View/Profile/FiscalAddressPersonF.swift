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
    
    override init(frame: CGRect, isLogin: Bool, isIpad:Bool, typeAddress: TypeAddress) {
        super.init(frame: frame, isLogin: isLogin, isIpad: isIpad, typeAddress: typeAddress )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(){
        super.setup()
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.address.person.name",comment:""))
        self.name!.typeField = TypeField.name
        self.name!.minLength = 2
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.address.person.name",comment:"")
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastName",comment:""))
        self.lastName!.typeField = TypeField.string
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.address.person.lastName",comment:"")
        
        self.lastName2 = FormFieldView()
        self.lastName2!.isRequired = false
        self.lastName2!.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastName2",comment:""))
        self.lastName2!.typeField = TypeField.string
        self.lastName2!.minLength = 2
        self.lastName2!.maxLength = 25
        self.lastName2!.nameField = NSLocalizedString("profile.address.person.lastName2",comment:"")
        
        self.rfc = FormFieldView()
        self.rfc!.isRequired = true
        self.rfc!.setCustomPlaceholder(NSLocalizedString("profile.address.rfc",comment:""))
        self.rfc!.typeField = TypeField.rfc
        self.rfc!.minLength = 10
        self.rfc!.maxLength = 13
        self.rfc!.validMessageText = "field.validate.text.invalid.rfc"
        self.rfc!.nameField = NSLocalizedString("profile.address.rfc",comment:"")
        
        self.ieps = FormFieldView()
        self.ieps!.isRequired = false
        self.ieps!.setCustomPlaceholder(NSLocalizedString("profile.address.ieps",comment:""))
        self.ieps!.typeField = TypeField.number
        self.ieps!.minLength = 14
        self.ieps!.maxLength = 14
        self.ieps!.keyboardType = UIKeyboardType.numberPad
        self.ieps!.inputAccessoryView = self.keyboardBar
        self.ieps!.nameField = NSLocalizedString("profile.address.ieps",comment:"")
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.address.email",comment:""))
        self.email!.typeField = TypeField.email
        self.email!.nameField = NSLocalizedString("profile.address.email",comment:"")
        self.email!.maxLength = 45
        
        self.addSubview(name!)
        self.addSubview(lastName!)
        self.addSubview(lastName2!)
        self.addSubview(rfc!)
        self.addSubview(ieps!)
        self.addSubview(email!)
        self.addSubview(telephone!)

        self.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.name?.frame = CGRect(x: leftRightPadding,  y: 0, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.lastName?.frame = CGRect(x: leftRightPadding,  y: name!.frame.maxY + 8, width: (self.name!.frame.width / 2) - 5 , height: fieldHeight)
        self.lastName2?.frame = CGRect(x: self.lastName!.frame.maxX + 10 , y: self.lastName!.frame.minY,   width: self.lastName!.frame.width  , height: fieldHeight)
        self.rfc?.frame = CGRect(x: leftRightPadding,  y: lastName2!.frame.maxY + 8, width: self.lastName!.frame.width , height: fieldHeight)
        self.ieps?.frame = CGRect(x: self.rfc!.frame.maxX + 10 , y: self.rfc!.frame.minY,   width: self.rfc!.frame.width  , height: fieldHeight)
        self.email?.frame = CGRect(x: leftRightPadding, y: self.ieps!.frame.maxY + 8, width: self.name!.frame.width , height: fieldHeight)
        self.telephone?.frame = CGRect(x: leftRightPadding,  y: email!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.viewAddress.frame = CGRect(x: 0, y: self.telephone!.frame.maxY + 8, width: self.bounds.width, height: showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
    }
    
    override func setItemWithDictionary(_ itemValues: [String:Any]) {
        super.setItemWithDictionary(itemValues)
        if self.item != nil && self.idAddress != nil {
            self.name!.text = self.item!["firstName"] as? String
            self.lastName!.text = self.item!["middleName"] as? String
            self.lastName2!.text = self.item!["lastName2"] as? String
            self.rfc!.text = self.item!["rfc"] as? String
            self.ieps!.text = self.item!["ieps"] as? String
            self.email!.text = self.item!["email"] as? String
            self.telephone!.text = self.item!["mobileNumber"] as? String
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
            let toValidate : NSString = telephone!.text!.trimmingCharacters(in: CharacterSet.whitespaces) as NSString
            if toValidate.length > 2 {
                if toValidate == "0000000000" || toValidate.substring(to: 2) == "00" {
                    error = self.viewError(telephone!, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                }
            }
        }
        if error{
            return false
        }
        return super.validateAddress()
    }
    
    override func getParams() -> [String:Any]{
         let paramsAdd : NSMutableDictionary? = [:]
        paramsAdd!.addEntries(from: super.getParams() as! [String:Any])
        //let paramsAddress =  super.getParams()
        paramsAdd?.addEntries(from: ["RFC":self.rfc!.text!,"email":self.email!.text!,"IEPS":self.ieps!.text!,"mobileNumber":self.telephone!.text!])
        paramsAdd?.addEntries(from: ["lastName2":self.lastName2!.text! ,"firstName":self.name!.text! ,"lastName":self.lastName!.text!,"persona":"F" ])
      //  let userParams = ["profile":["lastName2":self.lastName2!.text! ,"name":self.name!.text! ,"lastName":self.lastName!.text! ]]
//        paramsAddress.updateValue(userParams as AnyObject, forKey: "user")
        return paramsAdd!
    }
    
}
