//
//  AddressView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 23/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

@objc protocol AddressViewDelegate: class {
    func textModify(_ textField: UITextField!)
    func setContentSize()
    @objc optional func validateZip(_ isvalidate:Bool)
}

class AddressView: UIView , UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    
    var item: [String:Any]? = nil
    var idAddress : String? = nil
    var idSuburb : String? = nil
    var shortNameField : FormFieldView? = nil
    var street : FormFieldView? = nil
    var outdoornumber : FormFieldView? = nil
    var indoornumber : FormFieldView? = nil
    var zipcode : FormFieldView? = nil
    var suburb : FormFieldView? = nil
    var municipality : FormFieldView? = nil
    var city : FormFieldView? = nil
    var state : FormFieldView? = nil
    var errorView : FormFieldErrorView? = nil
    var telephone : FormFieldView? = nil
    var ieps : FormFieldView!
    var email : FormFieldView!
    var allAddress: [Any]!
    var preferedLabel : UILabel? = nil
    var defaultPrefered : Bool = false
    
    var viewAddress: UIView!
    var fieldHeight  : CGFloat = CGFloat(40)
    var leftRightPadding  : CGFloat = CGFloat(15)
    var pickerSuburb : UIPickerView? = nil
    var listSuburb : [[String:Any]] = []
    var titleLabel: UILabel!
    
    var isFromInvoice: Bool! = false
    var viewLoad : WMLoadingView!
    weak var delegate:AddressViewDelegate?
    var showSuburb : Bool! = false
    var isLogin : Bool! = false
    var isIpad : Bool! = false
    
    var telipad:String = "";
    
    var alertView : IPOWMAlertViewController? = nil
    var keyboardBar: FieldInputView? {
        didSet {
        }
    }
    
    init(frame: CGRect, isLogin: Bool, isIpad: Bool) {
        super.init(frame: frame)
        self.isLogin! = isLogin
        self.isIpad! = isIpad
        self.setup()
    }
    
    init(frame: CGRect, isLogin: Bool, isIpad: Bool, isFromInvoice: Bool) {
        super.init(frame: frame)
        self.isLogin! = isLogin
        self.isIpad! = isIpad
        self.isFromInvoice = isFromInvoice
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        viewAddress = UIView()
        var width = self.bounds.width
        
        if IS_IPAD {
            width = 1024.0
        }
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: width , height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                if field == self.zipcode!{
                    if !self.isFromInvoice{
                        self.callServiceZip(field!.text!, showError: true)
                    }else{
                        self.callServiceFiscalZip(field!.text!, showError: true)
                    }
                }else if field == self.suburb{
                    field!.resignFirstResponder()
                }else if field == self.ieps {
                    let _ = self.email!.becomeFirstResponder()
                }else {
                    let _ = self.shortNameField!.becomeFirstResponder()
                }
                
            }
            self.delegate?.textModify(field)
        })
        
        self.keyboardBar = viewAccess
        shortNameField = FormFieldView()
        if isFromInvoice{
            self.shortNameField!.typeField = TypeField.none
            self.shortNameField!.minLength = 3
            self.shortNameField!.maxLength = 50
            self.shortNameField!.isRequired = false
            self.shortNameField!.nameField = NSLocalizedString("profile.address.shortName",comment:"")
            self.shortNameField!.setCustomPlaceholder(NSLocalizedString("invoice.field.referencia",comment:""))
        }else{
            self.shortNameField!.typeField = TypeField.alphanumeric
            self.shortNameField!.minLength = 3
            self.shortNameField!.maxLength = 25
            self.shortNameField!.isRequired = true
            self.shortNameField!.nameField = NSLocalizedString("profile.address.shortName",comment:"")
            shortNameField!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname.description",comment:""))
        }
        
        
        street = FormFieldView()
        self.street!.isRequired = true
        street!.setCustomPlaceholder(NSLocalizedString("profile.address.street",comment:""))
        self.street!.typeField = TypeField.alphanumeric
        self.street!.minLength = 2
        self.street!.maxLength = 50
        self.street!.nameField = NSLocalizedString("profile.address.street",comment:"")
        
        outdoornumber = FormFieldView()
        self.outdoornumber!.isRequired = true
        outdoornumber!.setCustomPlaceholder(NSLocalizedString("profile.address.outdoornumber",comment:""))
        self.outdoornumber!.typeField = TypeField.numAddress
        self.outdoornumber!.minLength = 0
        self.outdoornumber!.maxLength = 15
        self.outdoornumber!.nameField = NSLocalizedString("profile.address.outdoornumber",comment:"")
        
        indoornumber = FormFieldView()
        self.indoornumber!.isRequired = false
        indoornumber!.setCustomPlaceholder(NSLocalizedString("profile.address.indoornumber",comment:""))
        self.indoornumber!.typeField = TypeField.innerNumber
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 50
        self.indoornumber!.delegate = self
        self.indoornumber!.nameField = NSLocalizedString("profile.address.indoornumber",comment:"")
        
        self.zipcode = FormFieldView()
        self.zipcode!.isRequired = true
        self.zipcode!.setCustomPlaceholder(NSLocalizedString("profile.address.zipcode",comment:""))
        self.zipcode!.typeField = TypeField.number
        self.zipcode!.minLength = 5
        self.zipcode!.maxLength = 5
        self.zipcode!.nameField = NSLocalizedString("profile.address.zipcode",comment:"")
        self.zipcode!.delegate = self
        self.zipcode!.keyboardType = UIKeyboardType.numberPad
        self.zipcode!.inputAccessoryView = self.keyboardBar
        
        suburb = FormFieldView()
        self.suburb!.isRequired = true
        suburb!.setCustomPlaceholder(NSLocalizedString("profile.address.suburb",comment:""))
        self.suburb!.typeField = TypeField.list
        self.suburb!.nameField = NSLocalizedString("profile.address.suburb",comment:"")
        suburb!.delegate = self
        self.suburb!.inputAccessoryView = self.keyboardBar
        self.suburb!.isHidden = true
        
        municipality = FormFieldView()
        self.municipality!.isRequired = true
        municipality!.setCustomPlaceholder(NSLocalizedString("profile.address.municipality",comment:""))
        self.municipality!.typeField = TypeField.none
        self.municipality!.nameField = NSLocalizedString("profile.address.municipality",comment:"")
        self.municipality!.isEnabled = false
        self.municipality!.isHidden = true
        
        city = FormFieldView()
        self.city!.isRequired = true
        city!.setCustomPlaceholder(NSLocalizedString("profile.address.city",comment:""))
        self.city!.typeField = TypeField.none
        self.city!.nameField = NSLocalizedString("profile.address.city",comment:"")
        self.city!.isEnabled = false
        self.city!.isHidden = true
        
        state = FormFieldView()
        self.state!.isRequired = true
        state!.setCustomPlaceholder(NSLocalizedString("profile.address.state",comment:""))
        self.state!.typeField = TypeField.none
        self.state!.nameField = NSLocalizedString("profile.address.state",comment:"")
        self.state!.isEnabled = false
        self.state!.isHidden = true
        
        preferedLabel = UILabel()
        
        self.titleLabel = UILabel()
        
        self.titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabel!.text =  NSLocalizedString("profile.address", comment: "")
        if !isLogin {
            self.titleLabel!.textColor = WMColor.light_blue
            self.titleLabel!.backgroundColor = UIColor.white
            self.backgroundColor = UIColor.white
        }else {
            self.backgroundColor = UIColor.clear
            self.titleLabel.backgroundColor = UIColor.clear
            self.titleLabel.textColor = UIColor.white
        }
        
        self.addSubview(viewAddress!)
        
        self.preferedLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.preferedLabel!.textColor = WMColor.gray
        self.preferedLabel!.textAlignment = .right
        
        self.telephone = FormFieldView()
        self.telephone!.isRequired = true
        self.telephone!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone",comment:""))
        self.telephone!.typeField = TypeField.number
        self.telephone!.nameField = NSLocalizedString("profile.address.telephone",comment:"")
        self.telephone!.minLength = 10
        self.telephone!.maxLength = 10
        self.telephone!.disablePaste = true
        self.telephone!.keyboardType = UIKeyboardType.numberPad
        self.telephone!.delegate = self
        self.telephone!.inputAccessoryView = self.keyboardBar
        
        self.viewAddress!.addSubview(titleLabel!)
        self.viewAddress!.addSubview(preferedLabel!)
        
        self.viewAddress!.addSubview(shortNameField!)
        
        self.viewAddress!.addSubview(street!)
        self.viewAddress!.addSubview(outdoornumber!)
        self.viewAddress!.addSubview(indoornumber!)
        self.viewAddress!.addSubview(zipcode!)
        self.viewAddress!.addSubview(suburb!)
        self.viewAddress!.addSubview(municipality!)
        self.viewAddress!.addSubview(city!)
        self.viewAddress!.addSubview(state!)
        //self.viewAddress!.addSubview(lineView!)
        
        pickerSuburb = UIPickerView(frame: CGRect.zero)
        pickerSuburb!.delegate = self
        pickerSuburb!.dataSource = self
        pickerSuburb!.showsSelectionIndicator = true
        suburb!.inputView = pickerSuburb!
        
        self.viewAddress!.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        
        self.preferedLabel?.frame = CGRect(x: self.bounds.width - 80 ,  y: 0, width: 80 - leftRightPadding , height: fieldHeight)
        self.titleLabel?.frame = CGRect(x: leftRightPadding,  y: 0, width: self.bounds.width - (leftRightPadding*2) - 60 , height: fieldHeight)
        if isFromInvoice{
            self.street?.frame = CGRect(x: leftRightPadding, y: self.titleLabel!.frame.maxY, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        }else{
            self.shortNameField?.frame = CGRect(x: leftRightPadding,  y: self.titleLabel!.frame.maxY, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
            self.street?.frame = CGRect(x: leftRightPadding, y: self.shortNameField!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        }
        
        self.outdoornumber?.frame = CGRect(x: leftRightPadding,  y: street!.frame.maxY + 8, width: (self.street!.frame.width / 2) - 5 , height: fieldHeight)
        self.indoornumber?.frame = CGRect(x: self.outdoornumber!.frame.maxX + 10 , y: self.outdoornumber!.frame.minY,   width: self.outdoornumber!.frame.width  , height: fieldHeight)
        if isFromInvoice{
            self.shortNameField?.frame = CGRect(x: leftRightPadding,  y: outdoornumber!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
            self.zipcode?.frame = CGRect(x: leftRightPadding,  y: shortNameField!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
        }else{
            self.zipcode?.frame = CGRect(x: leftRightPadding,  y: outdoornumber!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
        }
        self.suburb?.frame = CGRect(x: leftRightPadding,  y: zipcode!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
        self.suburb!.setImageTypeField()
        self.municipality?.frame = CGRect(x: leftRightPadding,  y: suburb!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
        self.city?.frame = CGRect(x: leftRightPadding,  y: municipality!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
        self.state?.frame = CGRect(x: leftRightPadding,  y: city!.frame.maxY + 8, width: self.street!.frame.width, height: fieldHeight)
        
        self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width, height: showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
        
    }
    
    func setItemWithDictionary(_ itemValues: [String:Any]) {
        self.item = itemValues
        if self.item != nil{
            if let id = self.item!["addressID"] as! String?{
                idAddress = id
                self.shortNameField!.text  = self.item!["name"] as? String
                self.street!.text = self.item!["street"] as? String
                self.zipcode!.text = self.item!["zipCode"] as? String
                self.outdoornumber!.text = self.item!["outerNumber"] as? String
                self.indoornumber!.text = self.item!["innerNumber"] as? String
                idSuburb = self.item!["neighborhoodId"] as? String
                self.municipality!.text = self.item!["county"] as? String
                self.city!.text = self.item!["city"] as? String
                self.state!.text = self.item!["state"] as? String
                if let prefered = self.item!["preferred"] as? NSNumber{
                    if prefered==1{
                        self.preferedLabel!.text = NSLocalizedString("profile.address.prefered",comment:"")
                    }
                }
                textFieldDidEndEditing(self.zipcode!)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == zipcode{
            if !self.isFromInvoice{
                self.callServiceZip(textField.text!, showError: true)
            }else{
                self.callServiceFiscalZip(textField.text!, showError: true)
            }
        }
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let keyword = strNSString.replacingCharacters(in: range, with: string)
        
        if self.delegate != nil{
            self.delegate!.textModify(textField)
        }
        
        if textField == self.telephone {
            telipad = self.telephone!.text!
            if keyword.characters.count == 10{
                textField.text = keyword
                let _ = self.shortNameField?.becomeFirstResponder()
                return false
            }
            else if keyword.characters.count > 10 {
                return false
            }
            else {
                return true
            }
        }
        
        if textField == zipcode {
            
            if Int(keyword) == nil && keyword != "" {
                return false
            }
            if keyword.characters.count == 5{
                if !self.isFromInvoice{
                    self.callServiceZip(keyword, showError: true)
                }else{
                    self.callServiceFiscalZip(keyword, showError: true)
                }
            }
            else if keyword.characters.count > 5 {
                return false
            }
        }
        
        if textField == indoornumber {
        
            if keyword.length() > 50 {
                return false
            }
            
        }
        
        return true
    }
    
    func callServiceZip(_ zipCodeUsr: String, showError:Bool){
        
        let zipCode = zipCodeUsr.trimmingCharacters(in: CharacterSet.whitespaces)
        if zipCode.characters.count==0 {
            return
        }
        var padding : String = ""
        if zipCode.characters.count < 5 {
            padding =  padding.padding( toLength: 5 - zipCode.characters.count , withPad: "0", startingAt: 0)
        }
        
        if (padding + zipCode ==  "00000") {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "Texto no permitido" , errorView:self.errorView! , becomeFirstResponder: true)
            
            return
        }
        
        if viewLoad == nil{
            viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.superview!.frame.width, height: self.superview!.frame.height - 46))
            viewLoad.backgroundColor = UIColor.white
        }
        
        
        let service = ZipCodeService()
        //self.addSubview(viewLoad)
        self.superview?.addSubview(viewLoad)
        viewLoad.startAnnimating(false)
        
        
        service.buildParams(padding + zipCode)
        service.callService([String:Any](),  successBlock:{ (resultCall:[String:Any]?) in
            self.viewLoad.stopAnnimating()
            if let city = resultCall!["city"] as? String {
                self.city!.text = city
                self.municipality!.text = resultCall!["county"] as? String
                self.state!.text = resultCall!["state"] as? String
                self.zipcode!.text = resultCall!["zipCode"] as? String
                var setElement = false
                if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                    for dic in  resultCall!["neighborhoods"] as! [[String:Any]]{
                        if dic["id"] as? String ==  self.idSuburb{
                            self.suburb!.text = dic["name"] as? String
                            setElement = true
                            break
                        }// if dic["id"] as? String ==  self.idSuburb{
                    }//for dic in  resultCall!["neighborhoods"] as [[String:Any]]{
                }//if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                self.listSuburb = resultCall!["neighborhoods"] as! [[String:Any]]
                self.validateShowField()
                if !setElement && self.listSuburb.count > 0  {
                    let _ = self.suburb?.becomeFirstResponder()
                    self.suburb!.text = self.listSuburb[0]["name"] as? String
                    self.idSuburb = self.listSuburb[0]["id"] as? String
                }//if setElement && self.listSuburb.count > 0  {
                self.pickerSuburb!.reloadAllComponents()
            }
            }, errorBlock: {(error: NSError) in
                self.listSuburb = []
                self.pickerSuburb!.reloadAllComponents()
                self.idSuburb = ""
                self.city!.text = ""
                self.municipality!.text = ""
                self.state!.text = ""
                self.suburb!.text = ""
                self.viewLoad.stopAnnimating()
                if showError {
                    
                    self.validateShowField()
                    
                    if self.errorView == nil{
                        self.errorView = FormFieldErrorView()
                    }
                    let stringToShow : NSString = error.localizedDescription as NSString
                    let withoutName = stringToShow.replacingOccurrences(of: self.zipcode!.nameField, with: "")
                    SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: true )
                }
                else{
                    let _ = self.zipcode?.resignFirstResponder()
                }
        })
    }

    func callServiceFiscalZip(_ zipCodeUsr: String, showError:Bool){
        
        let zipCode = zipCodeUsr.trimmingCharacters(in: CharacterSet.whitespaces)
        if zipCode.characters.count==0 {
            return
        }
        var padding : String = ""
        if zipCode.characters.count < 5 {
            padding =  padding.padding( toLength: 5 - zipCode.characters.count , withPad: "0", startingAt: 0)
        }
        
        if (padding + zipCode ==  "00000") {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "Texto no permitido" , errorView:self.errorView! , becomeFirstResponder: true)
            
            return
        }
        
        if viewLoad == nil{
            viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.superview!.frame.width, height: self.superview!.frame.height - 46))
            viewLoad.backgroundColor = UIColor.white
        }
        
        
        let service = InvoiceDataCPService()
        //self.addSubview(viewLoad)
        //self.superview?.addSubview(viewLoad)
        //viewLoad.startAnnimating(false)
        
        service.callService(params: ["postalCode":zipCode],  successBlock:{ (resultCall:[String:Any]?) in
          //  self.viewLoad.stopAnnimating()
            var responseOk : String! = ""
            if let headerData = resultCall!["headerResponse"] as? [String:Any]{
                // now val is not nil and the Optional has been unwrapped, so use it
                responseOk = headerData["responseCode"] as! String
            
            if responseOk == "OK"{

                let businessData = resultCall!["businessResponse"] as? [String:Any]
                let domicilio = businessData?["domicilioColonia"] as! [String:Any]
                self.city!.text = domicilio["ciudad"] as? String
                self.municipality!.text = domicilio["delegacionMunicipio"] as? String
                self.state!.text = domicilio["estado"] as? String
                self.zipcode!.text = domicilio["codigoPostal"] as? String
                var setElement = false
                if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                    var index = 0
                    for dic in  domicilio["coloniasList"] as! [[String:Any]]{
                        if String(index) ==  self.idSuburb{
                            self.suburb!.text = dic["descripcion"] as? String
                            setElement = true
                            break
                        }
                        index += 1// if dic["id"] as? String ==  self.idSuburb{
                    }//for dic in  resultCall!["neighborhoods"] as [[String:Any]]{
                }//if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                self.listSuburb = domicilio["coloniasList"] as! [[String : Any]]
                self.validateShowField()
                if !setElement && self.listSuburb.count > 0  {
                    let _ = self.suburb?.becomeFirstResponder()
                    self.suburb!.text = self.listSuburb[1]["descripcion"] as? String
                    self.idSuburb = "1"
                }//if setElement && self.listSuburb.count > 0  {
                self.pickerSuburb!.reloadAllComponents()                }
            else{
                let errorMess = headerData["responseDescription"] as! String
                self.listSuburb = []
                self.pickerSuburb!.reloadAllComponents()
                self.idSuburb = ""
                self.city!.text = ""
                self.municipality!.text = ""
                self.state!.text = ""
                self.suburb!.text = ""
                self.viewLoad.stopAnnimating()
                if showError {
                    
                    self.validateShowField()
                    
                    if self.errorView == nil{
                        self.errorView = FormFieldErrorView()
                    }
                    let stringToShow : NSString = errorMess as NSString
                    let withoutName = stringToShow.replacingOccurrences(of: self.zipcode!.nameField, with: "")
                    SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: true )
                }
                else{
                    let _ = self.zipcode?.resignFirstResponder()
                }
                }
            }
        }, errorBlock: {(error: NSError) in
            self.listSuburb = []
            self.pickerSuburb!.reloadAllComponents()
            self.idSuburb = ""
            self.city!.text = ""
            self.municipality!.text = ""
            self.state!.text = ""
            self.suburb!.text = ""
            self.viewLoad.stopAnnimating()
            if showError {
                
                self.validateShowField()
                
                if self.errorView == nil{
                    self.errorView = FormFieldErrorView()
                }
                let stringToShow : NSString = error.localizedDescription as NSString
                let withoutName = stringToShow.replacingOccurrences(of: self.zipcode!.nameField, with: "")
                SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: true )
            }
            else{
                let _ = self.zipcode?.resignFirstResponder()
            }
        })
    }

    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
    return listSuburb.count
    }
    
    func validateShowField() {
        if self.listSuburb.count > 0{
            if !showSuburb {
                self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width,height: self.state!.frame.maxY)
                self.suburb!.isHidden = false
                self.municipality!.isHidden = false
                self.city!.isHidden = false
                self.state!.isHidden = false
                showSuburb = true
                delegate?.validateZip!(true)
                delegate?.setContentSize()
            }
        } else {
            if showSuburb == true {
                self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width,height: self.zipcode!.frame.maxY)
                self.suburb!.isHidden = true
                self.municipality!.isHidden = true
                self.city!.isHidden = true
                self.state!.isHidden = true
                showSuburb = false
                delegate?.setContentSize()
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if listSuburb.count > 0 {
            if isFromInvoice{
                if row == 1 {
                    self.idSuburb = "1"
                    suburb!.text = listSuburb[row]["descripcion"] as? String
                }
                return listSuburb[row]["descripcion"] as? String
            }else{
                if row == 0 {
                    self.idSuburb = listSuburb[row]["id"] as? String
                    suburb!.text = listSuburb[row]["name"] as? String
                }
                return listSuburb[row]["name"] as? String
            }
            
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if listSuburb.count > 0 {
            if isFromInvoice{
                if row>0{
                delegate?.textModify(suburb!)
                self.idSuburb = String(row)
                suburb!.text = listSuburb[row]["descripcion"] as? String
                }
                
            }else{
                delegate?.textModify(suburb!)
                self.idSuburb = listSuburb[row]["id"] as? String
                suburb!.text = listSuburb[row]["name"] as? String
            }
            
        }
    }
    
    func validateAddress() -> Bool{
        var error = viewError(shortNameField!)
        if !error{
            error = viewError(street!)
        }
        if !error{
            error = viewError(outdoornumber!)
        }
        if !error{
            error = viewError(indoornumber!)
        }
        if !error{
            error = validateShortName()
        }
        if !error{
            error = viewError(zipcode!)
            let message = suburb!.validate()
            if message != nil {
                error = viewError(zipcode!,message:NSLocalizedString("field.validate.zipcode",comment:""))
            }
        }
        if !error{
            if (self.zipcode!.text ==  "00000") {
                if self.errorView == nil{
                    self.errorView = FormFieldErrorView()
                }
                SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "Texto no permitido" , errorView:self.errorView! ,  becomeFirstResponder: true)
                return false
            }
        }
        
        if !error{
            error = viewError(municipality!)
        }
        if !error{
            error = viewError(city!)
        }
        if !error{
            error = viewError(state!)
        }
        if error{
            return false
        }
        return true
    }
    
    func validateFiscalAddress() -> Bool{
        var error = viewError(street!)
        if !error{
            error = viewError(outdoornumber!)
        }
        if !error{
            error = viewError(indoornumber!)
        }
        if !error{
            error = viewError(zipcode!)
            let message = suburb!.validate()
            if message != nil {
                error = viewError(zipcode!,message:NSLocalizedString("field.validate.zipcode",comment:""))
            }
        }
        if !error{
            if (self.zipcode!.text ==  "00000") {
                if self.errorView == nil{
                    self.errorView = FormFieldErrorView()
                }
                SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "Texto no permitido" , errorView:self.errorView! ,  becomeFirstResponder: true)
                return false
            }
        }
        
        if error{
            return false
        }
        return true
    }
    
    func validateShortName()-> Bool {
        let id = self.idAddress == nil ? "-1" : self.idAddress!
        for item in  self.allAddress as! [[String:Any]]{
            let idItem = item["addressID"] as! NSString
            let name = item["name"] as! NSString
            if id != idItem as String && name.uppercased ==  shortNameField!.text!.uppercased() {
                let _ = self.viewError(shortNameField!, message:NSLocalizedString("profile.address.already.exist", comment: ""))
                return true
            }
        }
        return false
    }
    
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(_ field: FormFieldView,message:String?)-> Bool{
        if message != nil {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:"", message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        }
        return false
    }
    
    func getParams() -> [String:Any]{
        var paramsAddress : [String : Any]
        if isFromInvoice{
            paramsAddress = ["calle":self.street!.text!,"ciudadEstado":self.city!.text!,"codigoPostal":self.zipcode!.text!,"colonia":self.suburb!.text!,"delegacionMunicipio":self.municipality!.text!,"numeroExterior":self.outdoornumber!.text!,"numeroInterior":self.indoornumber!.text!,"referencia":self.shortNameField!.text!]
        }else{
            paramsAddress = ["token":"token","city":self.city!.text!,"zipCode":self.zipcode!.text!,"street":self.street!.text! ,"innerNumber":self.indoornumber!.text!,"state":self.state!.text!,"county":self.city!.text!,"neighborhoodID":self.idSuburb!,"name":self.shortNameField!.text!,"outerNumber":self.outdoornumber!.text! , "preferred": self.defaultPrefered ? 1:0]
            if idAddress != nil{
                paramsAddress.updateValue(self.idAddress! as AnyObject, forKey: "AddressID")
            }
        }
        
        return paramsAddress
    }

    
}
