//
//  AddressView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 23/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

@objc protocol AddressViewDelegate {
    func textModify(_ textField: UITextField!)
    func setContentSize()
    @objc optional func validateZip(_ isvalidate:Bool)
    
    @objc optional func showUpdate()
    @objc optional func showNoCPWarning()
    
}

class AddressView: UIView, AlertPickerViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{
    
     var errorLabelStore: UILabel!
    
    var item: NSDictionary? = nil
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
    
    var store : FormFieldView!
    var idStoreArray :  [String]! = []
    var idStoreSelected : String? = ""
    
    var allAddress: NSArray!
    
    var preferedLabel : UILabel? = nil
    var defaultPrefered : Bool = false
    
    var viewAddress: UIView!
    var fieldHeight  : CGFloat = CGFloat(40)
    var leftRightPadding  : CGFloat = CGFloat(15)
    
    var neighborhoodsDic : [NSDictionary]! = []
    var storesDic : [NSDictionary]! = []
    var resultDict : NSDictionary! = [:]
    var neighborhoods : [String]! = []
    var stores : [String]! = []
    
    var selectedStore : IndexPath!
    var selectedNeighborhood : IndexPath!
    
    var viewLoad : WMLoadingView!
    var delegate:AddressViewDelegate?
    var showSuburb : Bool! = false
    //var isLogin : Bool! = false
    var isIpad : Bool! = false
    var picker : AlertPickerView!
    var titleLabel: UILabel!
    var currentZipCode = ""
    var typeAddress: TypeAddress = TypeAddress.shiping
    
    let tableHeight: CGFloat = 136.0
    var popupTable: UITableView? = nil
    var popupTableSelected : IndexPath? = nil
    var popupTableItem: FormFieldView? = nil
    var itemsToShow : [String] = []
    var usePopupPicker = true
  
    
    var keyboardBar: FieldInputView? {
        didSet {
        }
    }
    
