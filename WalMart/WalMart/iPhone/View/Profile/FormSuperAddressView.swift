//
//  FormSuperAddressView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol FormSuperAddressViewDelegate: class {
    func showUpdate()
    func showNoCPWarning()
}

class FormSuperAddressView : UIView, AlertPickerViewDelegate,UITextFieldDelegate {
    
    var titleLabelAddress : UILabel!
    var titleLabelBetween : UILabel!
    var errorLabelStore: UILabel!
    var addressName : FormFieldView!
    var street : FormFieldView!
    var outdoornumber : FormFieldView!
    var indoornumber : FormFieldView!
    var zipcode : FormFieldView!
    var store : FormFieldView!
    var suburb : FormFieldView!
    var betweenFisrt : FormFieldView!
    var betweenSecond : FormFieldView!
    var leftRightPadding  : CGFloat = CGFloat(16)
    var errorLabelWidth  : CGFloat = CGFloat(150)
    var fieldHeight  : CGFloat = CGFloat(40)
    var separatorField  : CGFloat = CGFloat(8)
    var neighborhoods : [String]! = []
    var stores : [String]! = []
    var allAddress: [Any]! = []
    var titleLabelPhone : UILabel!
    var phoneWorkNumber : FormFieldView!
    var cellPhone : FormFieldView!
    var phoneHomeNumber : FormFieldView!
    
    var neighborhoodsDic : [[String:Any]]! = []
    var storesDic : [[String:Any]]! = []
    var resultDict : [String:Any]! = [:]
    
    var selectedStore : IndexPath!
    var selectedNeighborhood : IndexPath!
    
    var errorView : FormFieldErrorView? = nil
    weak var delegateFormAdd : FormSuperAddressViewDelegate?
    
    var currentZipCode = ""
    var picker : AlertPickerView!
    
    var idAddress : String!
    var isSignUp = false
    
    var gPhoneHome  = "";
    var gPhoneWork  = "";
    var gCellPhone       = "";

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        picker = AlertPickerView.initPickerWithDefault()
    
