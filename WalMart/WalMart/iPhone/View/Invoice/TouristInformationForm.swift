//
//  TouristInformationForm.swift
//  WalMart
//
//  Created by Alonso Salcido on 04/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class TouristInformationForm: UIView,TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate {
    var titleForm : UILabel!
    var errorLabel: UILabel!
    
    var date : FormFieldView!
    var nationality : FormFieldView!
    var documentType : FormFieldView!
    var documentNumber : FormFieldView!
    var transportWay : FormFieldView!
    var transportCompany : FormFieldView!
    var transportId : FormFieldView!
    
    var scrollForm: TPKeyboardAvoidingScrollView!
    
    var invoiceSelect: UIButton?
    var consultSelect: UIButton?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var arrivalButton: UIButton?
    var departureButton: UIButton?
    var layerLine: CALayer!
    
    let leftRightPadding  : CGFloat = CGFloat(16)
    let errorLabelWidth  : CGFloat = CGFloat(150)
    let fieldHeight  : CGFloat = CGFloat(40)
    let separatorField  : CGFloat = CGFloat(8)
    let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
    let checkTermFull : UIImage = UIImage(named:"check_full")!
    
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
        layerLine.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6, alpha: 1.0).CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView(frame: self.frame)
        self.scrollForm.delegate = self
        self.scrollForm.scrollDelegate = self
        self.scrollForm.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.scrollForm)
        //Address Super
        self.titleForm = UILabel()
        self.titleForm!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleForm!.text =  "Tipo de Tránsito"
        self.titleForm!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleForm!)
        
        self.arrivalButton = UIButton()
        arrivalButton!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        arrivalButton!.setImage(checkTermFull, forState: UIControlState.Selected)
        arrivalButton!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        arrivalButton!.setTitle("Arribo", forState: UIControlState.Normal)
        arrivalButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        arrivalButton!.titleLabel?.textAlignment = .Left
        arrivalButton!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        arrivalButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        arrivalButton!.selected = true
        self.scrollForm.addSubview(self.arrivalButton!)
        
        self.departureButton = UIButton()
        departureButton!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        departureButton!.setImage(checkTermFull, forState: UIControlState.Selected)
        departureButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        departureButton!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        departureButton!.setTitle("Salida", forState: UIControlState.Normal)
        departureButton!.titleLabel?.textAlignment = .Left
        departureButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        departureButton!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        self.scrollForm.addSubview(self.departureButton!)
        
        self.errorLabel = UILabel()
        self.errorLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.errorLabel!.text =  NSLocalizedString("gr.address.section.errorLabelStore", comment: "")
        self.errorLabel!.textColor = UIColor.redColor()
        self.errorLabel!.numberOfLines = 3
        self.errorLabel!.textAlignment = NSTextAlignment.Right
        self.errorLabel!.hidden = true
        self.scrollForm.addSubview(self.errorLabel!)
        
        self.date = FormFieldView()
        self.date!.isRequired = true
        self.date!.setCustomPlaceholder("Fecha")
        self.date!.typeField = TypeField.Alphanumeric
        self.date!.nameField = "Fecha"
        self.date!.minLength = 3
        self.date!.maxLength = 25
        self.scrollForm.addSubview(self.date!)
        
        self.nationality = FormFieldView()
        self.nationality!.isRequired = true
        self.nationality!.setCustomPlaceholder("Nacionalidad")
        self.nationality!.typeField = TypeField.Alphanumeric
        self.nationality!.nameField = "Nacionalidad"
        self.nationality!.minLength = 3
        self.nationality!.maxLength = 25
        self.scrollForm.addSubview(self.nationality!)
        
        self.documentType = FormFieldView()
        self.documentType!.isRequired = true
        self.documentType!.setCustomPlaceholder("Tipo de documento")
        self.documentType!.typeField = TypeField.Alphanumeric
        self.documentType!.nameField = "Tipo de documento"
        self.documentType!.minLength = 3
        self.documentType!.maxLength = 25
        self.scrollForm.addSubview(self.documentType!)
        
        self.documentNumber = FormFieldView()
        self.documentNumber!.isRequired = true
        self.documentNumber!.setCustomPlaceholder("Número de documento")
        self.documentNumber!.typeField = TypeField.Alphanumeric
        self.documentNumber!.nameField = "Número de documento"
        self.documentNumber!.minLength = 3
        self.documentNumber!.maxLength = 25
        self.scrollForm.addSubview(self.documentNumber!)
        
        self.transportWay = FormFieldView()
        self.transportWay!.isRequired = true
        self.transportWay!.setCustomPlaceholder("Via")
        self.transportWay!.typeField = TypeField.List
        self.transportWay!.nameField = "Via"
        self.transportWay!.minLength = 3
        self.transportWay!.maxLength = 25
        self.scrollForm.addSubview(self.transportWay!)
        
        self.transportCompany = FormFieldView()
        self.transportCompany!.isRequired = true
        self.transportCompany!.setCustomPlaceholder("Empresa transporte")
        self.transportCompany!.typeField = TypeField.Alphanumeric
        self.transportCompany!.nameField = "Empresa transporte"
        self.transportCompany!.minLength = 3
        self.transportCompany!.maxLength = 25
        self.scrollForm.addSubview(self.transportCompany!)

        self.transportId = FormFieldView()
        self.transportId!.isRequired = true
        self.transportId!.setCustomPlaceholder("Id transporte")
        self.transportId!.typeField = TypeField.Alphanumeric
        self.transportId!.nameField = "Id transporte"
        self.transportId!.minLength = 3
        self.transportId!.maxLength = 25
        self.scrollForm.addSubview(self.transportId!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.listAddressHeaderSectionColor
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancelButton!)
        
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
        let widthLessMargin = self.frame.width - leftRightPadding
        let rightPadding = leftRightPadding * 2
        self.scrollForm.frame = CGRectMake(0, 0, self.frame.width , self.frame.height - 66)
        self.errorLabel.frame = CGRectMake((self.frame.width - leftRightPadding) - errorLabelWidth , 0, errorLabelWidth , fieldHeight)
        self.titleForm.frame = CGRectMake(leftRightPadding, 52, self.frame.width - rightPadding , fieldHeight)
        self.arrivalButton!.frame = CGRectMake(leftRightPadding, self.titleForm!.frame.maxY - 12, 65 , fieldHeight)
        self.departureButton!.frame = CGRectMake(self.arrivalButton!.frame.maxX + 39, self.titleForm!.frame.maxY - 12, 65 , fieldHeight)
        self.date.frame = CGRectMake(leftRightPadding, self.arrivalButton!.frame.maxY + 20, self.frame.width - rightPadding , fieldHeight)
        self.nationality.frame = CGRectMake(leftRightPadding, self.date.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.documentType.frame = CGRectMake(leftRightPadding, self.nationality.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.documentNumber.frame = CGRectMake(leftRightPadding, self.documentType.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.transportWay.frame = CGRectMake(leftRightPadding, self.documentNumber.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.transportWay!.setImageTypeField()
        self.transportCompany.frame = CGRectMake(leftRightPadding, self.transportWay.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.transportId.frame = CGRectMake(leftRightPadding, self.transportCompany.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.scrollForm.contentSize = CGSize(width: self.frame.width,height: self.transportId.frame.maxY + 20)
        self.layerLine.frame = CGRectMake(0, self.scrollForm!.frame.maxY,  self.frame.width, 1)
        self.cancelButton!.frame = CGRectMake(leftRightPadding, self.scrollForm!.frame.maxY + 15.0, 125, 34)
        self.saveButton!.frame = CGRectMake(widthLessMargin - 125 , self.scrollForm!.frame.maxY + 15.0, 125, 34)
        
    }
    
    func checkSelected(sender:UIButton) {
        if sender.selected{
            return
        }
        if sender == arrivalButton!{
            departureButton!.selected = false
        }else{
            arrivalButton!.selected = false
        }
        sender.selected = !(sender.selected)
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        let val = CGSizeMake(self.frame.width, self.scrollForm.contentSize.height)
        return val
    }
    
}
