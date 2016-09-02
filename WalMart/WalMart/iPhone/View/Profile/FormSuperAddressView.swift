//
//  FormSuperAddressView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol FormSuperAddressViewDelegate {
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
    var allAddress: NSArray! = []
    var titleLabelPhone : UILabel!
    var phoneWorkNumber : FormFieldView!
    var cellPhone : FormFieldView!
    var phoneHomeNumber : FormFieldView!
    
    var neighborhoodsDic : [NSDictionary]! = []
    var storesDic : [NSDictionary]! = []
    var resultDict : NSDictionary! = [:]
    
    var selectedStore : NSIndexPath!
    var selectedNeighborhood : NSIndexPath!
    
    var errorView : FormFieldErrorView? = nil
    var delegateFormAdd : FormSuperAddressViewDelegate!
    
    var currentZipCode = ""
    var picker : AlertPickerView!
    
    var idAddress : String!
    
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
      

        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, width, 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                if field! == self.zipcode {
                    if self.zipcode.text!.utf16.count > 0 {
                        let xipStr = self.zipcode.text! as NSString
                        self.zipcode.text = String(format: "%05d",xipStr.integerValue)
                        self.store.becomeFirstResponder()
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
        self.errorLabelStore!.textColor = UIColor.redColor()
        self.errorLabelStore!.numberOfLines = 3
        self.errorLabelStore!.textAlignment = NSTextAlignment.Right
        self.errorLabelStore!.hidden = true
        
        self.addressName = FormFieldView()
        self.addressName!.isRequired = true
        self.addressName!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname.description",comment:""))
        self.addressName!.typeField = TypeField.Alphanumeric
        self.addressName!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        
        self.addressName!.minLength = 3
        self.addressName!.maxLength = 25
        
        self.street = FormFieldView()
        self.street!.isRequired = true
        self.street!.setCustomPlaceholder(NSLocalizedString("gr.address.field.street",comment:""))
        self.street!.typeField = TypeField.Alphanumeric
        self.street!.nameField = NSLocalizedString("gr.address.field.street",comment:"")
        self.street!.minLength = 2
        self.street!.maxLength = 50
        
        self.outdoornumber = FormFieldView()
        self.outdoornumber!.isRequired = true
        self.outdoornumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.outdoornumber",comment:""))
        self.outdoornumber!.typeField = TypeField.NumAddress
        self.outdoornumber!.minLength = 1
        self.outdoornumber!.maxLength = 5
        self.outdoornumber!.nameField = NSLocalizedString("gr.address.field.outdoornumber",comment:"")
        
        self.indoornumber = FormFieldView()
        self.indoornumber!.isRequired = false
        self.indoornumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.indoornumber",comment:""))
        self.indoornumber!.typeField = TypeField.NumAddress
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 5
        self.indoornumber!.nameField = NSLocalizedString("gr.address.field.indoornumber",comment:"")
        
        
        self.zipcode = FormFieldView()
        self.zipcode!.isRequired = true
        self.zipcode!.setCustomPlaceholder(NSLocalizedString("gr.address.field.zipcode",comment:""))
        self.zipcode!.typeField = TypeField.Number
        self.zipcode!.minLength = 5
        self.zipcode!.maxLength = 5
        self.zipcode!.nameField = NSLocalizedString("gr.address.field.zipcode",comment:"")
        self.zipcode!.keyboardType = UIKeyboardType.NumberPad
        self.zipcode!.inputAccessoryView = viewAccess
        self.zipcode!.disablePaste = true
        self.zipcode!.delegate = self
        
        self.store = FormFieldView()
        self.store!.isRequired = true
        self.store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        self.store!.typeField = TypeField.List
        self.store!.nameField = NSLocalizedString("gr.address.field.store",comment:"")
        
        self.suburb = FormFieldView()
        self.suburb!.isRequired = false
        self.suburb!.setCustomPlaceholder(NSLocalizedString("gr.address.field.suburb",comment:""))
        self.suburb!.typeField = TypeField.List
        self.suburb!.nameField = NSLocalizedString("gr.address.field.suburb",comment:"")
        
        //Add title
        
        self.titleLabelBetween = UILabel()
        self.titleLabelBetween!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelBetween!.text =  NSLocalizedString("gr.address.section.between.title", comment: "")
        self.titleLabelBetween!.textColor = WMColor.light_blue
        
        self.betweenFisrt = FormFieldView()
        self.betweenFisrt!.isRequired = false
        self.betweenFisrt!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenFisrt",comment:""))
        self.betweenFisrt!.typeField = TypeField.Alphanumeric
        self.betweenFisrt!.nameField = NSLocalizedString("gr.address.field.betweenFisrt",comment:"")
        self.betweenFisrt!.minLength = 2
        self.betweenFisrt!.maxLength = 50
        
        self.betweenSecond = FormFieldView()
        self.betweenSecond!.isRequired = false
        self.betweenSecond!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenSecond",comment:""))
        self.betweenSecond!.typeField = TypeField.Alphanumeric
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
        self.phoneHomeNumber!.typeField = TypeField.Phone
        self.phoneHomeNumber!.nameField = NSLocalizedString("profile.address.field.telephone.house",comment:"")
        self.phoneHomeNumber!.minLength = 10
        self.phoneHomeNumber!.maxLength = 10
        self.phoneHomeNumber!.keyboardType = UIKeyboardType.NumberPad
        self.phoneHomeNumber!.inputAccessoryView = viewAccess
        self.phoneHomeNumber!.delegate =  self
        
        self.phoneWorkNumber = FormFieldView()
        self.phoneWorkNumber!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone.office",comment:""))
        self.phoneWorkNumber!.typeField = TypeField.Phone
        self.phoneWorkNumber!.nameField = NSLocalizedString("profile.address.field.telephone.office",comment:"")
        self.phoneWorkNumber!.minLength = 10
        self.phoneWorkNumber!.maxLength = 10
        self.phoneWorkNumber!.keyboardType = UIKeyboardType.NumberPad
        self.phoneWorkNumber!.inputAccessoryView = viewAccess
        
        self.cellPhone = FormFieldView()
        self.cellPhone!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone.cell",comment:""))
        self.cellPhone!.typeField = TypeField.Phone
        self.cellPhone!.nameField = NSLocalizedString("profile.address.field.telephone.cell",comment:"")
        self.cellPhone!.minLength = 10
        self.cellPhone!.maxLength = 10
        self.cellPhone!.keyboardType = UIKeyboardType.NumberPad
        self.cellPhone!.inputAccessoryView = viewAccess
        
        
        if UserCurrentSession.hasLoggedUser() {
            self.cellPhone!.text = UserCurrentSession.sharedInstance().userSigned!.profile.cellPhone as String
            self.phoneWorkNumber!.text = UserCurrentSession.sharedInstance().userSigned!.profile.phoneHomeNumber as String
            self.phoneHomeNumber!.text = UserCurrentSession.sharedInstance().userSigned!.profile.phoneHomeNumber as String
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
                var zipCode = self.zipcode.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                self.neighborhoods = []
                self.stores = []
                
                self.suburb!.text = ""
                self.selectedNeighborhood = nil
                
                self.store!.text = ""
                self.selectedStore = nil
                
                var padding : String = ""
                
                let textZipcode = String(format: "%05d",(zipCode as NSString).integerValue)
                zipCode = textZipcode.substringToIndex(textZipcode.startIndex.advancedBy(5))
                
                if zipCode.characters.count < 5 {
                    padding =  padding.stringByPaddingToLength( 5 - zipCode.characters.count , withString: "0", startingAtIndex: 0)
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
                serviceZip.callService([:], successBlock: { (result:NSDictionary) -> Void in
                    
                    self.resultDict = result
                    self.neighborhoods = []
                    self.stores = []
                    
                    let zipreturned = result["zipCode"] as! String
                    self.zipcode.text = zipreturned
                    
                    self.neighborhoodsDic = result["neighborhoods"] as! [NSDictionary]
                    for dic in  self.neighborhoodsDic {
                        self.neighborhoods.append(dic["name"] as! String!)
                    }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
                    self.storesDic = result["stores"] as! [NSDictionary]
                    for dic in  self.storesDic {
                        let name = dic["name"] as! String!
                        let cost = dic["cost"] as! String!
                        self.stores.append("\(name) - \(cost)")
                    }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
                    
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
                        self.selectedNeighborhood = NSIndexPath(forRow: 0, inSection: 0)
                        if  self.errorView?.focusError == self.suburb {
                            self.errorView?.removeFromSuperview()
                            self.errorView = nil
                        }
                    }
                    
                    if self.stores.count > 0 {
                        self.store!.text = self.stores[0]
                        self.selectedStore = NSIndexPath(forRow: 0, inSection: 0)
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
                        
                        if !self.store.isRequired
                        {
                            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                            alertView!.setMessage(NSLocalizedString("gr.address.field.notStore",comment:""))
                            alertView!.showDoneIconWithoutClose()
                            alertView!.showOkButton("OK", colorButton: WMColor.green)
                        }
                        self.showErrorLabel(true)                     
                        if self.errorView == nil{
                            self.errorView = FormFieldErrorView()
                        }
                        let stringToShow : NSString = error.localizedDescription
                        let withoutName = stringToShow.stringByReplacingOccurrencesOfString(self.zipcode!.nameField, withString: "")
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
        
        
        self.titleLabelAddress.frame = CGRectMake(leftRightPadding, 0, self.frame.width - rightPadding , fieldHeight)
        self.errorLabelStore.frame = CGRectMake((self.frame.width - leftRightPadding) - errorLabelWidth , 0, errorLabelWidth , fieldHeight)
        self.addressName.frame = CGRectMake(leftRightPadding, self.titleLabelAddress.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.street.frame = CGRectMake(leftRightPadding, self.addressName.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.outdoornumber.frame = CGRectMake(leftRightPadding, self.street.frame.maxY + separatorField, ((self.frame.width - rightPadding) / 2) - 8, fieldHeight)
        self.indoornumber.frame = CGRectMake(self.outdoornumber.frame.maxX + leftRightPadding, self.street.frame.maxY + separatorField, ((self.frame.width - rightPadding) / 2) - 8 , fieldHeight)
        self.zipcode.frame = CGRectMake(leftRightPadding, self.indoornumber.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.store.frame = CGRectMake(leftRightPadding, self.zipcode.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.suburb.frame = CGRectMake(leftRightPadding, self.store.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.titleLabelBetween.frame = CGRectMake(leftRightPadding, self.suburb.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.betweenFisrt.frame = CGRectMake(leftRightPadding, self.titleLabelBetween.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.betweenSecond.frame = CGRectMake(leftRightPadding, self.betweenFisrt.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.titleLabelPhone.frame = CGRectMake(leftRightPadding, self.betweenSecond.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.phoneHomeNumber.frame = CGRectMake(leftRightPadding, self.titleLabelPhone.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.phoneWorkNumber.frame = CGRectMake(leftRightPadding, self.phoneHomeNumber.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.cellPhone.frame = CGRectMake(leftRightPadding, self.phoneWorkNumber.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        
        
    }
    
    func invokeStoresService() {
        
    }
    
    func didSelectOption(picker:AlertPickerView, indexPath:NSIndexPath ,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.store! {
                self.store!.text = selectedStr
                self.selectedStore = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd.showUpdate()
                }
            }
            if formFieldObj ==  self.suburb! {
                self.suburb!.text = selectedStr
                self.selectedNeighborhood = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd.showUpdate()
                }
            }
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.store! {
                self.store!.text = ""
                
            }
            if formFieldObj ==  self.suburb! {
                self.suburb!.text = ""
            }
        }
    }
    
    
    
    func buttomViewSelected(sender: UIButton) {
        
    }
    
    func getAddressDictionary(addressId:String , delete:Bool) -> NSMutableDictionary? {
        return getAddressDictionary(addressId , delete:delete,preferred:false)
    }
    
    func getAddressDictionary(addressId:String , delete:Bool,preferred:Bool) -> NSMutableDictionary? {
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
            self.store.becomeFirstResponder()
            return nil


        }
        
        if self.phoneWorkNumber.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == ""
            && self.phoneHomeNumber.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == ""
            && self.cellPhone.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == ""
            && !delete  {
                self.viewError(self.phoneHomeNumber,message: "Es necesario capturar un teléfono")
                return nil
        }
        if self.phoneWorkNumber.text != "" {
            let toValidate : NSString = self.phoneWorkNumber.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if  self.viewError(self.phoneWorkNumber)  {
                return nil
            }
            if (toValidate == "0000000000" || toValidate.substringToIndex(2) == "00")
                && !delete {
                    self.viewError(self.phoneWorkNumber, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                    return nil
            }
        }
        if self.phoneHomeNumber.text != ""   && !delete {
            let toValidate : NSString = self.phoneHomeNumber.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if  self.viewError(self.phoneHomeNumber)  {
                return nil
            }
            if (toValidate == "0000000000" || toValidate.substringToIndex(2) == "00")  && !delete{
                self.viewError(self.phoneHomeNumber, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                return nil
            }
        }
        if self.cellPhone.text != "" {
            let toValidate : NSString = self.cellPhone.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if  self.viewError(self.cellPhone)  {
                return nil
            }
            if (toValidate == "0000000000" || toValidate.substringToIndex(2) == "00"   && !delete) {
                self.viewError(self.cellPhone, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                return nil
            }
        }
        
        UserCurrentSession.sharedInstance().setMustUpdatePhoneProfile(self.phoneHomeNumber.text!, cellPhone: self.cellPhone.text!)
        
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
    
    func validateShortName(addressId:String)-> Bool {
        let id = addressId == "" ? "-1" : addressId
        if self.allAddress?.count > 0 {
            for item in  self.allAddress as! [NSDictionary]{
                let idItem = item["id"] as! String
                let name = item["name"] as! String
                if id != idItem && name.uppercaseString ==  addressName!.text!.uppercaseString {
                    self.viewError(addressName!, message:NSLocalizedString("profile.address.already.exist", comment: ""))
                    return true
                }
            }
        }
        return false
    }
    
    func viewError(field: FormFieldView)-> Bool{
        let message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(field: FormFieldView,message:String?)-> Bool{
        if message != nil {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField: field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        } else {
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
        return false
    }
    
    
    func setZipCodeAnfFillFields(zipcode:String,neighborhoodID:String,storeID:String) {
        let serviceZip = GRZipCodeService()
        serviceZip.buildParams(self.zipcode.text!)
        serviceZip.callService([:], successBlock: { (result:NSDictionary) -> Void in
            
            self.resultDict = result
            self.neighborhoods = []
            self.stores = []
            
            self.neighborhoodsDic = result["neighborhoods"] as! [NSDictionary]
            var index = 0
            for dic in  self.neighborhoodsDic {
                
                self.neighborhoods.append(dic["name"] as! String!)
                let idNeighborhood = dic["id"] as! String!
                if neighborhoodID == idNeighborhood {
                    self.suburb!.text = self.neighborhoods[index]
                    self.selectedNeighborhood = NSIndexPath(forRow: index, inSection: 0)
                }
                if neighborhoodID == "" {
                    self.suburb!.text = self.neighborhoods[0]
                    self.selectedNeighborhood = NSIndexPath(forRow: 0, inSection: 0)
                }
                index += 1
            }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
            
            self.storesDic = result["stores"] as! [NSDictionary]
            for dic in  self.storesDic {
                let name = dic["name"] as! String!
                let cost = dic["cost"] as! String!
                
                self.stores.append("\(name) - \(cost)")
                
                let idStore = dic["id"] as! String!
                if idStore == storeID {
                    self.store!.text = self.stores[self.stores.count - 1]
                    self.selectedStore = NSIndexPath(forRow: self.stores.count - 1, inSection: 0)
                    self.currentZipCode = self.zipcode.text!
                }
                if storeID == "" {
                    self.store!.text = self.stores[0]
                    self.selectedStore = NSIndexPath(forRow: 0, inSection: 0)
                }
                
            }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
            
            
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
                self.viewError(formField)
            }
        }
    }
    
    func viewReplaceContent(frame:CGRect) -> UIView! {
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
    
    func showErrorLabel(show: Bool)
    {
        self.errorLabelStore!.hidden = !show
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let fieldString = strNSString.stringByReplacingCharactersInRange(range, withString: string)
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
        if textField == self.phoneHomeNumber{
            if fieldString.characters.count == 11{
                return false
            }else{
                self.delegateFormAdd?.showUpdate()
            }
        }
        return true
    }
}