        var width = self.frame.width
        if IS_IPAD {
           width = 1024.0
        }
      

        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: width, height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                if field! == self.zipcode {
                    if self.zipcode.text!.utf16.count > 0 {
                        let xipStr = self.zipcode.text! as NSString
                        self.zipcode.text = String(format: "%05d",xipStr.integerValue)
                        let _ = self.store.becomeFirstResponder()
                    }
                }
                field!.resignFirstResponder()
            }
            //self.delegate.textModify(field)
        })
        
        //Address Super
        self.titleLabelAddress = UILabel()
        self.titleLabelAddress!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelAddress!.text =  NSLocalizedString("gr.address.section.title", comment: "")
        self.titleLabelAddress!.textColor = WMColor.light_blue
        
        self.errorLabelStore = UILabel()
        self.errorLabelStore!.font = WMFont.fontMyriadProLightOfSize(14)
        self.errorLabelStore!.text =  NSLocalizedString("gr.address.section.errorLabelStore", comment: "")
        self.errorLabelStore!.textColor = UIColor.red
        self.errorLabelStore!.numberOfLines = 3
        self.errorLabelStore!.textAlignment = NSTextAlignment.right
        self.errorLabelStore!.isHidden = true
        
        self.addressName = FormFieldView()
        self.addressName!.isRequired = true
        self.addressName!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname.description",comment:""))
        self.addressName!.typeField = TypeField.alphanumeric
        self.addressName!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        
        self.addressName!.minLength = 3
        self.addressName!.maxLength = 25
        
        self.street = FormFieldView()
        self.street!.isRequired = true
        self.street!.setCustomPlaceholder(NSLocalizedString("gr.address.field.street",comment:""))
        self.street!.typeField = TypeField.alphanumeric
        self.street!.nameField = NSLocalizedString("gr.address.field.street",comment:"")
        self.street!.minLength = 2
        self.street!.maxLength = 50
        
        self.outdoornumber = FormFieldView()
        self.outdoornumber!.isRequired = true
        self.outdoornumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.outdoornumber",comment:""))
        self.outdoornumber!.typeField = TypeField.numAddress
        self.outdoornumber!.minLength = 1
        self.outdoornumber!.maxLength = 5
        self.outdoornumber!.nameField = NSLocalizedString("gr.address.field.outdoornumber",comment:"")
        
        self.indoornumber = FormFieldView()
        self.indoornumber!.isRequired = false
        self.indoornumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.indoornumber",comment:""))
        self.indoornumber!.typeField = TypeField.numAddress
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 5
        self.indoornumber!.nameField = NSLocalizedString("gr.address.field.indoornumber",comment:"")
        
        
        self.zipcode = FormFieldView()
        self.zipcode!.isRequired = true
        self.zipcode!.setCustomPlaceholder(NSLocalizedString("gr.address.field.zipcode",comment:""))
        self.zipcode!.typeField = TypeField.number
        self.zipcode!.minLength = 5
        self.zipcode!.maxLength = 5
        self.zipcode!.nameField = NSLocalizedString("gr.address.field.zipcode",comment:"")
        self.zipcode!.keyboardType = UIKeyboardType.numberPad
        self.zipcode!.inputAccessoryView = viewAccess
        self.zipcode!.disablePaste = true
        self.zipcode!.delegate = self
        
        self.store = FormFieldView()
        self.store!.isRequired = true
        self.store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        self.store!.typeField = TypeField.list
        self.store!.nameField = NSLocalizedString("gr.address.field.store",comment:"")
        
        self.suburb = FormFieldView()
        self.suburb!.isRequired = true
        self.suburb!.setCustomPlaceholder(NSLocalizedString("gr.address.field.suburb",comment:""))
        self.suburb!.typeField = TypeField.list
        self.suburb!.nameField = NSLocalizedString("gr.address.field.suburb",comment:"")
        
        //Add title
        
        self.titleLabelBetween = UILabel()
        self.titleLabelBetween!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelBetween!.text =  NSLocalizedString("gr.address.section.between.title", comment: "")
        self.titleLabelBetween!.textColor = WMColor.light_blue
        
        self.betweenFisrt = FormFieldView()
        self.betweenFisrt!.isRequired = false
        self.betweenFisrt!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenFisrt",comment:""))
        self.betweenFisrt!.typeField = TypeField.alphanumeric
        self.betweenFisrt!.nameField = NSLocalizedString("gr.address.field.betweenFisrt",comment:"")
        self.betweenFisrt!.minLength = 2
        self.betweenFisrt!.maxLength = 50
        
        self.betweenSecond = FormFieldView()
        self.betweenSecond!.isRequired = false
        self.betweenSecond!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenSecond",comment:""))
        self.betweenSecond!.typeField = TypeField.alphanumeric
        self.betweenSecond!.nameField = NSLocalizedString("gr.address.field.betweenSecond",comment:"")
        self.betweenSecond!.minLength = 2
        self.betweenSecond!.maxLength = 50
        
        self.titleLabelPhone = UILabel()
        self.titleLabelPhone!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelPhone!.text =  NSLocalizedString("gr.address.section.between.phone", comment: "")
        self.titleLabelPhone!.textColor = WMColor.light_blue
        
        self.phoneHomeNumber = FormFieldView()
        self.phoneHomeNumber!.isRequired = true
        self.phoneHomeNumber!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone.house",comment:""))
        self.phoneHomeNumber!.typeField = TypeField.phone
        self.phoneHomeNumber!.nameField = NSLocalizedString("profile.address.field.telephone.house",comment:"")
        self.phoneHomeNumber!.minLength = 10
        self.phoneHomeNumber!.maxLength = 10
        self.phoneHomeNumber!.disablePaste = true
        self.phoneHomeNumber!.keyboardType = UIKeyboardType.numberPad
        self.phoneHomeNumber!.inputAccessoryView = viewAccess
        self.phoneHomeNumber!.delegate =  self
        
        self.phoneWorkNumber = FormFieldView()
        self.phoneWorkNumber!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone.office",comment:""))
        self.phoneWorkNumber!.typeField = TypeField.number
        self.phoneWorkNumber!.nameField = NSLocalizedString("profile.address.field.telephone.office",comment:"")
        self.phoneWorkNumber!.minLength = 0
        self.phoneWorkNumber!.maxLength = 10
        self.phoneWorkNumber!.disablePaste = true
        self.phoneWorkNumber!.delegate = self
        self.phoneWorkNumber!.keyboardType = UIKeyboardType.numberPad
        self.phoneWorkNumber!.inputAccessoryView = viewAccess
        
        self.cellPhone = FormFieldView()
        self.cellPhone!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone.cell",comment:""))
        self.cellPhone!.typeField = TypeField.phone
        self.cellPhone!.nameField = NSLocalizedString("profile.address.field.telephone.cell",comment:"")
        self.cellPhone!.minLength = 10
        self.cellPhone!.maxLength = 10
        self.cellPhone!.disablePaste = true
        self.cellPhone!.keyboardType = UIKeyboardType.numberPad
        self.cellPhone!.inputAccessoryView = viewAccess
        self.cellPhone.delegate = self
        
        
        if UserCurrentSession.hasLoggedUser() {
            self.cellPhone!.text = UserCurrentSession.sharedInstance.userSigned!.profile.cellPhone as String
            self.phoneWorkNumber!.text = UserCurrentSession.sharedInstance.userSigned!.profile.phoneWorkNumber as String
            self.phoneHomeNumber!.text = UserCurrentSession.sharedInstance.userSigned!.profile.phoneHomeNumber as String
        }

        
        self.addSubview(self.titleLabelAddress)
        self.addSubview(self.errorLabelStore)
        self.addSubview(self.addressName)
        self.addSubview(self.street)
        self.addSubview(self.outdoornumber)
        self.addSubview(self.indoornumber)
        self.addSubview(self.zipcode)
        self.addSubview(self.store)
        self.addSubview(self.suburb)
        self.addSubview(self.titleLabelBetween)
        self.addSubview(self.betweenFisrt)
        self.addSubview(self.betweenSecond)
        self.addSubview(self.titleLabelPhone)
        self.addSubview(self.phoneHomeNumber)
        self.addSubview(self.phoneWorkNumber)
        self.addSubview(self.cellPhone)
        
        
        
        self.store.onBecomeFirstResponder = { () in
            
            if self.currentZipCode != self.zipcode.text {
                self.currentZipCode = self.zipcode.text!
                var zipCode = self.zipcode.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                
                self.neighborhoods = []
                self.stores = []
                
                self.suburb!.text = ""
                self.selectedNeighborhood = nil
                
                self.store!.text = ""
                self.selectedStore = nil
                
                var padding : String = ""
                
                let textZipcode = String(format: "%05d",(zipCode as NSString).integerValue)
                zipCode = textZipcode.substring(to: textZipcode.characters.index(textZipcode.startIndex, offsetBy: 5))
                
                if zipCode.characters.count < 5 {
                    padding =  padding.padding( toLength: 5 - zipCode.characters.count , withPad: "0", startingAt: 0)
                }
                
                if (padding + zipCode ==  "00000") {
                    if self.errorView == nil{
                        self.errorView = FormFieldErrorView()
                    }
                    SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "No Valido" , errorView:self.errorView! ,  becomeFirstResponder: true)
                    return
                }
                
                let serviceZip = GRZipCodeService()
                serviceZip.buildParams(padding + zipCode )
                serviceZip.callService([:], successBlock: { (result:[String:Any]) -> Void in
                    
                    self.resultDict = result
                    self.neighborhoods = []
                    self.stores = []
                    
                    let zipreturned = result["zipCode"] as! String
                    self.zipcode.text = zipreturned
                    
                    self.neighborhoodsDic = result["neighborhoods"] as! [[String:Any]]
                    for dic in  self.neighborhoodsDic {
                        self.neighborhoods.append(dic["name"] as! String!)
                    }//for dic in  resultCall!["neighborhoods"] as [[String:Any]]{
                    self.storesDic = result["stores"] as! [[String:Any]]
                    for dic in  self.storesDic {
                        let name = dic["name"] as! String!
                        let cost = dic["cost"] as! String!
                        self.stores.append("\(name!) - \(cost!)")
                    }//for dic in  resultCall!["neighborhoods"] as [[String:Any]]{
                    
                    /*if self.stores.count == 0 {
                        
                        self.zipcode.text = ""
                        
                        self.store.text = ""
                        self.suburb.text = ""
                        
                        self.delegateFormAdd?.showNoCPWarning()
                        return
                    }*/
                    
                    if self.stores.count == 0 && !self.store.isRequired
                    {
                        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                        alertView!.setMessage(NSLocalizedString("gr.address.field.notStore",comment:""))
                        alertView!.showDoneIconWithoutClose()
                        alertView!.showOkButton("OK", colorButton: WMColor.green)
                    }
                    
                    self.showErrorLabel(self.stores.count == 0)
                    
                    //Default Values
                    if self.neighborhoods.count > 0 {
                        self.suburb!.text = self.neighborhoods[0]
                        self.selectedNeighborhood = IndexPath(row: 0, section: 0)
                        if  self.errorView?.focusError == self.suburb {
                            self.errorView?.removeFromSuperview()
                            self.errorView = nil
                        }
                    }
                    
                    if self.stores.count > 0 {
                        self.store!.text = self.stores[0]
                        self.selectedStore = IndexPath(row: 0, section: 0)
                        if  self.errorView?.focusError == self.store {
                            self.errorView?.removeFromSuperview()
                            self.errorView = nil
                        }
                        self.picker!.selected = self.selectedStore
                        self.picker!.sender = self.store!
                        self.picker!.delegate = self
                        self.picker!.setValues(self.store!.nameField, values: self.stores)
                        self.picker!.showPicker()
                    }
                    
                    self.endEditing(true)
                    
                    if self.errorView != nil {
                        if  self.errorView?.focusError == self.zipcode {
                            self.errorView?.removeFromSuperview()
                            self.errorView = nil
                        }
                    }
                    
                    
                    
                    }, errorBlock: { (error:NSError) -> Void in
                        
                        //self.zipcode.text = ""
                        //self.currentZipCode  = ""
                        self.store.text = ""
                        self.suburb.text = ""
                         self.storesDic = []
                        self.neighborhoods = []
                        self.stores = []
                        
                        self.showErrorLabel(true)                     
                        if self.errorView == nil{
                            self.errorView = FormFieldErrorView()
                        }
                        var stringToShow : NSString = error.localizedDescription as NSString
                        if error.code != -1 {
                            stringToShow = "Intenta nuevamente."
                        }
                        let withoutName = stringToShow.replacingOccurrences(of: self.zipcode!.nameField, with: "")
                        SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: false )
                        
                        //self.delegateFormAdd?.showNoCPWarning()
                        return
                        
                        
                })
            } else {
                self.endEditing(true)
                
                if (self.stores.count > 0){
                    self.picker!.selected = self.selectedStore
                    self.picker!.sender = self.store!
                    self.picker!.delegate = self
                    self.picker!.setValues(self.store!.nameField, values: self.stores)
                    self.picker!.showPicker()
                }
            }
        }
        
        self.suburb.onBecomeFirstResponder = { () in
            if self.neighborhoods.count > 0 {
                self.endEditing(true)
                self.picker!.selected = self.selectedNeighborhood
                self.picker!.sender = self.suburb!
                self.picker!.delegate = self
                self.picker!.setValues(self.suburb!.nameField, values: self.neighborhoods)
                self.picker!.showPicker()
            }
        }
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rightPadding = leftRightPadding * 2
        
        
        self.titleLabelAddress.frame = CGRect(x: leftRightPadding, y: 0, width: self.frame.width - rightPadding , height: fieldHeight)
        self.errorLabelStore.frame = CGRect(x: (self.frame.width - leftRightPadding) - errorLabelWidth , y: 0, width: errorLabelWidth , height: fieldHeight)
        self.addressName.frame = CGRect(x: leftRightPadding, y: self.titleLabelAddress.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.street.frame = CGRect(x: leftRightPadding, y: self.addressName.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.outdoornumber.frame = CGRect(x: leftRightPadding, y: self.street.frame.maxY + separatorField, width: ((self.frame.width - rightPadding) / 2) - 8, height: fieldHeight)
        self.indoornumber.frame = CGRect(x: self.outdoornumber.frame.maxX + leftRightPadding, y: self.street.frame.maxY + separatorField, width: ((self.frame.width - rightPadding) / 2) - 8 , height: fieldHeight)
        self.zipcode.frame = CGRect(x: leftRightPadding, y: self.indoornumber.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.store.frame = CGRect(x: leftRightPadding, y: self.zipcode.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.suburb.frame = CGRect(x: leftRightPadding, y: self.store.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleLabelBetween.frame = CGRect(x: leftRightPadding, y: self.suburb.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.betweenFisrt.frame = CGRect(x: leftRightPadding, y: self.titleLabelBetween.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.betweenSecond.frame = CGRect(x: leftRightPadding, y: self.betweenFisrt.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleLabelPhone.frame = CGRect(x: leftRightPadding, y: self.betweenSecond.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.phoneHomeNumber.frame = CGRect(x: leftRightPadding, y: self.titleLabelPhone.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.phoneWorkNumber.frame = CGRect(x: leftRightPadding, y: self.phoneHomeNumber.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.cellPhone.frame = CGRect(x: leftRightPadding, y: self.phoneWorkNumber.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        
        
    }
    
    func invokeStoresService() {
        
    }
    
    func didSelectOption(_ picker:AlertPickerView, indexPath:IndexPath ,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.store! {
                self.store!.text = selectedStr
                self.selectedStore = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd?.showUpdate()
                }
            }
            if formFieldObj ==  self.suburb! {
                self.suburb!.text = selectedStr
                self.selectedNeighborhood = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd?.showUpdate()
                }
            }
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.store! {
                self.store!.text = ""
                
            }
            if formFieldObj ==  self.suburb! {
                self.suburb!.text = ""
            }
        }
    }
    
    
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    
    func getAddressDictionary(_ addressId:String , delete:Bool) -> [String:Any]? {
        return getAddressDictionary(addressId , delete:delete,preferred:false)
    }
    
    func getAddressDictionary(_ addressId:String , delete:Bool,preferred:Bool) -> [String:Any]? {
        endEditing(true)
        let service = GRAddressAddService()
        
        if !delete {
            
            if self.viewError(self.addressName) {
                return nil
            }
            if (self.validateShortName(addressId)) {
                return nil
            }
            if self.viewError(self.street)  {
                return nil
            }
            if self.viewError(self.outdoornumber)  {
                return nil
            }
            if self.viewError(self.indoornumber)  {
                return nil
            }
            if self.viewError(self.zipcode)  {
                return nil
            }
            if (self.outdoornumber!.text == "0"){
                if self.errorView == nil{
                    self.errorView = FormFieldErrorView()
                }
                SignUpViewController.presentMessage(self.outdoornumber!, nameField:self.outdoornumber!.nameField, message: "Texto no permitido" , errorView:self.errorView! ,  becomeFirstResponder: true)
                return nil
            }
            
            if (self.zipcode!.text ==  "00000") {
                if self.errorView == nil{
                    self.errorView = FormFieldErrorView()
                }
                SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "Texto no permitido" , errorView:self.errorView! ,  becomeFirstResponder: true)
                return nil
            }
            
            
            
            if self.viewError(self.store) {
                return nil
            }
            
            if self.viewError(self.suburb)  {
                return nil
            }
            if self.viewError(self.betweenFisrt)  {
                return nil
            }
            if  self.viewError(self.betweenSecond)  {
                return nil
            }
        }
        //cambio para direcciones!
        if self.zipcode!.text != "" && self.zipcode!.text !=  "00000" && self.store.text == "" && self.suburb.text == "" && self.stores.count > 0 {
            let _ = self.store.becomeFirstResponder()
            return nil


        }

        if self.phoneHomeNumber.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""
            && self.cellPhone.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""
            && !delete  {
                let _ = self.viewError(self.phoneHomeNumber,message: "Es necesario capturar un teléfono")
                return nil
        }
        if self.phoneWorkNumber.text != "" {
            let toValidate : NSString = self.phoneWorkNumber.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
            if  self.viewError(self.phoneWorkNumber)  {
                return nil
            }
            if (toValidate == "0000000000" || toValidate.substring(to: 2) == "00")
                && !delete {
                    let _ = self.viewError(self.phoneWorkNumber, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                    return nil
            }
            
            gPhoneWork = self.phoneWorkNumber.text!
            
        }
        if self.phoneHomeNumber.text != ""   && !delete {
            let toValidate : NSString = self.phoneHomeNumber.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
            if  self.viewError(self.phoneHomeNumber)  {
                return nil
            }
            if (toValidate == "0000000000" || toValidate.substring(to: 2) == "00")  && !delete{
                let _ = self.viewError(self.phoneHomeNumber, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                return nil
            }
            
            self.gPhoneHome = self.phoneHomeNumber.text!

        }
        if self.cellPhone.text != "" {
            let toValidate : NSString = self.cellPhone.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
            if  self.viewError(self.cellPhone)  {
                return nil
            }
            if (toValidate == "0000000000" || toValidate.substring(to: 2) == "00"   && !delete) {
                let _ = self.viewError(self.cellPhone, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                return nil
            }
            
            gCellPhone = self.cellPhone.text!

        }
        
        UserCurrentSession.sharedInstance.setMustUpdatePhoneProfile(self.phoneHomeNumber.text!, work: self.phoneWorkNumber.text!, cellPhone: self.cellPhone.text!)
        
        let resultDictVal = JSON(resultDict)
        
        let strCity =  resultDictVal["city"].stringValue
        let zipCode = self.zipcode.text
        let street =  self.street!.text
        let innerNumber =  self.indoornumber!.text
        let state =  resultDictVal["state"].stringValue
        let county =  resultDictVal["county"].stringValue
        var  neightId = ""
        if self.neighborhoods.count > 0 {
            if selectedNeighborhood !=  nil {
                let neightDict =  self.neighborhoodsDic[selectedNeighborhood.row]
                neightId = neightDict["id"] as! String
            }
        }
        let name = self.addressName.text
        let outerNumber =  self.outdoornumber!.text
        let referenceOne =  self.betweenFisrt!.text
        let referenceTwo =  self.betweenSecond!.text
        
        var  storeId = ""
        var  storeName = ""
        if self.storesDic.count > 0 {
            let storeDict =  self.storesDic[selectedStore.row]
            storeId = storeDict["id"] as! String!
            storeName = storeDict["name"] as! String!
        }
        
        var action = "A"
        if delete {
            action = "B"
        }else
            if addressId != "" {
                action = "C"
        }
        return  service.buildParams(strCity, addressID: addressId, zipCode: zipCode!, street: street!, innerNumber: innerNumber!, state: state, county: county, neighborhoodID: neightId, phoneNumber: "", outerNumber: outerNumber!, adName: name!, reference1: referenceOne!, reference2: referenceTwo!, storeID: storeId,storeName: storeName, operationType: action, preferred: preferred)
    }
    
    func validateShortName(_ addressId:String)-> Bool {
        let id = addressId == "" ? "-1" : addressId
        for item in  self.allAddress as! [[String:Any]]{
            let idItem = item["id"] as! String
            let name = item["name"] as! String
            if id != idItem && name.uppercased() ==  addressName!.text!.uppercased() {
                let _ = self.viewError(addressName!, message:NSLocalizedString("profile.address.already.exist", comment: ""))
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
            
            SignUpViewController.presentMessage(field, nameField: field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            
            if isSignUp {
                BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(errorView!.errorLabel.text!, stepError: "Direcciones")
            }
            
            return true
        } else {
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
        return false
    }
    
    
    func setZipCodeAnfFillFields(_ zipcode:String,neighborhoodID:String,storeID:String) {
        let serviceZip = GRZipCodeService()
        serviceZip.buildParams(self.zipcode.text!)
        serviceZip.callService([:], successBlock: { (result:[String:Any]) -> Void in
            
            self.resultDict = result
            self.neighborhoods = []
            self.stores = []
            
            self.neighborhoodsDic = result["neighborhoods"] as! [[String:Any]]
            var index = 0
            for dic in  self.neighborhoodsDic {
                
                self.neighborhoods.append(dic["name"] as! String!)
                let idNeighborhood = dic["id"] as! String!
                if neighborhoodID == idNeighborhood {
                    self.suburb!.text = self.neighborhoods[index]
                    self.selectedNeighborhood = IndexPath(row: index, section: 0)
                }
                if neighborhoodID == "" {
                    self.suburb!.text = self.neighborhoods[0]
                    self.selectedNeighborhood = IndexPath(row: 0, section: 0)
                }
                index += 1
            }//for dic in  resultCall!["neighborhoods"] as [[String:Any]]{
            
            self.storesDic = result["stores"] as! [[String:Any]]
            for dic in  self.storesDic {
                let name = dic["name"] as! String!
                let cost = dic["cost"] as! String!
                
                self.stores.append("\(name!) - \(cost!)")
                
                let idStore = dic["id"] as! String!
                if idStore == storeID {
                    self.store!.text = self.stores[self.stores.count - 1]
                    self.selectedStore = IndexPath(row: self.stores.count - 1, section: 0)
                    self.currentZipCode = self.zipcode.text!
                }
                if storeID == "" {
                    self.store!.text = self.stores[0]
                    self.selectedStore = IndexPath(row: 0, section: 0)
                }
                
            }//for dic in  resultCall!["neighborhoods"] as [[String:Any]]{
            
            
            //            self.picker!.selected = self.selectedStore
            //            self.picker!.sender = self.store!
            //            self.picker!.delegate = self
            //            self.picker!.setValues(self.store!.nameField, values: self.stores)
            //self.picker!.showPicker()
            
            }, errorBlock: { (error:NSError) -> Void in
                print("error:: \(error)")
                
        })
    }
    
    func removeErrorLog() {
        if self.errorView != nil{
            if let formField = self.errorView?.focusError as? FormFieldView {
                let _ = self.viewError(formField)
            }
        }
    }
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }
    
    func saveReplaceViewSelected() {
    }
    
    //    func fieldChangeValue(value:String) {
    //        if value != currentZipCode {
    //            let xipStr = self.zipcode.text as NSString
    //            self.zipcode.text = String(format: "%05d",xipStr.integerValue)
    //            self.store.becomeFirstResponder()
    //        }
    //    }
    
    func showErrorLabel(_ show: Bool)
    {
        self.errorLabelStore!.isHidden = !show
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let fieldString = strNSString.replacingCharacters(in: range, with: string)
        if textField == self.zipcode {
            if fieldString.characters.count > 5{
                return false
            }else{
                self.delegateFormAdd?.showUpdate()
            }
            if fieldString != currentZipCode {
                self.suburb!.text = ""
                self.selectedNeighborhood = nil
            
                self.store!.text = ""
                self.selectedStore = nil
            }
        }
        
        if textField == self.phoneHomeNumber || textField == self.cellPhone {
            if fieldString.characters.count == 11 {
                return false
            }else{
                self.delegateFormAdd?.showUpdate()
            }
        }
        
        if textField == self.phoneWorkNumber {
            if fieldString.characters.count == 10 {
                return false
            }
        }
        
        return true
    }
    
    func getPhoneHomeNumber()-> String {
        
        return self.gPhoneHome
    }
    
    func getPhoneWorkNumber()-> String {
        
        return self.gPhoneWork
    }
    
    func getCellPhone()-> String {
        
        return self.gCellPhone
    }
    
}
