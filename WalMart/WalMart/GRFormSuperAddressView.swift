//
//  GRFormSuperAddressView.swift
//  WalMart
//
//  Created by Alonso Salcido on 05/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRFormSuperAddressView: FormSuperAddressView, UITableViewDataSource, UITableViewDelegate {
    
    let tableHeight: CGFloat = 136.0
    var popupTable: UITableView? = nil
    var itemsToShow : [String] = []
    var popupTableSelected : IndexPath? = nil
    var popupTableItem: FormFieldView? = nil
    var titleLabelStore : UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rightPadding = leftRightPadding * 2
        
        self.titleLabelStore.frame = CGRect(x: leftRightPadding, y: self.zipcode.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
       
        self.suburb.frame = CGRect(x: leftRightPadding, y: self.titleLabelStore.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.store.frame = CGRect(x: leftRightPadding, y: self.suburb.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        
        self.titleLabelBetween.frame = CGRect(x: leftRightPadding, y: self.store.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.betweenFisrt.frame = CGRect(x: leftRightPadding, y: self.titleLabelBetween.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.betweenSecond.frame = CGRect(x: leftRightPadding, y: self.betweenFisrt.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleLabelPhone.frame = CGRect(x: leftRightPadding, y: self.betweenSecond.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.phoneHomeNumber.frame = CGRect(x: leftRightPadding, y: self.titleLabelPhone.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.phoneWorkNumber.frame = CGRect(x: leftRightPadding, y: self.phoneHomeNumber.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.cellPhone.frame = CGRect(x: leftRightPadding, y: self.phoneWorkNumber.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        
        self.store.setImageTypeField()
        self.suburb.setImageTypeField()
    }
    
    override func setup() {
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
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
        self.indoornumber!.typeField = TypeField.innerNumber
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 50
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
        
        self.titleLabelStore = UILabel()
        self.titleLabelStore!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelStore!.text =  NSLocalizedString("gr.address.field.store", comment: "")
        self.titleLabelStore!.textColor = WMColor.light_blue
        
        self.suburb = FormFieldView()
        self.suburb!.isRequired = false
        self.suburb!.setCustomPlaceholder(NSLocalizedString("gr.address.field.suburb",comment:""))
        self.suburb!.typeField = TypeField.list
        self.suburb!.nameField = NSLocalizedString("gr.address.field.suburb",comment:"")
        
        self.store = FormFieldView()
        self.store!.isRequired = true
        self.store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        self.store!.typeField = TypeField.list
        self.store!.nameField = NSLocalizedString("gr.address.field.store",comment:"")
        
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
        self.phoneWorkNumber!.delegate = self
        self.phoneWorkNumber!.disablePaste = true
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
        self.addSubview(self.suburb)
        self.addSubview(self.store)
        self.addSubview(self.titleLabelBetween)
        self.addSubview(self.betweenFisrt)
        self.addSubview(self.betweenSecond)
        self.addSubview(self.titleLabelPhone)
        self.addSubview(self.phoneHomeNumber)
        self.addSubview(self.phoneWorkNumber)
        self.addSubview(self.cellPhone)
        self.addSubview(self.titleLabelStore)
        self.itemsToShow = []
        
        self.popupTable = UITableView(frame: CGRect(x: 0, y: 0,  width: self.store!.frame.width,height: tableHeight))
        self.popupTable!.register(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        self.popupTable!.delegate = self
        self.popupTable!.dataSource = self
        self.popupTable!.isHidden = true
        self.addSubview(self.popupTable!)
        self.store.onBecomeFirstResponder = { () in
            
            if self.currentZipCode != self.zipcode.text {
                self.currentZipCode = self.zipcode.text!
                let zipCode = self.zipcode.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                
                self.neighborhoods = []
                self.suburb!.text = ""
                self.selectedNeighborhood = nil
                
                var padding : String = ""
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
                
                let  colonyService = GetColonyByZipCodeService()
                colonyService.buildParams(padding + zipCode)
                colonyService.callService([:], successBlock: { (result:[String : Any]) in
                    self.stores = []
                    self.store!.text = ""
                    self.selectedStore = nil
                     self.errorLabelStore?.isHidden = true
                    self.errorView?.removeFromSuperview()
                    self.errorView = nil
                    
                    self.resultDict = result
                    self.neighborhoods = []
                    self.stores = []
                    
                    //let zipreturned = result["zipCode"] as! String
                    //self.zipcode.text = zipreturned
                    let neighbor = result["neighborhoods"] as! [[String:Any]]
                    self.neighborhoodsDic = result["neighborhoods"] as! [[String:Any]]
                    if neighbor.count == 1 {
                        if  neighbor[0]["name"] as! String!  == "selectOption" || neighbor[0]["name"] as! String!  == "invalidZipCode"{
                            self.neighborhoodsDic = []
                        }
                    }
                    
                   
                    for dic in  self.neighborhoodsDic {
                        self.neighborhoods.append(dic["name"] as! String!)
                    }
                    
                    self.suburb.onBecomeFirstResponder!()
                    
                    
                    
                }, errorBlock: { (error:NSError) in
                    
                    self.store.text = ""
                    self.suburb.text = ""
                    
                    self.neighborhoods = []
                    self.stores = []
                    
                    self.showErrorLabel(true)
                    if self.errorView == nil{
                        self.errorView = FormFieldErrorView()
                    }
                    let stringToShow : NSString = error.localizedDescription as NSString
                    let withoutName = stringToShow.replacingOccurrences(of: self.zipcode!.nameField, with: "")
                    SignUpViewController.presentMessage(self.zipcode!, nameField:self.zipcode!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: false)
                    
                    return
                    
                })
     
            } else {
                self.endEditing(true)
                
                if (self.stores.count > 0){
                    self.popupTableSelected = self.selectedStore as IndexPath?
                    self.setValues(self.stores)
                    //self.picker!.showPicker()
                    self.store!.imageList?.image = UIImage(named: "fieldListClose")
                    self.addPopupTable(self.store)
                }
            }
        }
        
        self.suburb.onBecomeFirstResponder = { () in
            if self.neighborhoods.count > 0 {
                self.endEditing(true)
                self.popupTableSelected = self.selectedNeighborhood as IndexPath?
                self.setValues(self.neighborhoods)
                //self.picker!.showPicker()
                self.suburb!.imageList?.image = UIImage(named: "fieldListClose")
                self.addPopupTable(self.suburb)
            }
        }

    }
    
    override func loadStoresFromZip(zipcode:String,colony:String,storeID:String){
        self.storesDic = []
        self.stores = []
        
        let storeByZipService =  GetStoreByZipCodeColonyService()
        storeByZipService.buildParams(zipcode, colony:colony)
        storeByZipService.callService([:], successBlock: { (result:[String : Any]) in
            print(result)
            
            self.storesDic = result["stores"] as! [[String:Any]]
            for dic in  self.storesDic {
                let name = dic["name"] as! String!
                let cost = dic["cost"] as! String!
                self.stores.append("\(name!) - \(cost!)")
            }
            if self.stores.count > 0 {
                self.store!.text = self.stores[0]
                self.selectedStore = IndexPath(row: 0, section: 0)
                if  self.errorView?.focusError == self.store {
                    self.errorView?.removeFromSuperview()
                    self.errorView = nil
                }
                self.popupTableSelected = self.selectedStore
                self.setValues(self.stores)
                //self.picker!.showPicker()
                self.store!.imageList?.image = UIImage(named: "fieldListClose")
                self.addPopupTable(self.store)
            }
            
            self.showErrorLabel(self.stores.count == 0)
            
            self.endEditing(true)
            
            if self.errorView != nil {
                if  self.errorView?.focusError == self.zipcode {
                    self.errorView?.removeFromSuperview()
                    self.errorView = nil
                }
            }
            
        
        },errorBlock: { (error:NSError) in
            print(error.localizedDescription)
            self.showErrorLabel(self.stores.count == 0)
            self.storesDic = []
            self.stores = []
            self.store.text = ""
            self.selectedStore = nil
            
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            var stringToShow : NSString = error.localizedDescription as NSString
            if error.code != -1 {
                stringToShow = "Intenta nuevamente."
            }
            let withoutName = stringToShow.replacingOccurrences(of: self.suburb!.nameField, with: "")
            SignUpViewController.presentMessage(self.suburb!, nameField:self.suburb!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: false )

            

        })
    
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
    
    /**
     Removes a popup view with an options table
     
     - parameter itemView: item which is to be added the popup
     */
    func removePopupTable(){
            self.popupTable?.isHidden = true
            self.popupTableItem?.imageList?.image = UIImage(named: "fieldListOpen")
            self.popupTableItem = nil
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        self.popupTable!.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelItem") as! SelectItemTableViewCell!
        cell?.textLabel?.text = itemsToShow[indexPath.row]
        self.popupTableSelected = self.popupTableSelected ?? indexPath
        if self.popupTable != nil {
            cell?.setSelected(indexPath.row == self.popupTableSelected!.row, animated: true)
            cell?.backgroundColor = WMColor.light_light_gray
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStr = self.itemsToShow[indexPath.row]
        if popupTableItem ==  self.store! {
            self.store!.text = selectedStr
            self.store!.imageList?.image = UIImage(named: "fieldListOpen")
            self.selectedStore = indexPath
            if delegateFormAdd != nil {
                self.delegateFormAdd?.showUpdate()
            }
        }
        
        if popupTableItem ==  self.suburb! {
            self.suburb!.text = selectedStr
            self.suburb!.imageList?.image = UIImage(named: "fieldListOpen")
            self.selectedNeighborhood = indexPath
            if delegateFormAdd != nil {
                self.delegateFormAdd?.showUpdate()
            }
            self.loadStoresFromZip(zipcode: self.zipcode!.text! , colony: selectedStr, storeID: "")
        }
         self.popupTable!.isHidden = true
         self.popupTableItem = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let textCell = itemsToShow[indexPath.row]
        return  46
    }
    
   //MARK: textFieldDelegate
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let fieldString = strNSString.replacingCharacters(in: range, with: string)
        if textField == self.zipcode {
            if fieldString.characters.count > 5{
                return false
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
            }
        }
        
        if textField == self.phoneWorkNumber {
            if fieldString.characters.count == 10 {
                return false
            }
        }
        
        return true
    }
    
    func clearView() {
        self.addressName?.text = ""
        self.street?.text = ""
        self.outdoornumber?.text = ""
        self.indoornumber?.text = ""
        self.zipcode?.text = ""
        self.store?.text = ""
        self.suburb?.text = ""
        self.betweenFisrt?.text = ""
        self.betweenSecond?.text = ""
        self.currentZipCode = ""
        self.stores = []
        self.removePopupTable()
        self.errorView?.removeFromSuperview()
        self.errorView = nil
    }
}
