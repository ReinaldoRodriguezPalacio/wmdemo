//
//  ReferedForm.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol ReferedFormDelegate {
    func selectSaveButton(name: String, mail: String)
}

class ReferedForm: UIView{
    
    var titleSection : UILabel!
    var errorView: FormFieldErrorView!
    var confirmLabel: UILabel!
    var name : FormFieldView!
    var email : FormFieldView!
    var saveButton: UIButton?
    var delegate: ReferedFormDelegate?
    var layerLine: CALayer!
    let leftRightPadding  : CGFloat = CGFloat(16)
    let errorLabelWidth  : CGFloat = CGFloat(150)
    let fieldHeight  : CGFloat = CGFloat(40)
    let separatorField  : CGFloat = CGFloat(12)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.lineSaparatorColor.CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
        
        self.titleSection = UILabel()
        self.titleSection!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleSection!.text =  "Datos de mi referido"
        self.titleSection!.textColor = WMColor.listAddressHeaderSectionColor
        self.titleSection!.textAlignment = .Left
        self.addSubview(self.titleSection!)
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder("Nombre")
        self.name!.typeField = TypeField.Name
        self.name!.nameField = "Name"
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.addSubview(self.name!)
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.typeField = TypeField.Email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.maxLength = 45
        self.email!.autocapitalizationType = UITextAutocapitalizationType.None
        self.addSubview(self.email!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Enviar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.loginSignInButonBgColor
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(saveButton!)
        
        self.confirmLabel = UILabel()
        self.confirmLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.confirmLabel!.text =  "Confirmado"
        self.confirmLabel!.textColor = WMColor.UIColorFromRGB(0x5f5f5f)
        self.confirmLabel!.textAlignment = .Center
        self.confirmLabel!.hidden = true
        self.addSubview(self.confirmLabel!)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleSection.frame = CGRectMake(leftRightPadding,58,self.frame.width - leftRightPadding,16)
        self.name.frame = CGRectMake(leftRightPadding,titleSection.frame.maxY + separatorField,self.frame.width - (leftRightPadding * 2),fieldHeight)
        self.email.frame = CGRectMake(leftRightPadding,name.frame.maxY + separatorField,self.frame.width - (leftRightPadding * 2),fieldHeight)
        self.layerLine.frame = CGRectMake(0,email.frame.maxY + separatorField,self.frame.width,1)
        self.saveButton!.frame = CGRectMake((self.frame.width - 98) / 2,layerLine.frame.maxY + 12,98,34)
        self.confirmLabel!.frame = CGRectMake((self.frame.width - 98) / 2,layerLine.frame.maxY + 12,98,34)
    }
    
    func validate() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(email!)
        }
        if error{
            return false
        }
        return true
    }
    
    func viewError(field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil  {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!, becomeFirstResponder: true)
            return true
        }
        return false
    }

    
    func save(){
        if self.validate(){
            delegate?.selectSaveButton(name.text!, mail: email.text!)
        }
    }
    
    func showReferedUser(name:String,mail:String){
        self.email.text = mail
        self.name.text = name
        self.email.enabled = false
        self.name.enabled = false
        self.saveButton?.hidden = true
        self.confirmLabel?.hidden = false
    }
}