    init(frame: CGRect, isLogin: Bool, isIpad: Bool, typeAddress: TypeAddress) {
        super.init(frame: frame)
        //self.isLogin! = isLogin
        self.isIpad! = isIpad
        self.typeAddress = typeAddress
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        picker = AlertPickerView.initPickerWithDefault()

        viewAddress = UIView()
        var width = self.bounds.width
        
        if IS_IPAD {
            width = 1024.0
        }
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: width , height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                if field == self.zipcode!{
                    self.callServiceZip(field!.text!, showError: true)
                }else if field == self.suburb{
                    field!.resignFirstResponder()
                }else if field == self.ieps {
                    self.email!.becomeFirstResponder()
                }else {
                    self.shortNameField!.becomeFirstResponder()
                }
                
            }
            self.delegate?.textModify(field)
        })
        
        self.keyboardBar = viewAccess
        shortNameField = FormFieldView()
        self.shortNameField!.isRequired = true
        shortNameField!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname.description",comment:""))
        self.shortNameField!.typeField = TypeField.alphanumeric
        self.shortNameField!.minLength = 3
        self.shortNameField!.maxLength = 25
        self.shortNameField!.nameField = NSLocalizedString("profile.address.shortName",comment:"")
        
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
        self.outdoornumber!.maxLength = 5
        self.outdoornumber!.nameField = NSLocalizedString("profile.address.outdoornumber",comment:"")
        
        indoornumber = FormFieldView()
        self.indoornumber!.isRequired = false
        indoornumber!.setCustomPlaceholder(NSLocalizedString("profile.address.indoornumber",comment:""))
        self.indoornumber!.typeField = TypeField.numAddress
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 5
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
        //suburb!.delegate = self
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
        //if !isLogin {
            self.titleLabel!.textColor = WMColor.light_blue
            self.titleLabel!.backgroundColor = UIColor.white
            self.backgroundColor = UIColor.white
        /*}else {
            self.backgroundColor = UIColor.clearColor()
            self.titleLabel.backgroundColor = UIColor.clearColor()
            self.titleLabel.textColor = UIColor.whiteColor()
        }*/
        
        
        self.addSubview(viewAddress!)
        
        self.preferedLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.preferedLabel!.textColor = WMColor.reg_gray
        self.preferedLabel!.textAlignment = .right
        
        self.telephone = FormFieldView()
        self.telephone!.isRequired = true
        self.telephone!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone",comment:""))
        self.telephone!.typeField = TypeField.number
        self.telephone!.nameField = NSLocalizedString("profile.address.telephone",comment:"")
        self.telephone!.minLength = 10
        self.telephone!.maxLength = 10
        self.telephone!.keyboardType = UIKeyboardType.numberPad
        self.telephone!.delegate = self
        self.telephone!.inputAccessoryView = self.keyboardBar
        
        
        /*self.store = FormFieldView()
        self.store!.isRequired = true
        self.store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        self.store!.typeField = TypeField.List
        self.store!.nameField = NSLocalizedString("gr.address.field.store",comment:"")
        */
 
        store = FormFieldView()
        self.store!.isRequired = true
        store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        self.store!.typeField = TypeField.list
        self.store!.nameField = NSLocalizedString("gr.address.field.store",comment:"")
        //suburb!.delegate = self
        self.store!.inputAccessoryView = self.keyboardBar
        self.store!.isHidden = true
        
        self.errorLabelStore = UILabel()
        self.errorLabelStore!.font = WMFont.fontMyriadProLightOfSize(14)
        self.errorLabelStore!.text =  NSLocalizedString("gr.address.section.errorLabelStore", comment: "")
        self.errorLabelStore!.textColor = UIColor.red
        self.errorLabelStore!.numberOfLines = 3
        self.errorLabelStore!.textAlignment = NSTextAlignment.right
        self.errorLabelStore!.isHidden = true

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
        
        self.itemsToShow = []
        self.popupTable = UITableView(frame: CGRect(x: 0, y: 0,  width: self.store!.frame.width,height: tableHeight))
        self.popupTable!.register(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        self.popupTable!.delegate = self
        self.popupTable!.dataSource = self
        self.popupTable!.isHidden = true
        self.viewAddress!.addSubview(self.popupTable!)
      
        if self.typeAddress == TypeAddress.shiping {
            self.viewAddress!.addSubview(self.store)
            self.viewAddress.addSubview(self.errorLabelStore)
        
            self.store.onBecomeFirstResponder = { () in
                if self.currentZipCode != self.zipcode!.text {
                    
                    self.callServiceZip(self.zipcode!.text!, showError: true)
                
                } else {
                    self.endEditing(true)
                
                    if (self.stores.count > 0){
                        if self.usePopupPicker {
                            self.picker!.selected = self.selectedStore
                            self.picker!.sender = self.store!
                            self.picker!.delegate = self
                            self.picker!.setValues(self.store!.nameField as NSString, values: self.stores)
                            self.picker!.showPicker()
                        }else{
                            self.popupTableSelected = self.selectedStore
                            self.setValues(self.stores)
                            self.store!.imageList?.image = UIImage(named: "fieldListClose")
                            self.addPopupTable(self.store)
                        }
                    }
                }
            
            }
        }
        
        self.suburb!.onBecomeFirstResponder = { () in
            if self.neighborhoods.count > 0 {
                self.endEditing(true)
                if self.usePopupPicker {
                    self.picker!.selected = self.selectedNeighborhood
                    self.picker!.sender = self.suburb!
                    self.picker!.delegate = self
                    self.picker!.setValues(self.suburb!.nameField as NSString, values: self.neighborhoods)
                    self.picker!.showPicker()
                }else{
                    self.endEditing(true)
                    self.popupTableSelected = self.selectedNeighborhood
                    self.setValues(self.neighborhoods)
                    self.suburb!.imageList?.image = UIImage(named: "fieldListClose")
                    self.addPopupTable(self.suburb!)
                }
            }
        }
        
        self.viewAddress!.backgroundColor = UIColor.clear

    }
    
    override func layoutSubviews() {
        
        self.preferedLabel?.frame = CGRect(x: self.bounds.width - 80 ,  y: 0, width: 80 - leftRightPadding , height: fieldHeight)
        self.titleLabel?.frame = CGRect(x: leftRightPadding,  y: 0, width: self.bounds.width - (leftRightPadding*2) - 60 , height: fieldHeight)
        
        self.shortNameField?.frame = CGRect(x: leftRightPadding,  y: self.titleLabel!.frame.maxY, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.street?.frame = CGRect(x: leftRightPadding, y: self.shortNameField!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.outdoornumber?.frame = CGRect(x: leftRightPadding,  y: street!.frame.maxY + 8, width: (self.shortNameField!.frame.width / 2) - 5 , height: fieldHeight)
        self.indoornumber?.frame = CGRect(x: self.outdoornumber!.frame.maxX + 10 , y: self.outdoornumber!.frame.minY,   width: self.outdoornumber!.frame.width  , height: fieldHeight)
        self.zipcode?.frame = CGRect(x: leftRightPadding,  y: outdoornumber!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.suburb?.frame = CGRect(x: leftRightPadding,  y: zipcode!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.suburb!.setImageTypeField()
        self.municipality?.frame = CGRect(x: leftRightPadding,  y: suburb!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.city?.frame = CGRect(x: leftRightPadding,  y: municipality!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.state?.frame = CGRect(x: leftRightPadding,  y: city!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
    
        if self.typeAddress == TypeAddress.shiping {
            self.store.frame = CGRect(x: leftRightPadding, y: self.state!.frame.maxY + 8, width: self.shortNameField!.frame.width , height: fieldHeight)
            self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width, height: showSuburb == true ? self.store!.frame.maxY : self.zipcode!.frame.maxY )
        
        }
        else {
            self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width, height: showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
        }
    }
    
    func setItemWithDictionary(_ itemValues: NSDictionary) {
        self.item = itemValues
        if self.item != nil{
            //TODO:Checar por que las direcciones no traen Id
            if let id = self.item!["addressId"] as! String?{
                idAddress = id
                self.shortNameField!.text  = self.item!["name"] as? String
                self.street!.text = self.item!["street"] as? String
                self.zipcode!.text = self.item!["zipCode"] as? String
                self.outdoornumber!.text = self.item!["outerNumber"] as? String
                self.indoornumber!.text = self.item!["innerNumber"] as? String
                self.idSuburb = self.item!["neighborhoodId"] as? String
                
                self.idStoreSelected = self.item!["storeId"] as? String
                self.municipality!.text = self.item!["county"] as? String
                self.city!.text = self.item!["city"] as? String
                self.state!.text = self.item!["state"] as? String
                if let prefered = self.item!["preferred"] as? NSNumber{
                    if prefered==1{
                        self.preferedLabel!.text = NSLocalizedString("profile.address.prefered",comment:"")
                    }
                }
               // if self.zipcode?.text == zipcode{
                    self.callServiceZip(self.zipcode!.text!, showError: true)
                //}
                //textFieldDidEndEditing(self.zipcode!)
            }
        }
    }
    
    /*func textFieldDidEndEditing(textField: UITextField) {
        if textField == zipcode{
            self.callServiceZip(textField.text!, showError: true)
        }
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
            }
        }
    }*/
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let keyword = strNSString.replacingCharacters(in: range, with: string)
        
        if self.delegate != nil{
            self.delegate!.textModify(textField)
        }
        if textField == self.telephone{
            if keyword.characters.count == 10{
                textField.text = keyword
                self.shortNameField?.becomeFirstResponder()
                return false
            }
            else  if keyword.characters.count > 10 {
                return false
            }
            else {
                return true
            }
        }
        if textField == zipcode{
             self.errorView?.removeFromSuperview()
             self.errorView = nil
            
            if Int(keyword) == nil && keyword != "" {
                return false
            }
            if keyword.characters.count == 5{
                self.callServiceZip(keyword, showError:true)
            }
            else if keyword.characters.count > 5 {
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
        
        
        let service = GRZipCodeService()
        //self.addSubview(viewLoad)
        self.superview?.addSubview(viewLoad)
        viewLoad.startAnnimating(false)
        
        
        
        service.callService(service.buildParams(padding + zipCode),  successBlock:{ (resultCall:NSDictionary?) in
            self.viewLoad.stopAnnimating()
            if let city = resultCall!["city"] as? String {
                self.city!.text = city
                self.municipality!.text = resultCall!["county"] as? String
                self.state!.text = resultCall!["state"] as? String
                self.zipcode!.text = resultCall!["zipCode"] as? String
                var setElement = false
                self.currentZipCode = self.zipcode!.text!
                
                if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.neighborhoodsDic.count == 0  {
                    for dic in  resultCall!["neighbourhoods"] as! [NSDictionary]{
                        if dic["neighbourhoodId"] as? String ==  self.idSuburb{
                            self.suburb!.text = dic["neighbourhoodName"] as? String
                            self.city!.isHidden = true
                            setElement = true
                        }// if dic["id"] as? String ==  self.idSuburb{
                    }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
                }//if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                
                self.neighborhoodsDic = resultCall!["neighbourhoods"] as! [NSDictionary]
                self.neighborhoods =  []
                var index = 0

                for dic in  resultCall!["neighbourhoods"] as! [NSDictionary]{
                    self.neighborhoods.append(dic["neighbourhoodName"] as! String!)
                    if dic["neighbourhoodId"] as? String ==  self.idSuburb{
                        self.selectedNeighborhood = IndexPath(row: index, section: 0)
                    }
                    index += 1
                }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
                
                self.storesDic = resultCall!["stores"] as! [NSDictionary]
                for dic in  self.storesDic {
                    let name = dic["storeName"] as! String!
                    let cost = dic["cost"] as! String!
                    self.stores.append("\(name) - \(cost)")
                    self.idStoreArray.append(dic["storeId"] as! String!)
                    
                    if dic["storeId"] as? String ==  self.idStoreSelected{
                        self.store!.text = "\(name) - \(cost)"
                        self.selectedStore = IndexPath(row: self.stores.count - 1, section: 0)
                        //self.currentZipCode = self.zipcode.text!
                    }
                }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
                
                
                self.validateShowField()
                if !setElement && self.neighborhoodsDic.count > 0  {
                    self.selectedNeighborhood = IndexPath(row: 0, section: 0)
                    self.suburb?.becomeFirstResponder()
                    self.suburb!.text = self.neighborhoodsDic[0].object(forKey: "neighbourhoodName") as? String
                    self.idSuburb = self.neighborhoodsDic[0].object(forKey: "neighbourhoodId") as? String
                }//if setElement && self.listSuburb.count > 0  {
                
                if !setElement && self.storesDic.count > 0  {
                    self.selectedStore = IndexPath(row: 0, section: 0)
                    let name = self.storesDic[0].object(forKey: "storeName") as! String!
                    let cost = self.storesDic[0].object(forKey: "cost") as! String!
                    self.store!.text = "\(name) - \(cost)"
                    self.idStoreSelected = self.storesDic[0].object(forKey: "storeId") as! String!
                }//if setElement && self.listSuburb.count > 0  {
                
                
              //  self.pickerSuburb!.reloadAllComponents()
            }
            }, errorBlock: {(error: NSError) in
                self.neighborhoodsDic = []
               // self.pickerSuburb!.reloadAllComponents()
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
                    self.zipcode?.resignFirstResponder()
                }
        })
    }
    
   
    
    func validateShowField() {
        if self.neighborhoodsDic.count > 0{
            if !showSuburb {
                self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width,height: self.state!.frame.maxY)
                self.suburb!.isHidden = false
                self.municipality!.isHidden = false
                self.city!.isHidden = false
                self.state!.isHidden = false
                self.store!.isHidden = false
                showSuburb = true
                delegate?.validateZip?(true)
                delegate?.setContentSize()
            }
        } else {
            if showSuburb == true {
                self.viewAddress.frame = CGRect(x: 0,y: 0, width: self.bounds.width,height: self.zipcode!.frame.maxY)
                self.suburb!.isHidden = true
                self.municipality!.isHidden = true
                self.city!.isHidden = true
                self.state!.isHidden = true
                self.store!.isHidden = true
                showSuburb = false
                delegate?.setContentSize()
            }
        }
        
    }
    
    func showErrorLabel(_ show: Bool)
    {
        self.errorLabelStore!.isHidden = !show
    }

    
   
    
    func validateAddress() -> Bool{
        var error = viewError(shortNameField!)
        if !error{
            error = validateShortName()
        }
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
            error = viewError(zipcode!)
            let message = zipcode!.validate()
            if message != nil {
                error = viewError(zipcode!,message:message)
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
    
    func validateShortName()-> Bool {
        let id = self.idAddress == nil ? "-1" : self.idAddress!
        for item in  self.allAddress as! [NSDictionary]{
            let idItem = item["addressId"] as? NSString
            let name = item["name"] as! NSString
            if idItem != nil && id != idItem! as String && name.uppercased ==  shortNameField!.text!.uppercased() {
                self.viewError(shortNameField!, message:NSLocalizedString("profile.address.already.exist", comment: ""))
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
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        }
        return false
    }
    
    func getParams() -> NSDictionary {//"profileId":UserCurrentSession.sharedInstance.userSigned!.idUser,
           let paramsAdd : NSMutableDictionary? = [:]
        let paramsAddress = ["city":self.city!.text!,"zipCode":self.zipcode!.text!,"street":self.street!.text!,"innerNumber":self.indoornumber!.text!,"state":self.state!.text! ,"county":self.city!.text! ,"neighborhoodId":self.idSuburb!,"addressName":self.shortNameField!.text!,"outerNumber":self.outdoornumber!.text! , "setAsPreferredAdress": self.defaultPrefered ? "true":"false","storeId":self.idStoreSelected!]
        if idAddress != nil{
           paramsAdd?.addEntries(from: paramsAddress)
            paramsAdd?.addEntries(from: ["addressId":self.idAddress!,"profileId":UserCurrentSession.sharedInstance.userSigned!.idUser])
            return  paramsAdd!
        }
        return paramsAddress as NSDictionary
        
    }
    
    
    //MARK: - AlertPickerView
    func didSelectOption(_ picker:AlertPickerView, indexPath:IndexPath ,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.store! {
                self.store!.text = selectedStr
                self.selectedStore = indexPath
                self.idStoreSelected = self.idStoreArray[(indexPath as NSIndexPath).row]
                /*if delegate != nil {
                    self.delegate.showUpdate!()
                }*/
            }
            if formFieldObj ==  self.suburb! {
                self.suburb!.text = selectedStr
                self.selectedNeighborhood = indexPath
                self.idSuburb = self.neighborhoods[(indexPath as NSIndexPath).row]
                
                /*if delegate != nil {
                    self.delegate.showUpdate!()
                }*/
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
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }
    
    func saveReplaceViewSelected() {
    }

    func buttomViewSelected(_ sender: UIButton) {
        
    }
    
    /**
     Adds a popup view with an options table
     
     - parameter itemView: item which is to be added the popup
     */
    func addPopupTable(_ itemView: FormFieldView){
        if itemView == self.popupTableItem {
            self.popupTable!.isHidden = true
            self.popupTableItem!.imageList?.image = UIImage(named: "fieldListOpen")
            self.popupTableItem = nil
        }else{
            self.popupTable?.frame = CGRect(x: itemView.frame.minX, y: itemView.frame.maxY - 0.1, width: itemView.frame.width, height: tableHeight)
            self.popupTable?.backgroundColor =  WMColor.light_light_gray
            self.popupTableItem = itemView
            self.popupTable!.isHidden = false
        }
    }
    
    //MARK - TableView
    /**
     Reloads the popup view with new options
     
     - parameter values: New options from table
     */
    func setValues(_ values:[String]) {
        self.itemsToShow = values
        popupTable!.reloadData()
    }
    
    //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        self.popupTable!.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelItem") as! SelectItemTableViewCell!
        cell?.textLabel?.text = itemsToShow[(indexPath as NSIndexPath).row]
        self.popupTableSelected = self.popupTableSelected ?? indexPath
        if self.popupTable != nil {
            cell?.setSelected((indexPath as NSIndexPath).row == (self.popupTableSelected! as NSIndexPath).row, animated: true)
            cell?.backgroundColor = WMColor.light_light_gray
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStr = self.itemsToShow[(indexPath as NSIndexPath).row]
        if popupTableItem ==  self.store! {
            self.store!.text = selectedStr
            self.store!.imageList?.image = UIImage(named: "fieldListOpen")
            self.selectedStore = indexPath
        }
        
        if popupTableItem ==  self.suburb! {
            self.suburb!.text = selectedStr
            self.suburb!.imageList?.image = UIImage(named: "fieldListOpen")
            self.selectedNeighborhood = indexPath
        }
        self.popupTable!.isHidden = true
        self.popupTableItem = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let textCell = itemsToShow[(indexPath as NSIndexPath).row]
        return  SelectItemTableViewCell.sizeText(textCell, width: 247.0)
    }

}
