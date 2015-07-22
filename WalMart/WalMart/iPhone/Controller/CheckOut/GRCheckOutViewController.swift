//
//  GRCheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/22/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, UIPickerViewDelegate,AlertPickerViewDelegate,OrderConfirmDetailViewDelegate {
    
    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var errorView : FormFieldErrorView? = nil
    
    var paymentOptions: FormFieldView?
    var address: FormFieldView?
    var shipmentType: FormFieldView?
    var deliveryDate: FormFieldView?
    var comments: FormFieldView?
    var confirmation: FormFieldView?
    var deliverySchedule: FormFieldView?

    var paymentOptionsPicker: UIPickerView?
    var addressPicker: UIPickerView?
    var shipmentTypePicker: UIPickerView?
    var deliveryDatePicker: UIDatePicker?
    var confirmationPicker: UIPickerView?
    
    var paymentOptionsItems: [AnyObject]?
    var addressItems: [AnyObject]?
    var shipmentItems: [AnyObject]?
    var slotsItems: [AnyObject]?
    var orderOptionsItems: [AnyObject]?

    var totalItems: String?
    var selectedAddress: String? = nil
    
    var resume: UIView?
    var numOfArtLabel: UILabel?
    var subTotalLabel: UILabel?
    var subTotalPriceLabel: CurrencyCustomLabel?
    var totalLabel: UILabel?
    var totalPriceLabel: CurrencyCustomLabel?
    
    var footer: UIView?
    var buttonShop: UIButton?
    
    var dateFmt: NSDateFormatter?
    
    var selectedPaymentType : NSIndexPath!
    var selectedAddressIx : NSIndexPath!
    var selectedShipmentTypeIx : NSIndexPath!
    var selectedTimeSlotTypeIx : NSIndexPath!
    var selectedConfirmation : NSIndexPath!
    var selectedDate : NSDate!
    
    var scrollForm : TPKeyboardAvoidingScrollView!
    
    var picker : AlertPickerView!
    
    var sAddredssForm : FormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    
    var customlabel : CurrencyCustomLabel!
    var serviceDetail : OrderConfirmDetailView? = nil
    
    var totalView : IPOCheckOutTotalView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.invokePaymentService()
        //self.invokeAddressUserService()
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        self.titleLabel?.text = NSLocalizedString("checkout.gr.title", comment:"")
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)

        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44),
            inputViewStyle: .Keyboard,
            titleSave: "Ok",
            save: { (field:UITextField?) -> Void in
                field?.resignFirstResponder()
                if field != nil {
                    if field!.text == nil || field!.text.isEmpty {
                        if field === self.deliveryDate {
                            self.dateChanged()
                        }
                    }
                }
        })
        
        var margin: CGFloat = 15.0
        var width = self.view.frame.width - (2*margin)
        var fheight: CGFloat = 44.0
        var lheight: CGFloat = 25.0
        
        //Opciones de Pago
        var sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.paymentOptions", comment:""), frame: CGRectMake(margin, 20.0, width, lheight))
        self.content.addSubview(sectionTitle)
        
        self.paymentOptions = FormFieldView(frame: CGRectMake(margin, sectionTitle.frame.maxY + 10.0, width, fheight))
        self.paymentOptions!.setPlaceholder(NSLocalizedString("checkout.field.paymentOptions", comment:""))
        self.paymentOptions!.isRequired = true
        self.paymentOptions!.typeField = TypeField.List
        self.paymentOptions!.setImageTypeField()
        self.paymentOptions!.nameField = NSLocalizedString("checkout.field.paymentOptions", comment:"")
        self.content.addSubview(self.paymentOptions!)
        
        sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.shipmentOptions", comment:""), frame: CGRectMake(margin, self.paymentOptions!.frame.maxY + 20.0, width, lheight))
        self.content.addSubview(sectionTitle)

        self.address = FormFieldView(frame: CGRectMake(margin, sectionTitle.frame.maxY + 10.0, width, fheight))
        self.address!.setPlaceholder(NSLocalizedString("checkout.field.address", comment:""))
        self.address!.isRequired = true
        self.address!.typeField = TypeField.List
        self.address!.setImageTypeField()
        self.address!.nameField = NSLocalizedString("checkout.field.address", comment:"")
        self.content.addSubview(self.address!)

        self.shipmentType = FormFieldView(frame: CGRectMake(margin, self.address!.frame.maxY + 5.0, width, fheight))
        self.shipmentType!.setPlaceholder(NSLocalizedString("checkout.field.shipmentType", comment:""))
        self.shipmentType!.isRequired = true
        self.shipmentType!.typeField = TypeField.List
        self.shipmentType!.setImageTypeField()
        self.shipmentType!.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
        self.content.addSubview(self.shipmentType!)


        self.deliveryDate = FormFieldView(frame: CGRectMake(margin, self.shipmentType!.frame.maxY + 5.0, width, fheight))
        self.deliveryDate!.setPlaceholder(NSLocalizedString("checkout.field.deliveryDate", comment:""))
        self.deliveryDate!.isRequired = true
        self.deliveryDate!.typeField = TypeField.List
        self.deliveryDate!.setImageTypeField()
        self.deliveryDate!.nameField = NSLocalizedString("checkout.field.deliveryDate", comment:"")
        self.deliveryDate!.inputAccessoryView = viewAccess
        self.deliveryDate!.disablePaste = true
        self.content.addSubview(self.deliveryDate!)
        
        self.deliveryDatePicker = UIDatePicker()
        self.deliveryDatePicker!.datePickerMode = .Date
        self.deliveryDatePicker!.date = NSDate()
        
         var SECS_IN_DAY:NSTimeInterval = 60 * 60 * 24
         var maxDate =  NSDate()
         maxDate = maxDate.dateByAddingTimeInterval(SECS_IN_DAY * 6.0)
        
        self.deliveryDatePicker!.minimumDate = NSDate()
        self.deliveryDatePicker!.maximumDate = maxDate
        
        
        self.deliveryDatePicker!.addTarget(self, action: "dateChanged", forControlEvents: .ValueChanged)
        self.deliveryDate!.inputView = self.deliveryDatePicker!
        
        self.deliverySchedule = FormFieldView(frame: CGRectMake(margin, self.deliveryDate!.frame.maxY + 5.0, width, fheight))
        self.deliverySchedule!.setPlaceholder(NSLocalizedString("checkout.field.deliverySchedule", comment:""))
        self.deliverySchedule!.isRequired = true
        self.deliverySchedule!.typeField = TypeField.List
        self.deliverySchedule!.setImageTypeField()
        self.deliverySchedule!.nameField = NSLocalizedString("checkout.field.deliverySchedule", comment:"")
        self.content.addSubview(self.deliverySchedule!)

        self.comments = FormFieldView(frame: CGRectMake(margin, self.deliverySchedule!.frame.maxY + 5.0, width, fheight))
        self.comments!.setPlaceholder(NSLocalizedString("checkout.field.comments", comment:""))
        self.comments!.isRequired = true
        self.comments!.typeField = TypeField.String
        self.comments!.nameField = NSLocalizedString("checkout.field.comments", comment:"")
        self.comments!.inputAccessoryView = viewAccess
        self.comments!.maxLength = 100
        self.content.addSubview(self.comments!)
        self.comments!.inputAccessoryView = viewAccess

        sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.confirmation", comment:""), frame: CGRectMake(margin, self.comments!.frame.maxY + 20.0, width, lheight))
        self.content.addSubview(sectionTitle)

        self.confirmation = FormFieldView(frame: CGRectMake(margin, sectionTitle.frame.maxY + 10.0, width, fheight))
        self.confirmation!.setPlaceholder(NSLocalizedString("checkout.field.confirmation", comment:""))
        self.confirmation!.isRequired = true
        self.confirmation!.typeField = TypeField.List
        self.confirmation!.setImageTypeField()
        self.confirmation!.nameField = NSLocalizedString("checkout.field.confirmation", comment:"")
        
        self.content.addSubview(self.confirmation!)

        self.buildFooterView()
        
        totalView = IPOCheckOutTotalView(frame:CGRectMake(0, self.confirmation!.frame.maxY + 10, self.view.frame.width, 60))
        
        totalView.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
            subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
            saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
        
        self.content.addSubview(totalView)
        self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR())")
        
        self.content.contentSize = CGSizeMake(self.view.frame.width, totalView.frame.maxY + 20.0)
        
        
        picker = AlertPickerView.initPickerWithDefault()
        
        self.addViewLoad();
        
        self.invokePaymentService { () -> Void in
            self.paymentOptions!.onBecomeFirstResponder = {() in
                if self.paymentOptionsItems != nil && self.paymentOptionsItems!.count > 0 {
                    var itemsPayments : [String] = []
                    for option in self.paymentOptionsItems! {
                        if let text = option["paymentType"] as? String {
                            itemsPayments.append(text)
                        }
                    }
                    
                    
                    self.picker!.selected = self.selectedPaymentType
                    self.picker!.sender = self.paymentOptions!
                    self.picker!.delegate = self
                    self.picker!.setValues(self.paymentOptions!.nameField, values: itemsPayments)
                    self.picker!.hiddenRigthActionButton(true)
                    self.picker!.showPicker()
                    
                    self.removeViewLoad()
                    
                }
            }
            
            
            self.reloadUserAddresses()
        
        }
        
        //Fill orders
        self.orderOptionsItems = self.optionsConfirmOrder()
        
        if  self.orderOptionsItems?.count > 0 {
            self.selectedConfirmation  = NSIndexPath(forRow: 0, inSection: 0)
            let first = self.orderOptionsItems![0] as NSDictionary
            if let text = first["desc"] as? String {
                self.confirmation!.text = text
            }
            
        }
        
        self.confirmation!.onBecomeFirstResponder = {() in
            self.comments?.resignFirstResponder()
            if self.paymentOptionsItems != nil && self.paymentOptionsItems!.count > 0 {
                var itemsOrderOptions : [String] = []
                for option in self.orderOptionsItems! {
                    if let text = option["desc"] as? String {
                        itemsOrderOptions.append(text)
                    }
                }
                
                self.picker!.selected = self.selectedConfirmation
                self.picker!.sender = self.confirmation!
                self.picker!.delegate = self
                self.picker!.setValues(self.confirmation!.nameField, values: itemsOrderOptions)
                self.picker!.hiddenRigthActionButton(true)
                self.picker!.showPicker()
                
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.frame.size
        var resumeHeight:CGFloat = 75.0
        var footerHeight:CGFloat = 60.0
        
        self.totalView.frame = CGRectMake(0, self.confirmation!.frame.maxY + 10, self.view.frame.width, 60)
//        self.content!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - (self.header!.frame.height + footerHeight))
//        self.content.contentSize = CGSizeMake(self.view.frame.width, totalView.frame.maxY + 20.0)
//        
        
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        
    
        self.footer!.frame = CGRectMake(0.0, self.view.frame.height - footerHeight, bounds.width, footerHeight)
        self.buttonShop!.frame = CGRectMake(16, (footerHeight / 2) - 17, bounds.width - 32, 34)
        
        var margin: CGFloat = 15.0
        var widthField = self.view.frame.width - (2*margin)
        var fheight: CGFloat = 44.0
        var lheight: CGFloat = 25.0
        
        self.paymentOptions!.frame = CGRectMake(margin, self.paymentOptions!.frame.minY, widthField, fheight)
        self.address!.frame = CGRectMake(margin, self.address!.frame.minY, widthField, fheight)
        self.shipmentType!.frame = CGRectMake(margin, self.address!.frame.maxY + 5.0, widthField, fheight)
        self.deliveryDate!.frame = CGRectMake(margin, self.shipmentType!.frame.maxY + 5.0, widthField, fheight)
        self.deliverySchedule!.frame = CGRectMake(margin, self.deliveryDate!.frame.maxY + 5.0, widthField, fheight)
        self.comments!.frame = CGRectMake(margin, self.deliverySchedule!.frame.maxY + 5.0, widthField, fheight)
        self.confirmation!.frame = CGRectMake(margin, self.confirmation!.frame.minY, widthField, fheight)
        
    }
    
    //MARK: - Build Views
    
    func buildFooterView() {
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.footer!)
        
        var bounds = self.view.frame.size
        var footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton.buttonWithType(.Custom) as? UIButton
        self.buttonShop!.frame = CGRectMake(16, (footerHeight / 2) - 17, bounds.width - 32, 34)
        self.buttonShop!.backgroundColor = WMColor.shoppingCartShopBgColor
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: "sendOrder", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonShop!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        self.footer!.addSubview(self.buttonShop!)

    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        var sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.listAddressHeaderSectionColor
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    //MARK: - Field Utils
    
    func paymentOption(atIndex index:Int) -> String {
        if self.paymentOptionsItems != nil && self.paymentOptionsItems!.count > 0 {
            var option = self.paymentOptionsItems![index] as [String:AnyObject]
            if let text = option["paymentType"] as? String {
                return text
            }
        }
        return ""
    }
    
    func addressOption(atIndex index:Int) -> String {
        if self.addressItems != nil && self.addressItems!.count > 0 {
            var option = self.addressItems![index] as [String:AnyObject]
            if let text = option["name"] as? String {
                return text
            }
        }
        return ""
    }
    
    func shipmentOption(atIndex index:Int) -> String {
        if self.shipmentItems != nil && self.shipmentItems!.count > 0 {
            var option = self.shipmentItems![index] as [String:AnyObject]
            if let text = option["name"] as? String {
                return text
            }
        }
        return ""
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
    
    func textFieldDidBeginEditing(sender: UITextField!) {
    }
    
    func textFieldDidEndEditing(sender: UITextField!) {
        
    }
    
     //MARK: - UIDatePicker
    
    func dateChanged() {
        var date = self.deliveryDatePicker!.date
        self.deliveryDate!.text = self.dateFmt!.stringFromDate(date)
        self.selectedDate = date
        buildSlotsPicker(date)
        
    }
    
    func buildSlotsPicker(date:NSDate?) {
        self.addViewLoad()
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
                let selectedSlot = self.slotsItems![0] as NSDictionary
                self.selectedTimeSlotTypeIx = NSIndexPath(forRow: 0, inSection: 0)
                self.deliverySchedule!.text = selectedSlot["displayText"] as NSString
            }
            else {
                self.deliverySchedule!.text = ""
            }
            self.deliverySchedule!.onBecomeFirstResponder = {() in
                var itemsSlots : [String] = []
                for option in self.slotsItems! {
                    if let visible = option["isVisible"] as? NSNumber {
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
                self.picker!.showPicker()
            }
            
            self.removeViewLoad()
            
        })
    }

    //MARK: - Services
    
    func invokePaymentService(endCallPaymentOptions:(() -> Void)) {
        self.addViewLoad()
        
        var service = GRPaymentTypeService()
        service.callService("2",
            successBlock: { (result:NSArray) -> Void in
                self.paymentOptionsItems = result
                if result.count > 0 {
                    let option = result[0] as NSDictionary
                    if let text = option["paymentType"] as? String {
                        self.paymentOptions!.text = text
                        self.selectedPaymentType = NSIndexPath(forRow: 0, inSection: 0)
                    }
                    
                   
                    
                }
                
                self.removeViewLoad()
                
                endCallPaymentOptions()
            },
            errorBlock: { (error:NSError) -> Void in
                println("Error at invoke payment type service")
                self.removeViewLoad()

                endCallPaymentOptions()
            }
        )
    }
    
    func invokeAddressUserService(endCallAddress:(() -> Void)) {
        self.addViewLoad()
        var service = GRAddressByUserService()
        service.callService(
            { (result:NSDictionary) -> Void in
                if let items = result["responseArray"] as? NSArray {
                    self.addressItems = items
                    if items.count > 0 {
                        var ixCurrent = 0
                        for dictDir in items {
                            if let preferred = dictDir["preferred"] as? NSNumber {
                                if self.selectedAddress == nil {
                                    if preferred.boolValue == true {
                                        self.selectedAddressIx = NSIndexPath(forRow: ixCurrent, inSection: 0)
                                        if let nameDict = dictDir["name"] as? String {
                                            self.address?.text =  nameDict
                                        }
                                        if let idDir = dictDir["id"] as? String {
                                            self.selectedAddress = idDir
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                self.removeViewLoad()
                endCallAddress()
            }, errorBlock: { (error:NSError) -> Void in
                
                self.removeViewLoad()
                println("Error at invoke address user service")
                endCallAddress()
            }
        )
    }
    
    
    
    func buildAndConfigureDeliveryType() {
        if self.selectedAddress != nil {
        self.invokeDeliveryTypesService({ () -> Void in
            self.shipmentType!.onBecomeFirstResponder = {() in
                var itemsShipment : [String] = []
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
                self.picker!.showPicker()
            }
            
            self.buildSlotsPicker(self.selectedDate)
        })
        }
    }
    
    func invokeDeliveryTypesService(endCallTypeService:(() -> Void)) {
        self.addViewLoad()
        var service = GRDeliveryTypeService()
        service.setParams("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())", addressId: self.selectedAddress!)
        service.callService(requestParams: [:],
            successBlock: { (result:NSDictionary) -> Void in
                self.shipmentItems = []
                if let fixedDelivery = result["fixedDelivery"] as? String {
                    //self.shipmentType!.text = fixedDelivery
                    self.shipmentItems!.append(["name":fixedDelivery, "key":"3"])
                }
                if let pickUpInStore = result["pickUpInStore"] as? String {
                    self.shipmentItems!.append(["name":pickUpInStore, "key":"4"])
                }
                if let normalDelivery = result["normalDelivery"] as? String {
                    self.shipmentItems!.append(["name":normalDelivery, "key":"1"])
                }
                if let expressDelivery = result["expressDelivery"] as? String {
                    self.shipmentItems!.append(["name":expressDelivery, "key":"2"])
                }
                if self.shipmentItems!.count > 0 {
                    let shipName = self.shipmentItems![0] as NSDictionary
                    self.selectedShipmentTypeIx = NSIndexPath(forRow: 0, inSection: 0)
                    self.shipmentType!.text = shipName["name"] as String
                }
                
                self.removeViewLoad()
                
                endCallTypeService()
            },
            errorBlock: { (error:NSError) -> Void in
                self.removeViewLoad()
                println("Error at invoke delivery type service")
                endCallTypeService()
            }
        )
    }
    
    
    func reloadUserAddresses(){
        self.addViewLoad();

        self.invokeAddressUserService({ () -> Void in
           self.getItemsTOSelectAddres()
            self.address!.onBecomeFirstResponder = {() in
                var itemsAddress : [String] = self.getItemsTOSelectAddres()
                
                self.picker!.selected = self.selectedAddressIx
                self.picker!.sender = self.address!
                self.picker!.delegate = self

                let btnNewAddress = UIButton()
                btnNewAddress.setTitle("Nueva", forState: UIControlState.Normal)
                btnNewAddress.backgroundColor = WMColor.UIColorFromRGB(0x2970ca)
                btnNewAddress.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
                btnNewAddress.layer.cornerRadius = 2.0
                
                self.picker!.addRigthActionButton(btnNewAddress)
                self.picker!.setValues(self.address!.nameField, values: itemsAddress)
                self.picker!.hiddenRigthActionButton(false)
                self.picker!.showPicker()
                
                self.removeViewLoad()
                
            }
            
            var date = NSDate()
            self.selectedDate = date
            self.deliveryDate!.text = self.dateFmt!.stringFromDate(date)
            self.buildAndConfigureDeliveryType()
        })
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
    
    func invokeTimeBandsService(date:String,endCallTypeService:(() -> Void)) {
        var service = GRTimeBands()
        let params = service.buildParams(date, addressId: self.selectedAddress!)
        service.callService(requestParams: params, successBlock: { (result:NSDictionary) -> Void in
               // var date = self.deliveryDatePicker!.date
            
                if let day = result["day"] as? String {
                    if let month = result["month"] as? String {
                        if let year = result["year"] as? String {
                            var dateSlot = "\(day)/\(month)/\(year)"
                            var date = self.parseDateString(dateSlot)
                            self.deliveryDate!.text = self.dateFmt!.stringFromDate(date)
                            self.selectedDate = date
                            self.deliveryDatePicker!.date = date
                        }
                    }
                }
                self.slotsItems = result["slots"] as NSArray
                self.addViewLoad()
                endCallTypeService()
            }) { (error:NSError) -> Void in
                self.removeViewLoad()
                self.slotsItems = []
                endCallTypeService()
        }
        
    }
    
    func parseDateString(dateStr:String, format:String="dd/MM/yyyy") -> NSDate {
        var dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.paymentOptions! {
                self.paymentOptions!.text = selectedStr
                self.selectedPaymentType = indexPath
            }
            if formFieldObj ==  self.address! {
                self.address!.text = selectedStr
                
                var option = self.addressItems![indexPath.row] as [String:AnyObject]
                if let addressId = option["id"] as? String {
                    self.selectedAddress = addressId
                }
                buildAndConfigureDeliveryType()
                self.selectedAddressIx = indexPath
            }
            if formFieldObj ==  self.shipmentType! {
                self.shipmentType!.text = selectedStr
                self.selectedShipmentTypeIx = indexPath
            }
            if formFieldObj ==  self.deliverySchedule! {
                self.deliverySchedule!.text = selectedStr
                self.selectedTimeSlotTypeIx = indexPath
            }
            if formFieldObj ==  self.confirmation! {
                self.confirmation!.text = selectedStr
                self.selectedConfirmation = indexPath

            }
            
            
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {

        if formFieldObj ==  self.paymentOptions! {
            self.paymentOptions!.text = ""
            //self.selectedPaymentType = indexPath
        }
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
        scrollForm.addSubview(sAddredssForm)
        self.picker!.titleLabel.text = NSLocalizedString("checkout.field.new.address", comment:"")
        return scrollForm
    }
    
    func saveReplaceViewSelected() {
        self.addViewLoad()
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary("", delete:false)
        if dictSend != nil {
            
            self.scrollForm.resignFirstResponder()
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                println("Se realizao la direccion")
                self.picker!.closeNew()
                self.picker!.closePicker()
                self.selectedAddress = resultCall["addressID"] as String!
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                }
                self.alertView!.showDoneIcon()
                self.reloadUserAddresses()
                
                }) { (error:NSError) -> Void in
                     self.removeViewLoad()
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            }
        }
    }
    
    func optionsConfirmOrder ()  -> [[String:String]] {
        //GroceriesCheckout descriptions
        
        var result : [[String:String]] = []
        
        let confirmCall = NSLocalizedString("gr.confirmacall", comment: "")
        var dictConfirm = ["name":confirmCall,"desc":confirmCall,"key":"3"]
        result.append(dictConfirm)
        
        let notConfirmCallOptions = NSLocalizedString("gr.not.confirmacall.option", comment: "")
        let notConfirmCallOptionsDetail = NSLocalizedString("gr.not.confirmacall.option.detail", comment: "")
        dictConfirm = ["name":notConfirmCallOptions,"desc":notConfirmCallOptionsDetail,"key":"1"]
        result.append(dictConfirm)

        let notConfirmCall = NSLocalizedString("gr.not.confirmacall", comment: "")
        let notConfirmCallDetail = NSLocalizedString("gr.not.confirmacall.detal", comment: "")
        dictConfirm = ["name":notConfirmCall,"desc":notConfirmCallDetail,"key":"2"]
        result.append(dictConfirm)
        
        return result
        
    }
    
    func updateShopButton(total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop!.bounds)
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop!.addSubview(customlabel)
            buttonShop!.sendSubviewToBack(customlabel)
        }
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
        
    }
    
    
    func sendOrder() {
        
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_CHECKOUT.rawValue,
                action: WMGAIUtils.EVENT_GR_EVENT_CHECKOUT_SENDORDER.rawValue,
                label: "", value: nil).build())
        }

        
       
        
        buttonShop?.enabled = false
        
        if validate() {
            
        
            if selectedTimeSlotTypeIx == nil {
                self.deliverySchedule?.validate()
                buttonShop?.enabled = true
                return
            }
            
            if selectedShipmentTypeIx == nil {
                self.shipmentType?.validate()
                buttonShop?.enabled = true
                return
                
            }
            
            if selectedConfirmation == nil {
                self.confirmation?.validate()
                buttonShop?.enabled = true
                return
                
            }
            
            let serviceCheck = GRSendOrderService()
            
            let total = UserCurrentSession.sharedInstance().estimateTotalGR()
            
            let components : NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit, fromDate: self.selectedDate)
            
            
            let dateMonth = components.month
            let dateYear = components.year
            let dateDay = components.day
            
            let paymentSel = self.paymentOptionsItems![selectedPaymentType.row] as NSDictionary
            let paymentSelectedId = paymentSel["id"] as NSString
            
            let slotSel = self.slotsItems![selectedTimeSlotTypeIx.row]  as NSDictionary
            let slotSelectedId = slotSel["id"] as Int
            
            let shipmentTypeSel = self.shipmentItems![selectedShipmentTypeIx.row] as NSDictionary
            let shipmentType = shipmentTypeSel["key"] as NSString
            
            let confirmTypeSel = self.orderOptionsItems![selectedConfirmation.row] as NSDictionary
            let confirmation = confirmTypeSel["key"] as NSString
            
            serviceDetail = OrderConfirmDetailView.initDetail()
            serviceDetail?.delegate = self
            serviceDetail!.showDetail()
            
            
            let paramsOrder = serviceCheck.buildParams(total, month: "\(dateMonth)", year: "\(dateYear)", day: "\(dateDay)", comments: self.comments!.text, paymentType: (paymentSelectedId), addressID: self.selectedAddress!, device: getDeviceNum(), slotId: slotSelectedId, deliveryType: shipmentType, correlationId: "", hour: self.deliverySchedule!.text, pickingInstruction: confirmation, deliveryTypeString: self.shipmentType!.text, authorizationId: "", paymentTypeString: self.paymentOptions!.text)
            
            serviceCheck.callService(requestParams: paramsOrder, successBlock: { (resultCall:NSDictionary) -> Void in
                
                let purchaseOrderArray = resultCall["purchaseOrder"] as NSArray
                let purchaseOrder = purchaseOrderArray[0] as NSDictionary
                
                let trakingNumber = purchaseOrder["trackingNumber"] as NSString
                let deliveryDate = purchaseOrder["deliveryDate"] as NSString
                let deliveryTypeString = purchaseOrder["deliveryTypeString"] as NSString
                let paymentTypeString = purchaseOrder["paymentTypeString"] as NSString
                let hour = purchaseOrder["hour"] as NSString
                let subTotal = purchaseOrder["subTotal"] as NSNumber
                let total = purchaseOrder["total"] as NSNumber
                
                let formattedSubtotal = CurrencyCustomLabel.formatString(subTotal.stringValue)
                let formattedTotal = CurrencyCustomLabel.formatString(total.stringValue)
                
                let formattedDate = deliveryDate.substringToIndex(10)
                
                
                self.serviceDetail?.completeOrder(trakingNumber, deliveryDate: formattedDate, deliveryHour: hour, paymentType: paymentTypeString, subtotal: formattedSubtotal, total: formattedTotal)
                
                self.buttonShop?.enabled = false
                
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_CHECKOUT.rawValue,
                        action: WMGAIUtils.EVENT_GR_EVENT_CHECKOUT_SENDORDER.rawValue,
                        label: trakingNumber, value: nil).build())
                }

                
                //self.performSegueWithIdentifier("showOrderDetail", sender: self)
                
                }) { (error:NSError) -> Void in
                    
                    if let tracker = GAI.sharedInstance().defaultTracker {
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_CHECKOUT.rawValue,
                            action: WMGAIUtils.EVENT_GR_EVENT_CHECKOUT_CONFIRMORDER.rawValue,
                            label: "", value: nil).build())
                    }
                    
                    
                    self.buttonShop?.enabled = true
                   // println("Error \(error)")
                    
                    if error.code == -400 {
                          self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
                    }
                    else {
                       self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
                    }
                    
                    
            }

        }else {
            buttonShop?.enabled = true
        }
    }
    
    func getDeviceNum() -> String {
        return  "24"
    }
    
    func validate() -> Bool{
        var error = viewError(deliverySchedule!)
        return !error
    }
    
    func viewError(field: FormFieldView)-> Bool{
        var message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(field: FormFieldView,message:String?)-> Bool{
        if message != nil {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: false)
            return true
        }
        return false
    }
    
    func didErrorConfirm() {
        self.dateChanged()
    }
    
    
    func didFinishConfirm() {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView!) {
    }
    
}