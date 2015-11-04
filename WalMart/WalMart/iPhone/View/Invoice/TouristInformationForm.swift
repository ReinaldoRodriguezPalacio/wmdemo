//
//  TouristInformationForm.swift
//  WalMart
//
//  Created by Alonso Salcido on 04/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class TouristInformationForm: UIView {
    var titleForm : UILabel!
    var errorLabel: UILabel!
    
    var date : FormFieldView!
    var nationality : FormFieldView!
    var documentType : FormFieldView!
    var documentNumber : FormFieldView!
    var transportWay : FormFieldView!
    var transportCompany : FormFieldView!
    var transportId : FormFieldView!
    
    var invoiceSelect: UIButton?
    var consultSelect: UIButton?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        var width = self.frame.width
        if IS_IPAD {
            width = 1024.0
        }
        
        //Address Super
        self.titleForm = UILabel()
        self.titleForm!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleForm!.text =  "Tipo de Tránsito"
        self.titleForm!.textColor = WMColor.listAddressHeaderSectionColor
        
        self.errorLabel = UILabel()
        self.errorLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.errorLabel!.text =  NSLocalizedString("gr.address.section.errorLabelStore", comment: "")
        self.errorLabel!.textColor = UIColor.redColor()
        self.errorLabel!.numberOfLines = 3
        self.errorLabel!.textAlignment = NSTextAlignment.Right
        self.errorLabel!.hidden = true
        
        self.date = FormFieldView()
        self.date!.isRequired = true
        self.date!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.date!.typeField = TypeField.Alphanumeric
        self.date!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.date!.minLength = 3
        self.date!.maxLength = 25
        
        self.nationality = FormFieldView()
        self.nationality!.isRequired = true
        self.nationality!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.nationality!.typeField = TypeField.Alphanumeric
        self.nationality!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.nationality!.minLength = 3
        self.nationality!.maxLength = 25
        
        self.documentType = FormFieldView()
        self.documentType!.isRequired = true
        self.documentType!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.documentType!.typeField = TypeField.Alphanumeric
        self.documentType!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.documentType!.minLength = 3
        self.documentType!.maxLength = 25
        
        self.documentNumber = FormFieldView()
        self.documentNumber!.isRequired = true
        self.documentNumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.documentNumber!.typeField = TypeField.Alphanumeric
        self.documentNumber!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.documentNumber!.minLength = 3
        self.documentNumber!.maxLength = 25
        
        self.transportWay = FormFieldView()
        self.transportWay!.isRequired = true
        self.transportWay!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.transportWay!.typeField = TypeField.Alphanumeric
        self.transportWay!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.transportWay!.minLength = 3
        self.transportWay!.maxLength = 25
        
        self.transportCompany = FormFieldView()
        self.transportCompany!.isRequired = true
        self.transportCompany!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.transportCompany!.typeField = TypeField.Alphanumeric
        self.transportCompany!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.transportCompany!.minLength = 3
        self.transportCompany!.maxLength = 25

        self.transportId = FormFieldView()
        self.transportId!.isRequired = true
        self.transportId!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.transportId!.typeField = TypeField.Alphanumeric
        self.transportId!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.transportId!.minLength = 3
        self.transportId!.maxLength = 25

        
        
    }
    
    
}
