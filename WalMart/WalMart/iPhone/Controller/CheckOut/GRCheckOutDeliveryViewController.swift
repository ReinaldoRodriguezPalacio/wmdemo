//
//  GRCheckOutDeliveryViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import Tune

class GRCheckOutDeliveryViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerViewDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var scrollForm : TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var picker : AlertPickerView!
    var sAddredssForm : FormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    var errorView : FormFieldErrorView? = nil
    var address: FormFieldView?
    var shipmentType: FormFieldView?
    var deliveryDate: FormFieldView?
    var deliverySchedule: FormFieldView?
    var addressItems: [AnyObject]?
    var shipmentItems: [AnyObject]?
    var slotsItems: [AnyObject]?
    var dateFmt: NSDateFormatter?
    var selectedAddress: String? = nil
    var selectedAddressHasStore: Bool = true
    var selectedDate : NSDate!
    var selectedAddressIx : NSIndexPath!
    var selectedShipmentTypeIx : NSIndexPath!
    var selectedTimeSlotTypeIx : NSIndexPath!
    var shipmentAmount: Double!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = "Detalles de Entrega"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 25.0
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "1 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        let sectionTitle = self.buildSectionTitle("Direccion de envio", frame: CGRectMake(margin, 20.0, width, lheight))
        self.content.addSubview(sectionTitle)
        
        self.address = FormFieldView(frame: CGRectMake(margin, sectionTitle.frame.maxY + 10.0, width, fheight))
        self.address!.setCustomPlaceholder(NSLocalizedString("checkout.field.address", comment:""))
        self.address!.isRequired = true
        self.address!.typeField = TypeField.List
        self.address!.setImageTypeField()
        self.address!.nameField = NSLocalizedString("checkout.field.address", comment:"")
        self.content.addSubview(self.address!)
        
        self.shipmentType = FormFieldView(frame: CGRectMake(margin, self.address!.frame.maxY + 5.0, width, fheight))
        self.shipmentType!.setCustomPlaceholder(NSLocalizedString("checkout.field.shipmentType", comment:""))
        self.shipmentType!.isRequired = true
        self.shipmentType!.typeField = TypeField.List
        self.shipmentType!.setImageTypeField()
        self.shipmentType!.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
        self.content.addSubview(self.shipmentType!)
        
        
        self.deliveryDate = FormFieldView(frame: CGRectMake(margin, self.shipmentType!.frame.maxY + 5.0, width, fheight))
        self.deliveryDate!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliveryDate", comment:""))
        self.deliveryDate!.isRequired = true
        self.deliveryDate!.typeField = TypeField.List
        self.deliveryDate!.setImageTypeField()
        self.deliveryDate!.nameField = NSLocalizedString("checkout.field.deliveryDate", comment:"")
        //self.deliveryDate!.inputAccessoryView = viewAccess
        self.deliveryDate!.disablePaste = true
        self.content.addSubview(self.deliveryDate!)
        
