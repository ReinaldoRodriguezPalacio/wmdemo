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
    var popupTableSelected : NSIndexPath? = nil
    var popupTableItem: FormFieldView? = nil
    var titleLabelStore : UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rightPadding = leftRightPadding * 2
        
        self.titleLabelStore.frame = CGRectMake(leftRightPadding, self.zipcode.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.store.frame = CGRectMake(leftRightPadding, self.titleLabelStore.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.suburb.frame = CGRectMake(leftRightPadding, self.store.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.titleLabelBetween.frame = CGRectMake(leftRightPadding, self.suburb.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.betweenFisrt.frame = CGRectMake(leftRightPadding, self.titleLabelBetween.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.betweenSecond.frame = CGRectMake(leftRightPadding, self.betweenFisrt.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.titleLabelPhone.frame = CGRectMake(leftRightPadding, self.betweenSecond.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.phoneHomeNumber.frame = CGRectMake(leftRightPadding, self.titleLabelPhone.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.phoneWorkNumber.frame = CGRectMake(leftRightPadding, self.phoneHomeNumber.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.cellPhone.frame = CGRectMake(leftRightPadding, self.phoneWorkNumber.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        
        self.store.setImageTypeField()
        self.suburb.setImageTypeField()
    }
    
    override func setup() {
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.frame.width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
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
        self.titleLabelAddress!.textColor = WMColor.listAddressHeaderSectionColor
        
        self.errorLabelStore = UILabel()
        self.errorLabelStore!.font = WMFont.fontMyriadProLightOfSize(14)
        self.errorLabelStore!.text =  NSLocalizedString("gr.address.section.errorLabelStore", comment: "")
        self.errorLabelStore!.textColor = UIColor.redColor()
        self.errorLabelStore!.numberOfLines = 3
        self.errorLabelStore!.textAlignment = NSTextAlignment.Right
        self.errorLabelStore!.hidden = true
        
        self.addressName = FormFieldView()
        self.addressName!.setCustomPlaceholder(NSLocalizedString("gr.address.field.shortname",comment:""))
        self.addressName!.isRequired = true
        self.addressName!.typeField = TypeField.Alphanumeric
        self.addressName!.nameField = NSLocalizedString("gr.address.field.shortname",comment:"")
        self.addressName!.minLength = 3
        self.addressName!.maxLength = 25
        
        self.street = FormFieldView()
        self.street!.setCustomPlaceholder(NSLocalizedString("gr.address.field.street",comment:""))
        self.street!.isRequired = true
        self.street!.typeField = TypeField.Alphanumeric
        self.street!.nameField = NSLocalizedString("gr.address.field.street",comment:"")
        self.street!.minLength = 2
        self.street!.maxLength = 50
        
        self.outdoornumber = FormFieldView()
        self.outdoornumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.outdoornumber",comment:""))
        self.outdoornumber!.isRequired = true
        self.outdoornumber!.typeField = TypeField.NumAddress
        self.outdoornumber!.minLength = 1
        self.outdoornumber!.maxLength = 15
        self.outdoornumber!.nameField = NSLocalizedString("gr.address.field.outdoornumber",comment:"")
        
        self.indoornumber = FormFieldView()
        self.indoornumber!.setCustomPlaceholder(NSLocalizedString("gr.address.field.indoornumber",comment:""))
        self.indoornumber!.isRequired = false
        self.indoornumber!.typeField = TypeField.NumAddress
        self.indoornumber!.minLength = 0
        self.indoornumber!.maxLength = 15
        self.indoornumber!.nameField = NSLocalizedString("gr.address.field.indoornumber",comment:"")
        
        
        self.zipcode = FormFieldView()
        self.zipcode!.setCustomPlaceholder(NSLocalizedString("gr.address.field.zipcode",comment:""))
        self.zipcode!.isRequired = true
        self.zipcode!.typeField = TypeField.Number
        self.zipcode!.minLength = 5
        self.zipcode!.maxLength = 5
        self.zipcode!.nameField = NSLocalizedString("gr.address.field.zipcode",comment:"")
        self.zipcode!.keyboardType = UIKeyboardType.NumberPad
        self.zipcode!.inputAccessoryView = viewAccess
        
        self.titleLabelStore = UILabel()
        self.titleLabelStore!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelStore!.text =  NSLocalizedString("gr.address.field.store", comment: "")
        self.titleLabelStore!.textColor = WMColor.listAddressHeaderSectionColor
        
        self.store = FormFieldView()
        self.store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        self.store!.isRequired = true
        self.store!.typeField = TypeField.List
        self.store!.nameField = NSLocalizedString("gr.address.field.store",comment:"")
        
        self.suburb = FormFieldView()
        self.suburb!.setCustomPlaceholder(NSLocalizedString("gr.address.field.suburb",comment:""))
        self.suburb!.isRequired = false
        self.suburb!.typeField = TypeField.List
        self.suburb!.nameField = NSLocalizedString("gr.address.field.suburb",comment:"")
        
        //Add title
        
        self.titleLabelBetween = UILabel()
        self.titleLabelBetween!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelBetween!.text =  NSLocalizedString("gr.address.section.between.title", comment: "")
        self.titleLabelBetween!.textColor = WMColor.listAddressHeaderSectionColor
        
        self.betweenFisrt = FormFieldView()
        self.betweenFisrt!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenFisrt",comment:""))
        self.betweenFisrt!.isRequired = false
        self.betweenFisrt!.typeField = TypeField.Alphanumeric
        self.betweenFisrt!.nameField = NSLocalizedString("gr.address.field.betweenFisrt",comment:"")
        self.betweenFisrt!.minLength = 2
        self.betweenFisrt!.maxLength = 100
        
        self.betweenSecond = FormFieldView()
        self.betweenSecond!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenSecond",comment:""))
        self.betweenSecond!.isRequired = false
        self.betweenSecond!.typeField = TypeField.Alphanumeric
        self.betweenSecond!.nameField = NSLocalizedString("gr.address.field.betweenSecond",comment:"")
        self.betweenSecond!.minLength = 2
        self.betweenSecond!.maxLength = 100
        
        self.titleLabelPhone = UILabel()
        self.titleLabelPhone!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelPhone!.text =  NSLocalizedString("gr.address.section.between.phone", comment: "")
        self.titleLabelPhone!.textColor = WMColor.listAddressHeaderSectionColor
        
        self.phoneHomeNumber = FormFieldView()
        self.phoneHomeNumber!.setCustomPlaceholder(NSLocalizedString("profile.address.field.telephone.house",comment:""))
        self.phoneHomeNumber!.typeField = TypeField.Phone
        self.phoneHomeNumber!.nameField = NSLocalizedString("profile.address.field.telephone.house",comment:"")
        self.phoneHomeNumber!.minLength = 10
        self.phoneHomeNumber!.maxLength = 10
        self.phoneHomeNumber!.keyboardType = UIKeyboardType.NumberPad
        self.phoneHomeNumber!.inputAccessoryView = viewAccess
        
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
        
        
        if UserCurrentSession.sharedInstance().userSigned != nil {
            self.cellPhone!.text = UserCurrentSession.sharedInstance().userSigned!.profile.cellPhone as String
            self.phoneWorkNumber!.text = UserCurrentSession.sharedInstance().userSigned!.profile.phoneWorkNumber as String
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
        self.addSubview(self.titleLabelStore)
        self.itemsToShow = []
        
        self.popupTable = UITableView(frame: CGRectMake(0, 0,  self.store!.frame.width,tableHeight))
        self.popupTable!.registerClass(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        self.popupTable!.delegate = self
        self.popupTable!.dataSource = self
        self.popupTable!.hidden = true
        self.addSubview(self.popupTable!)
        self.store.onBecomeFirstResponder = { () in
            
            if self.currentZipCode != self.zipcode.text {
                self.currentZipCode = self.zipcode.text!
                let zipCode = self.zipcode.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                self.neighborhoods = []
                self.stores = []
                
                self.suburb!.text = ""
                self.selectedNeighborhood = nil
                
                self.store!.text = ""
                self.selectedStore = nil
                
                var padding : String = ""
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
                    }
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
                        self.popupTableSelected = self.selectedStore
                        self.setValues(self.stores)
                        //self.picker!.showPicker()
                        self.store!.imageList?.image = UIImage(named: "fieldListClose")
                        self.addPopupTable(self.store)
                    }
                    
                    self.endEditing(true)
                    
                    if self.errorView != nil {
                        if  self.errorView?.focusError == self.zipcode {
                            self.errorView?.removeFromSuperview()
                            self.errorView = nil
                        }
                    }
                    
                    
                    
                    }, errorBlock: { (error:NSError) -> Void in
                        self.store.text = ""
                        self.suburb.text = ""
                        
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
                        return
                        
                        
                })
            } else {
                self.endEditing(true)
                
                if (self.stores.count > 0){
                    self.popupTableSelected = self.selectedStore
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
                self.popupTableSelected = self.selectedNeighborhood
                self.setValues(self.neighborhoods)
                //self.picker!.showPicker()
                self.suburb!.imageList?.image = UIImage(named: "fieldListClose")
                self.addPopupTable(self.suburb)
            }
        }

    }
    
    func addPopupTable(itemView: FormFieldView){
        if itemView == self.popupTableItem {
           self.popupTable!.hidden = true
           self.popupTableItem!.imageList?.image = UIImage(named: "fieldListOpen")
           self.popupTableItem = nil
        }else{
            self.popupTable?.frame = CGRectMake(itemView.frame.minX, itemView.frame.maxY - 0.1, itemView.frame.width, tableHeight)
            self.popupTable?.backgroundColor =  WMColor.loginFieldBgColor
            self.popupTableItem = itemView
            self.popupTable!.hidden = false
        }
    }
    
    //MARK - TableView
    
    func setValues(values:[String]) {
        self.itemsToShow = values
        popupTable!.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToShow.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        self.popupTable!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSelItem") as! SelectItemTableViewCell!
        cell.textLabel?.text = itemsToShow[indexPath.row]
        if self.popupTable != nil {
            cell.setSelected(indexPath.row == self.popupTableSelected!.row, animated: true)
            cell.backgroundColor = WMColor.loginFieldBgColor
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedStr = self.itemsToShow[indexPath.row]
        if popupTableItem ==  self.store! {
            self.store!.text = selectedStr
            self.store!.imageList?.image = UIImage(named: "fieldListOpen")
            self.selectedStore = indexPath
            if delegateFormAdd != nil {
                self.delegateFormAdd.showUpdate()
            }
        }
        
        if popupTableItem ==  self.suburb! {
            self.suburb!.text = selectedStr
            self.suburb!.imageList?.image = UIImage(named: "fieldListOpen")
            self.selectedNeighborhood = indexPath
            if delegateFormAdd != nil {
                self.delegateFormAdd.showUpdate()
            }
        }
         self.popupTable!.hidden = true
         self.popupTableItem = nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let textCell = itemsToShow[indexPath.row]
        return  SelectItemTableViewCell.sizeText(textCell, width: 247.0)
    }
}