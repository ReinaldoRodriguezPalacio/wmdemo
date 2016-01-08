//
//  AddressView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 23/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

@objc protocol AddressViewDelegate {
    func textModify(textField: UITextField!)
    func setContentSize()
    optional func validateZip(isvalidate:Bool)
}

class AddressView: UIView , UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    
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
    var allAddress: NSArray!
    
    var preferedLabel : UILabel? = nil
    var defaultPrefered : Bool = false
    
    var viewAddress: UIView!
    var fieldHeight  : CGFloat = CGFloat(40)
    var leftRightPadding  : CGFloat = CGFloat(15)
    var pickerSuburb : UIPickerView? = nil
    var listSuburb : [NSDictionary] = []
    var titleLabel: UILabel!
    
    var viewLoad : WMLoadingView!
    var delegate:AddressViewDelegate!
    var showSuburb : Bool! = false
    var isLogin : Bool! = false
    var isIpad : Bool! = false
    
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        viewAddress = UIView()
        var width = self.bounds.width
        
        if IS_IPAD {
            width = 1024.0
        }
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
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
            self.delegate.textModify(field)
        })
        
        self.keyboardBar = viewAccess
        shortNameField = FormFieldView()
        self.shortNameField!.isRequired = true
        shortNameField!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname.description",comment:""))
        self.shortNameField!.typeField = TypeField.Alphanumeric
        self.shortNameField!.minLength = 3
        self.shortNameField!.maxLength = 25
        self.shortNameField!.nameField = NSLocalizedString("profile.address.shortName",comment:"")
        
        street = FormFieldView()
        self.street!.isRequired = true
        street!.setCustomPlaceholder(NSLocalizedString("profile.address.street",comment:""))
        self.street!.typeField = TypeField.Alphanumeric
        self.street!.minLength = 2
        self.street!.maxLength = 50
        self.street!.nameField = NSLocalizedString("profile.address.street",comment:"")
        
        outdoornumber = FormFieldView()
        self.outdoornumber!.isRequired = true
        outdoornumber!.setCustomPlaceholder(NSLocalizedString("profile.address.outdoornumber",comment:""))
        self.outdoornumber!.typeField = TypeField.NumAddress
        self.outdoornumber!.minLength = 0
        self.outdoornumber!.maxLength = 15
        self.outdoornumber!.nameField = NSLocalizedString("profile.address.outdoornumber",comment:"")
        
        indoornumber = FormFieldView()
        self.indoornumber!.isRequired = false
        indoornumber!.setCustomPlaceholder(NSLocalizedString("profile.address.indoornumber",comment:""))
        self.indoornumber!.typeField = TypeField.NumAddress
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 15
        self.indoornumber!.nameField = NSLocalizedString("profile.address.indoornumber",comment:"")
        
        zipcode = FormFieldView()
        self.zipcode!.isRequired = true
        zipcode!.setCustomPlaceholder(NSLocalizedString("profile.address.zipcode",comment:""))
        self.zipcode!.typeField = TypeField.Number
        self.zipcode!.minLength = 5
        self.zipcode!.maxLength = 5
        self.zipcode!.nameField = NSLocalizedString("profile.address.zipcode",comment:"")
        zipcode!.delegate = self
        zipcode!.keyboardType = UIKeyboardType.NumberPad
        self.zipcode!.inputAccessoryView = self.keyboardBar
        
        suburb = FormFieldView()
        self.suburb!.isRequired = true
        suburb!.setCustomPlaceholder(NSLocalizedString("profile.address.suburb",comment:""))
        self.suburb!.typeField = TypeField.List
        self.suburb!.nameField = NSLocalizedString("profile.address.suburb",comment:"")
        suburb!.delegate = self
        self.suburb!.inputAccessoryView = self.keyboardBar
        self.suburb!.hidden = true
        
        municipality = FormFieldView()
        self.municipality!.isRequired = true
        municipality!.setCustomPlaceholder(NSLocalizedString("profile.address.municipality",comment:""))
        self.municipality!.typeField = TypeField.None
        self.municipality!.nameField = NSLocalizedString("profile.address.municipality",comment:"")
        self.municipality!.enabled = false
        self.municipality!.hidden = true
        
        city = FormFieldView()
        self.city!.isRequired = true
        city!.setCustomPlaceholder(NSLocalizedString("profile.address.city",comment:""))
        self.city!.typeField = TypeField.None
        self.city!.nameField = NSLocalizedString("profile.address.city",comment:"")
        self.city!.enabled = false
        self.city!.hidden = true
        
        state = FormFieldView()
        self.state!.isRequired = true
        state!.setCustomPlaceholder(NSLocalizedString("profile.address.state",comment:""))
        self.state!.typeField = TypeField.None
        self.state!.nameField = NSLocalizedString("profile.address.state",comment:"")
        self.state!.enabled = false
        self.state!.hidden = true
        
        preferedLabel = UILabel()
        
        self.titleLabel = UILabel()
        
        self.titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabel!.text =  NSLocalizedString("profile.address", comment: "")
        if !isLogin {
            self.titleLabel!.textColor = WMColor.listAddressHeaderSectionColor
            self.titleLabel!.backgroundColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.whiteColor()
        }else {
            self.backgroundColor = UIColor.clearColor()
            self.titleLabel.backgroundColor = UIColor.clearColor()
            self.titleLabel.textColor = UIColor.whiteColor()
        }
        
        /*self.lineView = UIView()
        self.lineView!.backgroundColor = WMColor.loginProfileLineColor*/
        
        self.addSubview(viewAddress!)
        
        self.preferedLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.preferedLabel!.textColor = WMColor.addressPreferedTextColor
        self.preferedLabel!.textAlignment = .Right
        
        self.telephone = FormFieldView()
        self.telephone!.isRequired = true
        self.telephone!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone",comment:""))
        self.telephone!.typeField = TypeField.Number
        self.telephone!.nameField = NSLocalizedString("profile.address.telephone",comment:"")
        self.telephone!.minLength = 10
        self.telephone!.maxLength = 10
        self.telephone!.keyboardType = UIKeyboardType.NumberPad
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
        
        pickerSuburb = UIPickerView(frame: CGRectZero)
        pickerSuburb!.delegate = self
        pickerSuburb!.dataSource = self
        pickerSuburb!.showsSelectionIndicator = true
        suburb!.inputView = pickerSuburb!
        
        self.viewAddress!.backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        
        self.preferedLabel?.frame = CGRectMake(self.bounds.width - 80 ,  0, 80 - leftRightPadding , fieldHeight)
        self.titleLabel?.frame = CGRectMake(leftRightPadding,  0, self.bounds.width - (leftRightPadding*2) - 60 , fieldHeight)
        
        self.shortNameField?.frame = CGRectMake(leftRightPadding,  self.titleLabel!.frame.maxY, self.bounds.width - (leftRightPadding*2), fieldHeight)
        self.street?.frame = CGRectMake(leftRightPadding, self.shortNameField!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.outdoornumber?.frame = CGRectMake(leftRightPadding,  street!.frame.maxY + 8, (self.shortNameField!.frame.width / 2) - 5 , fieldHeight)
        self.indoornumber?.frame = CGRectMake(self.outdoornumber!.frame.maxX + 10 , self.outdoornumber!.frame.minY,   self.outdoornumber!.frame.width  , fieldHeight)
        self.zipcode?.frame = CGRectMake(leftRightPadding,  outdoornumber!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.suburb?.frame = CGRectMake(leftRightPadding,  zipcode!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.suburb!.setImageTypeField()
        self.municipality?.frame = CGRectMake(leftRightPadding,  suburb!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.city?.frame = CGRectMake(leftRightPadding,  municipality!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.state?.frame = CGRectMake(leftRightPadding,  city!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        
        
        self.viewAddress.frame = CGRectMake(0,0, self.bounds.width, showSuburb == true ? self.state!.frame.maxY : self.zipcode!.frame.maxY )
        
    }
    
    func setItemWithDictionary(itemValues: NSDictionary) {
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
    
    func textFieldDidEndEditing(textField: UITextField) {
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
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        
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
    
    func callServiceZip(zipCodeUsr: String, showError:Bool){
        
        let zipCode = zipCodeUsr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if zipCode.characters.count==0 {
            return
        }
        var padding : String = ""
        if zipCode.characters.count < 5 {
            padding =  padding.stringByPaddingToLength( 5 - zipCode.characters.count , withString: "0", startingAtIndex: 0)
        }
        
        if (padding + zipCode ==  "00000") {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "No Válido" , errorView:self.errorView! , becomeFirstResponder: true)
            
            return
        }
        
        if viewLoad == nil{
            viewLoad = WMLoadingView(frame: CGRectMake(0, 46, self.superview!.frame.width, self.superview!.frame.height - 46))
            viewLoad.backgroundColor = UIColor.whiteColor()
        }
        
        
        let service = ZipCodeService()
        //self.addSubview(viewLoad)
        self.superview?.addSubview(viewLoad)
        viewLoad.startAnnimating(false)
        
        
        service.buildParams(padding + zipCode)
        service.callService(NSDictionary(),  successBlock:{ (resultCall:NSDictionary?) in
            self.viewLoad.stopAnnimating()
            if let city = resultCall!["city"] as? String {
                self.city!.text = city
                self.municipality!.text = resultCall!["county"] as? String
                self.state!.text = resultCall!["state"] as? String
                self.zipcode!.text = resultCall!["zipCode"] as? String
                var setElement = false
                if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                    for dic in  resultCall!["neighborhoods"] as! [NSDictionary]{
                        if dic["id"] as? String ==  self.idSuburb{
                            self.suburb!.text = dic["name"] as? String
                            setElement = true
                            break
                        }// if dic["id"] as? String ==  self.idSuburb{
                    }//for dic in  resultCall!["neighborhoods"] as [NSDictionary]{
                }//if self.suburb!.text == "" &&  self.idSuburb != nil &&  self.listSuburb.count == 0  {
                self.listSuburb = resultCall!["neighborhoods"] as! [NSDictionary]
                self.validateShowField()
                if !setElement && self.listSuburb.count > 0  {
                    self.suburb?.becomeFirstResponder()
                    self.suburb!.text = self.listSuburb[0].objectForKey("name") as? String
                    self.idSuburb = self.listSuburb[0].objectForKey("id") as? String
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
                    let stringToShow : NSString = error.localizedDescription
                    let withoutName = stringToShow.stringByReplacingOccurrencesOfString(self.zipcode!.nameField, withString: "")
                    SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: true )
                }
                else{
                    self.zipcode?.resignFirstResponder()
                }
        })
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listSuburb.count
    }
    
    func validateShowField() {
        if self.listSuburb.count > 0{
            if !showSuburb {
                self.viewAddress.frame = CGRectMake(0,0, self.bounds.width,self.state!.frame.maxY)
                self.suburb!.hidden = false
                self.municipality!.hidden = false
                self.city!.hidden = false
                self.state!.hidden = false
                showSuburb = true
                delegate.validateZip!(true)
                delegate.setContentSize()
            }
        } else {
            if showSuburb == true {
                self.viewAddress.frame = CGRectMake(0,0, self.bounds.width,self.zipcode!.frame.maxY)
                self.suburb!.hidden = true
                self.municipality!.hidden = true
                self.city!.hidden = true
                self.state!.hidden = true
                showSuburb = false
                delegate.setContentSize()
            }
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if listSuburb.count > 0 {
            if row == 0 {
                self.idSuburb = listSuburb[row].objectForKey("id") as? String
                suburb!.text = listSuburb[row].objectForKey("name") as? String
            }
            return listSuburb[row].objectForKey("name") as? String
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if listSuburb.count > 0 {
            delegate.textModify(suburb!)
            self.idSuburb = listSuburb[row].objectForKey("id") as? String
            suburb!.text = listSuburb[row].objectForKey("name") as? String
        }
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
                SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: "No Válido" , errorView:self.errorView! ,  becomeFirstResponder: true)
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
            let idItem = item["addressID"] as! NSString
            let name = item["name"] as! NSString
            if id != idItem && name.uppercaseString ==  shortNameField!.text!.uppercaseString {
                self.viewError(shortNameField!, message:NSLocalizedString("profile.address.already.exist", comment: ""))
                return true
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
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        }
        return false
    }
    
    func getParams() -> [String:AnyObject]{
        var paramsAddress : [String : AnyObject] = ["token":"token","city":self.city!.text!,"zipCode":self.zipcode!.text!,"street":self.street!.text!,"innerNumber":self.indoornumber!.text!,"state":self.state!.text! ,"county":self.city!.text! ,"neighborhoodID":self.idSuburb!,"name":self.shortNameField!.text!,"outerNumber":self.outdoornumber!.text! , "preferred": self.defaultPrefered ? 1:0]
        if idAddress != nil{
            paramsAddress.updateValue(self.idAddress!, forKey: "AddressID")
        }
        return paramsAddress
    }
    
}
