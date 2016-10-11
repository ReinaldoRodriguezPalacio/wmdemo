//
//  FiscalAddressPersonM.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 23/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class FiscalAddressPersonM: AddressView {

    var corporateName : FormFieldView? = nil
    var rfc : FormFieldView? = nil
    
    override init(frame: CGRect, isLogin: Bool, isIpad:Bool, typeAddress: TypeAddress) {
        super.init(frame: frame, isLogin: isLogin, isIpad: isIpad, typeAddress: typeAddress )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(){
        super.setup()
        
        self.corporateName = FormFieldView()
        self.corporateName!.isRequired = true
        self.corporateName!.setCustomPlaceholder(NSLocalizedString("profile.address.person.name.moral",comment:""))
        self.corporateName!.typeField = TypeField.Name
        self.corporateName!.minLength = 2
        self.corporateName!.maxLength = 20
        self.corporateName!.nameField = NSLocalizedString("profile.address.person.name.moral",comment:"")
        
        self.rfc = FormFieldView()
        self.rfc!.isRequired = true
        self.rfc!.setCustomPlaceholder(NSLocalizedString("profile.address.rfc",comment:""))
        self.rfc!.typeField = TypeField.RFCM
        self.rfc!.minLength = 12
        self.rfc!.maxLength = 12
        self.rfc!.nameField = NSLocalizedString("profile.address.rfc",comment:"")
        self.rfc!.validMessageText = "field.validate.text.invalid.rfc"
        
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
        
        self.addSubview(corporateName!)
        self.addSubview(rfc!)
        self.addSubview(ieps!)
        self.addSubview(email!)
        self.addSubview(telephone!)
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.corporateName?.frame = CGRectMake(leftRightPadding,  0, self.bounds.width - (leftRightPadding*2), fieldHeight)
        self.rfc?.frame = CGRectMake(leftRightPadding,  corporateName!.frame.maxY + 8, (self.corporateName!.frame.width / 2) - 5 , fieldHeight)
        self.ieps?.frame = CGRectMake(self.rfc!.frame.maxX + 10 , self.rfc!.frame.minY,   self.outdoornumber!.frame.width  , fieldHeight)
        self.email?.frame = CGRectMake(leftRightPadding, self.ieps!.frame.maxY + 8, self.corporateName!.frame.width , fieldHeight)
         self.telephone?.frame = CGRectMake(leftRightPadding,  email!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.viewAddress.frame = CGRectMake(0, self.telephone!.frame.maxY + 8, self.bounds.width, showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
        
    }
    
    override func setItemWithDictionary(itemValues: NSDictionary) {
        super.setItemWithDictionary(itemValues)
        if self.item != nil && self.idAddress != nil {
            self.corporateName!.text = self.item!["corporateName"] as? String
            self.rfc!.text = self.item!["rfc"] as? String
            self.ieps!.text = self.item!["ieps"] as? String
            self.email!.text = self.item!["rfcEmail"] as? String
            self.telephone!.text = self.item!["phoneNumber"] as? String
        }
    }
 
    override func validateAddress() -> Bool{
        var error = viewError(corporateName!)
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
    
    override func getParams() -> NSDictionary {
        let paramsAddress : NSMutableDictionary? = [:]
        paramsAddress!.addEntriesFromDictionary(super.getParams() as [NSObject : AnyObject])
        paramsAddress!.addEntriesFromDictionary([ "RFC":self.rfc!.text!, "rfcEmail":self.email!.text!,"ieps":self.ieps!.text!,"phoneNumber":self.telephone!.text!, "corporateName":self.corporateName!.text!, "name":"Empresa","persona":"M"])
        
        return paramsAddress!
    }
    
}
