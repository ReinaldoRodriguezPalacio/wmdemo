//
//  ReferedForm.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedForm: UIView{
    
    var titleSection : UILabel!
    var errorLabel: UILabel!
    var name : FormFieldView!
    var mail : FormFieldView!
    var saveButton: UIButton?
    var layerLine: CALayer!
    let leftRightPadding  : CGFloat = CGFloat(16)
    let errorLabelWidth  : CGFloat = CGFloat(150)
    let fieldHeight  : CGFloat = CGFloat(14)
    let separatorField  : CGFloat = CGFloat(20)
    
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
        self.titleSection!.text =  "Tipo de Tránsito"
        self.titleSection!.textColor = WMColor.listAddressHeaderSectionColor
        self.addSubview(self.titleSection!)
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder("Nombre")
        self.name!.typeField = TypeField.Alphanumeric
        self.name!.nameField = "Name"
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.addSubview(self.name!)
        
        self.mail = FormFieldView()
        self.mail!.isRequired = true
        self.mail!.setCustomPlaceholder("Correo")
        self.mail!.typeField = TypeField.Alphanumeric
        self.mail!.nameField = "Correo"
        self.mail!.minLength = 3
        self.mail!.maxLength = 25
        self.addSubview(self.mail!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.loginSignInButonBgColor
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(saveButton!)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}