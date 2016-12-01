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
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView(frame: self.frame)
        self.scrollForm.delegate = self
        self.scrollForm.scrollDelegate = self
        self.scrollForm.backgroundColor = UIColor.white
        self.addSubview(self.scrollForm)
        //Address Super
        self.titleForm = UILabel()
        self.titleForm!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleForm!.text =  "Tipo de Tránsito"
        self.titleForm!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleForm!)
        
        self.arrivalButton = UIButton()
        arrivalButton!.setImage(checkTermEmpty, for: UIControlState())
        arrivalButton!.setImage(checkTermFull, for: UIControlState.selected)
        arrivalButton!.addTarget(self, action: #selector(TouristInformationForm.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        arrivalButton!.setTitle("Arribo", for: UIControlState())
        arrivalButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        arrivalButton!.titleLabel?.textAlignment = .left
        arrivalButton!.setTitleColor(WMColor.gray, for: UIControlState())
        arrivalButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        arrivalButton!.isSelected = true
        self.scrollForm.addSubview(self.arrivalButton!)
        
        self.departureButton = UIButton()
        departureButton!.setImage(checkTermEmpty, for: UIControlState())
        departureButton!.setImage(checkTermFull, for: UIControlState.selected)
        departureButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        departureButton!.addTarget(self, action: #selector(TouristInformationForm.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        departureButton!.setTitle("Salida", for: UIControlState())
        departureButton!.titleLabel?.textAlignment = .left
        departureButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        departureButton!.setTitleColor(WMColor.gray, for: UIControlState())
        self.scrollForm.addSubview(self.departureButton!)
        
        self.errorLabel = UILabel()
        self.errorLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.errorLabel!.text =  NSLocalizedString("gr.address.section.errorLabelStore", comment: "")
        self.errorLabel!.textColor = UIColor.red
        self.errorLabel!.numberOfLines = 3
        self.errorLabel!.textAlignment = NSTextAlignment.right
        self.errorLabel!.isHidden = true
        self.scrollForm.addSubview(self.errorLabel!)
        
        self.date = FormFieldView()
        self.date!.isRequired = true
        self.date!.setCustomPlaceholder("Fecha")
        self.date!.typeField = TypeField.alphanumeric
        self.date!.nameField = "Fecha"
        self.date!.minLength = 3
        self.date!.maxLength = 25
        self.scrollForm.addSubview(self.date!)
        
        self.nationality = FormFieldView()
        self.nationality!.isRequired = true
        self.nationality!.setCustomPlaceholder("Nacionalidad")
        self.nationality!.typeField = TypeField.alphanumeric
        self.nationality!.nameField = "Nacionalidad"
        self.nationality!.minLength = 3
        self.nationality!.maxLength = 25
        self.scrollForm.addSubview(self.nationality!)
        
        self.documentType = FormFieldView()
        self.documentType!.isRequired = true
        self.documentType!.setCustomPlaceholder("Tipo de documento")
        self.documentType!.typeField = TypeField.alphanumeric
        self.documentType!.nameField = "Tipo de documento"
        self.documentType!.minLength = 3
        self.documentType!.maxLength = 25
        self.scrollForm.addSubview(self.documentType!)
        
        self.documentNumber = FormFieldView()
        self.documentNumber!.isRequired = true
        self.documentNumber!.setCustomPlaceholder("Número de documento")
        self.documentNumber!.typeField = TypeField.alphanumeric
        self.documentNumber!.nameField = "Número de documento"
        self.documentNumber!.minLength = 3
        self.documentNumber!.maxLength = 25
        self.scrollForm.addSubview(self.documentNumber!)
        
        self.transportWay = FormFieldView()
        self.transportWay!.isRequired = true
        self.transportWay!.setCustomPlaceholder("Via")
        self.transportWay!.typeField = TypeField.list
        self.transportWay!.nameField = "Via"
        self.transportWay!.minLength = 3
        self.transportWay!.maxLength = 25
        self.scrollForm.addSubview(self.transportWay!)
        
        self.transportCompany = FormFieldView()
        self.transportCompany!.isRequired = true
        self.transportCompany!.setCustomPlaceholder("Empresa transporte")
        self.transportCompany!.typeField = TypeField.alphanumeric
        self.transportCompany!.nameField = "Empresa transporte"
        self.transportCompany!.minLength = 3
        self.transportCompany!.maxLength = 25
        self.scrollForm.addSubview(self.transportCompany!)

        self.transportId = FormFieldView()
        self.transportId!.isRequired = true
        self.transportId!.setCustomPlaceholder("Id transporte")
        self.transportId!.typeField = TypeField.alphanumeric
        self.transportId!.nameField = "Id transporte"
        self.transportId!.minLength = 3
        self.transportId!.maxLength = 25
        self.scrollForm.addSubview(self.transportId!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.light_blue
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: Selector("back"), for: UIControlEvents.touchUpInside)
        self.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(FMResultSet.next), for: UIControlEvents.touchUpInside)
        self.addSubview(saveButton!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthLessMargin = self.frame.width - leftRightPadding
        let rightPadding = leftRightPadding * 2
        self.scrollForm.frame = CGRect(x: 0, y: 0, width: self.frame.width , height: self.frame.height - 66)
        self.errorLabel.frame = CGRect(x: (self.frame.width - leftRightPadding) - errorLabelWidth , y: 0, width: errorLabelWidth , height: fieldHeight)
        self.titleForm.frame = CGRect(x: leftRightPadding, y: 52, width: self.frame.width - rightPadding , height: fieldHeight)
        self.arrivalButton!.frame = CGRect(x: leftRightPadding, y: self.titleForm!.frame.maxY - 12, width: 65 , height: fieldHeight)
        self.departureButton!.frame = CGRect(x: self.arrivalButton!.frame.maxX + 39, y: self.titleForm!.frame.maxY - 12, width: 65 , height: fieldHeight)
        self.date.frame = CGRect(x: leftRightPadding, y: self.arrivalButton!.frame.maxY + 20, width: self.frame.width - rightPadding , height: fieldHeight)
        self.nationality.frame = CGRect(x: leftRightPadding, y: self.date.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.documentType.frame = CGRect(x: leftRightPadding, y: self.nationality.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.documentNumber.frame = CGRect(x: leftRightPadding, y: self.documentType.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.transportWay.frame = CGRect(x: leftRightPadding, y: self.documentNumber.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.transportWay!.setImageTypeField()
        self.transportCompany.frame = CGRect(x: leftRightPadding, y: self.transportWay.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.transportId.frame = CGRect(x: leftRightPadding, y: self.transportCompany.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.scrollForm.contentSize = CGSize(width: self.frame.width,height: self.transportId.frame.maxY + 20)
        self.layerLine.frame = CGRect(x: 0, y: self.scrollForm!.frame.maxY,  width: self.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: leftRightPadding, y: self.scrollForm!.frame.maxY + 15.0, width: 125, height: 34)
        self.saveButton!.frame = CGRect(x: widthLessMargin - 125 , y: self.scrollForm!.frame.maxY + 15.0, width: 125, height: 34)
        
    }
    
    func checkSelected(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == arrivalButton!{
            departureButton!.isSelected = false
        }else{
            arrivalButton!.isSelected = false
        }
        sender.isSelected = !(sender.isSelected)
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        let val = CGSize(width: self.frame.width, height: self.scrollForm.contentSize.height)
        return val
    }
    
}