//        self.deliveryDatePicker = UIDatePicker()
//        self.deliveryDatePicker!.datePickerMode = .Date
//        self.deliveryDatePicker!.date = NSDate()
//        
//        let SECS_IN_DAY:NSTimeInterval = 60 * 60 * 24
//        var maxDate =  NSDate()
//        maxDate = maxDate.dateByAddingTimeInterval(SECS_IN_DAY * 5.0)
//        
//        self.deliveryDatePicker!.minimumDate = NSDate()
//        self.deliveryDatePicker!.maximumDate = maxDate
//        
//        
//        self.deliveryDatePicker!.addTarget(self, action: "dateChanged", forControlEvents: .ValueChanged)
//        self.deliveryDate!.inputView = self.deliveryDatePicker!
        
        self.deliverySchedule = FormFieldView(frame: CGRectMake(margin, self.deliveryDate!.frame.maxY + 5.0, width, fheight))
        self.deliverySchedule!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliverySchedule", comment:""))
        self.deliverySchedule!.isRequired = true
        self.deliverySchedule!.typeField = TypeField.List
        self.deliverySchedule!.setImageTypeField()
        self.deliverySchedule!.nameField = NSLocalizedString("checkout.field.deliverySchedule", comment:"")
        self.content.addSubview(self.deliverySchedule!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Continuar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.addViewLoad()
        self.reloadUserAddresses()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - 65)
        self.layerLine.frame = CGRectMake(0, self.view.bounds.height - 65,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func showAddressPicker(){
        let itemsAddress : [String] = self.getItemsTOSelectAddres()
        self.picker!.selected = self.selectedAddressIx
        self.picker!.sender = self.address!
        self.picker!.delegate = self
        
        let btnNewAddress = WMRoundButton()
        btnNewAddress.setTitle("nueva", forState: UIControlState.Normal)
        btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        btnNewAddress.setBackgroundColor(WMColor.light_blue, size: CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
        btnNewAddress.layer.cornerRadius = 2.0
        
        self.picker!.addRigthActionButton(btnNewAddress)
        self.picker!.setValues(self.address!.nameField, values: itemsAddress)
        self.picker!.hiddenRigthActionButton(false)
        self.picker!.cellType = TypeField.Check
        if !self.selectedAddressHasStore {
            self.picker!.onClosePicker = {
                //--self.removeViewLoad()
                self.picker!.onClosePicker = nil
                self.navigationController?.popViewControllerAnimated(true)
                self.picker!.closePicker()
            }
        }
        self.picker!.showPicker()
    }
    
    func getItemsTOSelectAddres()  -> [String]{
        var itemsAddress : [String] = []
        var ixSelected = 0
        if self.addressItems != nil {
            for option in self.addressItems! {
                if let text = option["name"] as? String {
                    itemsAddress.append(text)
                    if let id = option["id"] as? String {
                        if id == self.selectedAddress {
                            self.selectedAddressIx = NSIndexPath(forRow: ixSelected, inSection: 0)
                            self.address!.text = text
                        }
                    }
                }
                ixSelected++
            }
        }
        return itemsAddress
    }
    
    func parseDateString(dateStr:String, format:String="dd/MM/yyyy") -> NSDate {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    func next(){
        let nextController = GRCheckOutCommentsViewController()
        self.navigationController?.pushViewController(nextController, animated: true)
    }

    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        if let scroll = sender as? TPKeyboardAvoidingScrollView {
            if scrollForm != nil {
                if scroll == scrollForm {
                    return CGSizeMake(self.scrollForm.frame.width, self.scrollForm.contentSize.height)
                }
            }
        }
        return CGSizeMake(self.view.frame.width, self.content.contentSize.height)
    }
     //MARK: AlertPickerViewDelegate
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            
            if formFieldObj ==  self.address! {
                self.addViewLoad()//--ok
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![indexPath.row] as! [String:AnyObject]
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddress = addressId
                    
                }
                self.selectedAddressIx = indexPath
            }
            if formFieldObj ==  self.shipmentType! {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_OK.rawValue , label: "")
                self.shipmentType!.text = selectedStr
                self.selectedShipmentTypeIx = indexPath
                let shipment: AnyObject = self.shipmentItems![indexPath.row]
                self.shipmentAmount = shipment["cost"] as! Double
            }
            if formFieldObj ==  self.deliverySchedule! {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_TIME_DELIVERY.rawValue , label: "")
                self.deliverySchedule!.text = selectedStr
                self.selectedTimeSlotTypeIx = indexPath
            }
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                self.address!.text = ""
                //var option = self.addressItems![indexPath.row] as [String:AnyObject]
                //if let addressId = option["id"] as? String {
                self.selectedAddress = ""
                //}
                buildAndConfigureDeliveryType()
                //self.selectedAddressIx = indexPath
            }
            if formFieldObj ==  self.shipmentType! {
                self.shipmentType!.text = ""
                // self.selectedShipmentTypeIx = indexPath
            }
            if formFieldObj ==  self.deliverySchedule! {
                self.deliverySchedule!.text = ""
            }
        }
    }
    
    func buttomViewSelected(sender: UIButton) {
        
    }
    
    func viewReplaceContent(frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSizeMake(frame.width, 720)
        sAddredssForm = FormSuperAddressView(frame: CGRectMake(scrollForm.frame.minX, 0, scrollForm.frame.width, 700))
        sAddredssForm.allAddress = self.addressItems
        sAddredssForm.idAddress = ""
        if !self.selectedAddressHasStore{
            let serviceAddress = GRAddressesByIDService()
            serviceAddress.addressId = self.selectedAddress!
            serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
                self.sAddredssForm.addressName.text = result["name"] as! String!
                self.sAddredssForm.outdoornumber.text = result["outerNumber"] as! String!
                self.sAddredssForm.indoornumber.text = result["innerNumber"] as! String!
                self.sAddredssForm.betweenFisrt.text = result["reference1"] as! String!
                self.sAddredssForm.betweenSecond.text = result["reference2"] as! String!
                self.sAddredssForm.zipcode.text = result["zipCode"] as! String!
                self.sAddredssForm.street.text = result["street"] as! String!
                let neighborhoodID = result["neighborhoodID"] as! String!
                let storeID = result["storeID"] as! String!
                self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: neighborhoodID, storeID: storeID)
                self.sAddredssForm.idAddress = result["addressID"] as! String!
                }) { (error:NSError) -> Void in
            }
        }
        
        scrollForm.addSubview(sAddredssForm)
        self.picker!.titleLabel.text = NSLocalizedString("checkout.field.new.address", comment:"")
        return scrollForm
        
        
    }
    
    func saveReplaceViewSelected() {
        self.picker!.onClosePicker = nil
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(sAddredssForm.idAddress, delete: false)
        if dictSend != nil {
            
            self.scrollForm.resignFirstResponder()
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            if self.addressItems?.count < 12 {
                service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                    //--self.addViewLoad()
                    print("Se realizao la direccion")
                    self.picker!.closeNew()
                    self.picker!.closePicker()
                    
                    self.selectedAddress = resultCall["addressID"] as! String!
                    print("saveReplaceViewSelected Address ID \(self.selectedAddress)---")
                    if let message = resultCall["message"] as? String {
                        self.alertView!.setMessage("\(message)")
                    }
                    self.alertView!.showDoneIcon()
                    
                    self.picker!.titleLabel.textAlignment = .Center
                    self.picker!.titleLabel.frame =  CGRectMake(40, self.picker!.titleLabel.frame.origin.y, self.picker!.titleLabel.frame.width, self.picker!.titleLabel.frame.height)
                    self.picker!.isNewAddres =  false
                    self.reloadUserAddresses()
                    
                    }) { (error:NSError) -> Void in
                        self.removeViewLoad()
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.close()
                }
            }
            else{
                self.alertView!.setMessage(NSLocalizedString("profile.address.error.max",comment:""))
                self.alertView!.showErrorIcon("Ok")
            }
        }
    }

    //MARK: Services
    
    func reloadUserAddresses(){
        self.invokeAddressUserService({ () -> Void in
            self.getItemsTOSelectAddres()
            self.address!.onBecomeFirstResponder = {() in
                self.showAddressPicker()
            }
            //TODO
            let date = NSDate()
            self.selectedDate = date
            //self.deliveryDate!.text = self.dateFmt!.stringFromDate(date)
            //self.buildAndConfigureDeliveryType()
            //self.validateMercuryDelivery()
            self.removeViewLoad()
            
        })
    }
    
    func invokeAddressUserService(endCallAddress:(() -> Void)) {
        //--self.addViewLoad()
        let service = GRAddressByUserService()
        service.callService(
            { (result:NSDictionary) -> Void in
                if let items = result["responseArray"] as? NSArray {
                    self.addressItems = items as [AnyObject]
                    if items.count > 0 {
                        let ixCurrent = 0
                        for dictDir in items {
                            if let preferred = dictDir["preferred"] as? NSNumber {
                                if self.selectedAddress == nil {
                                    if preferred.boolValue == true {
                                        self.selectedAddressIx = NSIndexPath(forRow: ixCurrent, inSection: 0)
                                        if let nameDict = dictDir["name"] as? String {
                                            self.address?.text =  nameDict
                                        }
                                        if let idDir = dictDir["id"] as? String {
                                            print("invokeAddressUserService idAdress \(idDir)")
                                            self.selectedAddress = idDir
                                            
                                        }
                                        if let isAddressOK = dictDir["isAddressOk"] as? String {
                                            self.selectedAddressHasStore = !(isAddressOK == "False")
                                            if !self.selectedAddressHasStore{
                                                self.showAddressPicker()
                                                self.picker!.newItemForm()
                                                self.picker!.viewButtonClose.hidden = true
                                                let delay = 0.7 * Double(NSEC_PER_SEC)
                                                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                                dispatch_after(time, dispatch_get_main_queue()) {
                                                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                                                    self.alertView!.setMessage(NSLocalizedString("gr.address.field.addressNotOk",comment:""))
                                                    self.alertView!.showDoneIconWithoutClose()
                                                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //--self.removeViewLoad()
                endCallAddress()
            }, errorBlock: { (error:NSError) -> Void in
                
                self.removeViewLoad()
                print("Error at invoke address user service")
                endCallAddress()
            }
        )
    }
    
    func buildAndConfigureDeliveryType() {
        if self.selectedAddress != nil {
            self.invokeDeliveryTypesService({ () -> Void in
                self.shipmentType!.onBecomeFirstResponder = {() in
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                    var itemsShipment : [String] = []
                    if self.shipmentItems?.count > 1{
                        for option in self.shipmentItems! {
                            if let text = option["name"] as? String {
                                itemsShipment.append(text)
                            }
                        }
                        self.picker!.selected = self.selectedShipmentTypeIx
                        self.picker!.sender = self.shipmentType!
                        self.picker!.delegate = self
                        self.picker!.setValues(self.shipmentType!.nameField, values: itemsShipment)
                        self.picker!.hiddenRigthActionButton(true)
                        self.picker!.cellType = TypeField.Check
                        self.picker!.showPicker()
                    }
                }
                
                self.buildSlotsPicker(self.selectedDate)
            })
        }
    }
    
    func invokeDeliveryTypesService(endCallTypeService:(() -> Void)) {
        //--self.addViewLoad()
        let service = GRDeliveryTypeService()
        //Validar self.selectedAddress != nil
        if self.selectedAddress != nil {
            service.setParams("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())", addressId: self.selectedAddress!,isFreeShiping:"false")
            service.callService(requestParams: [:],
                successBlock: { (result:NSDictionary) -> Void in
                    self.shipmentItems = []
                    if let fixedDelivery = result["fixedDelivery"] as? String {
                        //self.shipmentType!.text = fixedDelivery
                        var fixedDeliveryCostVal = 0.0
                        if let fixedDeliveryCost = result["fixedDeliveryCost"] as? NSString {
                            fixedDeliveryCostVal = fixedDeliveryCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":fixedDelivery, "key":"3","cost":fixedDeliveryCostVal])
                    }
                    
                    
                    if let pickUpInStore = result["pickUpInStore"] as? String {
                        var pickUpInStoreCostVal = 0.0
                        if let pickUpInStoreCost = result["pickUpInStoreCost"] as? NSString {
                            pickUpInStoreCostVal = pickUpInStoreCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":pickUpInStore, "key":"4","cost":pickUpInStoreCostVal])
                    }
                    if let normalDelivery = result["normalDelivery"] as? String {
                        var normalDeliveryCostVal = 0.0
                        if let normalDeliveryCost = result["normalDeliveryCost"] as? NSString {
                            normalDeliveryCostVal = normalDeliveryCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":normalDelivery, "key":"1","cost":normalDeliveryCostVal])
                    }
                    if let expressDelivery = result["expressDelivery"] as? String {
                        var expressDeliveryCostVal = 0.0
                        if let expressDeliveryCost = result["expressDeliveryCost"] as? NSString {
                            expressDeliveryCostVal = expressDeliveryCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":expressDelivery, "key":"2","cost":expressDeliveryCostVal])
                    }
                    
                    
                    if self.shipmentItems!.count > 0 {
                        let shipName = self.shipmentItems![0] as! NSDictionary
                        self.selectedShipmentTypeIx = NSIndexPath(forRow: 0, inSection: 0)
                        self.shipmentType!.text = shipName["name"] as? String
                    }
                    //--self.removeViewLoad()//ok
                    
                    endCallTypeService()
                },
                errorBlock: { (error:NSError) -> Void in
                    self.removeViewLoad()
                    print("Error at invoke delivery type service")
                    endCallTypeService()
                }
            )
        }
    }
    
    func buildSlotsPicker(date:NSDate?) {
        //self.addViewLoad()
        var strDate = ""
        if date != nil {
            let formatService  = NSDateFormatter()
            formatService.dateFormat = "dd/MM/yyyy"
            strDate = formatService.stringFromDate(date!)
        }
        self.invokeTimeBandsService(strDate, endCallTypeService: { () -> Void in
            if  self.slotsItems?.count > 0 {
                if self.errorView != nil {
                    self.errorView!.removeFromSuperview()
                    self.errorView!.focusError = nil
                    self.errorView = nil
                    self.deliverySchedule!.layer.borderColor = self.deliverySchedule!.textBorderOff
                }
                let selectedSlot = self.slotsItems![0] as! NSDictionary
                self.selectedTimeSlotTypeIx = NSIndexPath(forRow: 0, inSection: 0)
                self.deliverySchedule!.text = selectedSlot["displayText"] as? String
            }
            else {
                self.deliverySchedule!.text = ""
            }
            self.deliverySchedule!.onBecomeFirstResponder = {() in
                var itemsSlots : [String] = []
                for option in self.slotsItems! {
                    if let _ = option["isVisible"] as? NSNumber {
                        //if visible.boolValue {
                        if let text = option["displayText"] as? String {
                            itemsSlots.append(text)
                        }
                        //}
                    }
                }
                self.picker!.selected = self.selectedTimeSlotTypeIx
                self.picker!.sender = self.deliverySchedule!
                self.picker!.delegate = self
                self.picker!.setValues(self.deliverySchedule!.nameField, values: itemsSlots)
                self.picker!.hiddenRigthActionButton(true)
                self.picker!.cellType = TypeField.Check
                self.picker!.showPicker()
            }
            self.removeViewLoad()//ok
            
            self.removeViewLoad()//ok
            
        })
    }
    
    func invokeTimeBandsService(date:String,endCallTypeService:(() -> Void)) {
        //if !self.mercury {
            let service = GRTimeBands()
            let params = service.buildParams(date, addressId: self.selectedAddress!)
            service.callService(requestParams: params, successBlock: { (result:NSDictionary) -> Void in
                // var date = self.deliveryDatePicker!.date
                if let day = result["day"] as? String {
                    if let month = result["month"] as? String {
                        if let year = result["year"] as? String {
                            let dateSlot = "\(day)/\(month)/\(year)"
                            let date = self.parseDateString(dateSlot)
                            self.deliveryDate!.text = self.dateFmt!.stringFromDate(date)
                            self.selectedDate = date
                            //self.deliveryDatePicker!.date = date
                        }
                    }
                }
                self.slotsItems = result["slots"] as! NSArray as [AnyObject]
                //--self.addViewLoad()
                endCallTypeService()
                }) { (error:NSError) -> Void in
                    self.removeViewLoad()
                    self.slotsItems = []
                    endCallTypeService()
            }
        /*}else {
            let deliveryService = PostDelivery()
            deliveryService.validateMercurySlots(self.selectedDate, idShopper: "1", idStore: storeID, onSuccess: { (resultSuccess:AnyObject) -> Void in
                let allSlotsCustomObj = resultSuccess["custom"] as! [String:AnyObject]
                let allSlots = allSlotsCustomObj["slots"] as! [AnyObject]
                var allSlotsCustom : [AnyObject] = []
                if allSlots.count > 0 {
                    for slot in allSlots  {
                        if let strtDate = slot["beginDateRange"] as? String {
                            if let endDate = slot["endDateRange"] as? String  {
                                if let idSlot = slot["slotId"] as? Int  {
                                    allSlotsCustom.append(["displayText":"\(strtDate) - \(endDate)","id":idSlot,"isVisible":true])
                                }else {
                                    allSlotsCustom.append(["displayText":"No time","id":0,"isVisible":true])
                                }
                            } else {
                                allSlotsCustom.append(["displayText":"No time","id":0,"isVisible":true])
                            }
                        }else {
                            allSlotsCustom.append(["displayText":"No time","id":0,"isVisible":true])
                        }
                    }
                    self.slotsItems = allSlotsCustom
                    self.addViewLoad()
                    endCallTypeService()
                } else {
                    self.mercury = false
                    self.buildAndConfigureDeliveryType()
                }
                },onError: {(error:NSError) -> Void in
                    self.mercury = false
                    self.buildAndConfigureDeliveryType()
            })
        }*/
    }
}
