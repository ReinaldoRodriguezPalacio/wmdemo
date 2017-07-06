//
//  InvoiceFiscalAddressPersonF.swift
//  WalMart
//
//  Created by Vantis on 15/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

class InvoiceFiscalAddressPersonF: AddressView {
    
    var name : FormFieldView!
    var rfc : FormFieldView!
    var folioAddress : String! = ""
    var idCliente : String! = ""
    
    override init(frame: CGRect, isLogin: Bool, isIpad:Bool, isFromInvoice: Bool) {
        super.init(frame: frame, isLogin: isLogin, isIpad: isIpad, isFromInvoice: isFromInvoice )
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
        self.name!.maxLength = 40
        self.name!.nameField = NSLocalizedString("profile.address.person.name",comment:"")
        self.name!.tag=100
        
        self.rfc = FormFieldView()
        self.rfc!.isRequired = true
        self.rfc!.setCustomPlaceholder(NSLocalizedString("profile.address.rfc",comment:""))
        self.rfc!.typeField = TypeField.rfc
        self.rfc!.minLength = 13
        self.rfc!.maxLength = 13
        self.rfc!.validMessageText = "field.validate.text.invalid.rfc"
        self.rfc!.nameField = NSLocalizedString("profile.address.rfc",comment:"")
        self.rfc!.isEnabled = false
        self.rfc!.tag=101
        
        
        self.ieps = FormFieldView()
        self.ieps!.isRequired = false
        self.ieps!.setCustomPlaceholder(NSLocalizedString("profile.address.ieps",comment:""))
        self.ieps!.typeField = TypeField.number
        self.ieps!.minLength = 14
        self.ieps!.maxLength = 14
        self.ieps!.keyboardType = UIKeyboardType.numberPad
        self.ieps!.inputAccessoryView = self.keyboardBar
        self.ieps!.nameField = NSLocalizedString("profile.address.ieps",comment:"")
        self.ieps!.tag=102
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.address.email",comment:""))
        self.email!.typeField = TypeField.email
        self.email!.nameField = NSLocalizedString("profile.address.email",comment:"")
        self.email!.maxLength = 45
        self.email!.tag=103
        
        self.addSubview(name!)
        self.addSubview(rfc!)
        self.addSubview(ieps!)
        self.addSubview(email!)
        
        self.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.name?.frame = CGRect(x: leftRightPadding,  y: 0, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.rfc?.frame = CGRect(x: leftRightPadding,  y: name!.frame.maxY + 8, width: (self.name!.frame.width / 2) - 5 , height: fieldHeight)
        self.ieps?.frame = CGRect(x: self.rfc!.frame.maxX + 10 , y: self.rfc!.frame.minY,   width: self.rfc!.frame.width  , height: fieldHeight)
        self.email?.frame = CGRect(x: leftRightPadding, y: self.ieps!.frame.maxY + 8, width: self.name!.frame.width , height: fieldHeight)
        self.viewAddress.frame = CGRect(x: 0,  y: email!.frame.maxY + 8, width: self.name!.frame.width, height: showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
        
        
    }
    
    override func setItemWithDictionary(_ itemValues: [String:Any]) {
        super.setItemWithDictionary(itemValues)
        if self.item != nil && self.idAddress != nil {
            self.name!.text = self.item!["nombre"] as? String
            self.rfc!.text = self.item!["rfc"] as? String
            self.ieps!.text = self.item!["rfcIeps"] as? String
            self.email!.text = self.item!["correoElectronico"] as? String
        }
    }
    
    
    override func validateAddress() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(rfc!)
        }
        if !error{
            error = viewError(ieps!)
        }
        if !error{
            error = viewError(email!)
        }
        if error{
            return false
        }
        return super.validateFiscalAddress()
    }
    
    override func getParams() -> [String:Any]{
        var paramsAddress : [String:Any] = ["nombre":self.name!.text! ,"rfc":self.rfc!.text!]
        
        var domicilioData =   super.getParams()
        //let userParams = ["cliente":["nombre":self.name!.text! ,"rfc":self.rfc!.text!]]
        //paramsAddress.updateValue(userParams as AnyObject, forKey: "user")
        paramsAddress.updateValue(self.email!.text!, forKey: "correoElectronico")
        paramsAddress.updateValue(self.ieps!.text!, forKey: "rfcIeps")
        paramsAddress.updateValue(domicilioData, forKey: "domicilio")
        return paramsAddress
    }
    
}

