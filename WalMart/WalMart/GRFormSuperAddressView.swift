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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.store.setImageTypeField()
        self.suburb.setImageTypeField()
    }
    
    override func setup() {
        super.setup()
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
                        self.showErrorLabel(true)
                    }
                    else
                    {
                        self.showErrorLabel(false)
                    }
                    
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
                        
                        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                        alertView!.setMessage(NSLocalizedString("gr.address.field.notStore",comment:""))
                        alertView!.showDoneIconWithoutClose()
                        alertView!.showOkButton("OK", colorButton: WMColor.green)
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