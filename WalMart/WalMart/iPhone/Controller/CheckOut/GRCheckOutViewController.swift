//
//  GRCheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/22/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, UIPickerViewDelegate,AlertPickerViewDelegate,OrderConfirmDetailViewDelegate,PayPalPaymentDelegate, PayPalFuturePaymentDelegate {
    
    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var errorView : FormFieldErrorView? = nil
    
    var paymentOptions: FormFieldView?
    var payPalFuturePaymentField: FormFieldView?
    var discountAssociate: FormFieldView?
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
    var selectedAddressHasStore: Bool = true
    
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
    var amountDiscountAssociate: Double!
    var shipmentAmount: Double!
    var savings: Double!
    
    var scrollForm : TPKeyboardAvoidingScrollView!
    
    var picker : AlertPickerView!
    
    var sAddredssForm : FormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    
    var customlabel : CurrencyCustomLabel!
    var serviceDetail : OrderConfirmDetailView? = nil
    
    var totalView : IPOCheckOutTotalView!
    var sectionTitleDiscount : UILabel!
    var sectionTitleShipment : UILabel!
    var sectionTitleConfirm : UILabel!
    
    
    var showDiscountAsociate : Bool = false
    var asociateDiscount : Bool = false
    var discountsFreeShippingAssociated : Bool = false
    var discountsFreeShippingNotAssociated : Bool = false
    var payPalFuturePayment : Bool = false
    var showPayPalFuturePayment : Bool = false
    
    
    var associateNumber : String! = ""
    var dateAdmission : String! = ""
    var determinant : String! = ""
    var confirmOrderDictionary: [String:AnyObject]! = [:]
    var cancelOrderDictionary:  [String:AnyObject]! = [:]
    var completeOrderDictionary: [String:AnyObject]! = [:]
    var promotionIds: String! = ""
    var promotionsDesc: [[String:String]]! = []
    var hasPromotionsButtons: Bool! = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRSHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.invokePaymentService()
        //self.invokeAddressUserService()
        self.selectedAddressHasStore = true
        self.savings = 0.0
        self.amountDiscountAssociate = 0.0
        self.shipmentAmount = 0.0
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat =  "d MMMM yyyy"
        
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
                    if field!.text == nil || field!.text!.isEmpty {
                        if field === self.deliveryDate {
                            self.dateChanged()
                        }
                    }
                }
        })
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 25.0
        
        //Opciones de Pago
        let sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.paymentOptions", comment:""), frame: CGRectMake(margin, 20.0, width, lheight))
        self.content.addSubview(sectionTitle)
        
        self.paymentOptions = FormFieldView(frame: CGRectMake(margin, sectionTitle.frame.maxY + 10.0, width, fheight))
        self.paymentOptions!.setCustomPlaceholder(NSLocalizedString("checkout.field.paymentOptions", comment:""))
        self.paymentOptions!.isRequired = true
        self.paymentOptions!.typeField = TypeField.List
        self.paymentOptions!.setImageTypeField()
        self.paymentOptions!.nameField = NSLocalizedString("checkout.field.paymentOptions", comment:"")
        self.content.addSubview(self.paymentOptions!)
        
        self.payPalFuturePaymentField = FormFieldView(frame: CGRectMake(margin,paymentOptions!.frame.maxY + 10.0,width,fheight))
        self.payPalFuturePaymentField!.setCustomPlaceholder("PayPal pagos futuros")
        self.payPalFuturePaymentField!.isRequired = true
        self.payPalFuturePaymentField!.typeField = TypeField.Check
        self.payPalFuturePaymentField!.setImageTypeField()
        self.payPalFuturePaymentField!.nameField = "PayPal pagos futuros"
        self.content.addSubview(self.payPalFuturePaymentField!)

        //Descuentos
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRectMake(margin, self.paymentOptions!.frame.maxY + 20.0, width, lheight))
        self.content.addSubview(sectionTitleDiscount)
        
        self.discountAssociate = FormFieldView(frame: CGRectMake(margin,sectionTitleDiscount.frame.maxY + 10.0,width,fheight))
        self.discountAssociate!.setCustomPlaceholder(NSLocalizedString("checkout.field.discountAssociate", comment:""))
        self.discountAssociate!.isRequired = true
        self.discountAssociate!.typeField = TypeField.Check
        self.discountAssociate!.setImageTypeField()
        self.discountAssociate!.nameField = NSLocalizedString("checkout.field.discountAssociate", comment:"")
        self.content.addSubview(self.discountAssociate!)
        
        sectionTitleShipment = self.buildSectionTitle(NSLocalizedString("checkout.title.shipmentOptions", comment:""), frame: CGRectMake(margin, self.discountAssociate!.frame.maxY + 20.0, width, lheight))
        self.content.addSubview(sectionTitleShipment)

        self.address = FormFieldView(frame: CGRectMake(margin, sectionTitleShipment.frame.maxY + 10.0, width, fheight))
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
        self.deliveryDate!.inputAccessoryView = viewAccess
        self.deliveryDate!.disablePaste = true
        self.content.addSubview(self.deliveryDate!)
        
        self.deliveryDatePicker = UIDatePicker()
        self.deliveryDatePicker!.datePickerMode = .Date
        self.deliveryDatePicker!.date = NSDate()
        
         let SECS_IN_DAY:NSTimeInterval = 60 * 60 * 24
         var maxDate =  NSDate()
         maxDate = maxDate.dateByAddingTimeInterval(SECS_IN_DAY * 6.0)
        
        self.deliveryDatePicker!.minimumDate = NSDate()
        self.deliveryDatePicker!.maximumDate = maxDate
        
        
        self.deliveryDatePicker!.addTarget(self, action: "dateChanged", forControlEvents: .ValueChanged)
        self.deliveryDate!.inputView = self.deliveryDatePicker!
        
        self.deliverySchedule = FormFieldView(frame: CGRectMake(margin, self.deliveryDate!.frame.maxY + 5.0, width, fheight))
        self.deliverySchedule!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliverySchedule", comment:""))
        self.deliverySchedule!.isRequired = true
        self.deliverySchedule!.typeField = TypeField.List
        self.deliverySchedule!.setImageTypeField()
        self.deliverySchedule!.nameField = NSLocalizedString("checkout.field.deliverySchedule", comment:"")
        self.content.addSubview(self.deliverySchedule!)

        self.comments = FormFieldView(frame: CGRectMake(margin, self.deliverySchedule!.frame.maxY + 5.0, width, fheight))
        self.comments!.setCustomPlaceholder(NSLocalizedString("checkout.field.comments", comment:""))
        self.comments!.isRequired = true
        self.comments!.typeField = TypeField.String
        self.comments!.nameField = NSLocalizedString("checkout.field.comments", comment:"")
        self.comments!.inputAccessoryView = viewAccess
        self.comments!.maxLength = 100
        self.content.addSubview(self.comments!)
        self.comments!.inputAccessoryView = viewAccess

        sectionTitleConfirm = self.buildSectionTitle(NSLocalizedString("checkout.title.confirmation", comment:""), frame: CGRectMake(margin, self.comments!.frame.maxY + 20.0, width, lheight))
        self.content.addSubview(sectionTitleConfirm)

        self.confirmation = FormFieldView(frame: CGRectMake(margin, sectionTitleConfirm.frame.maxY + 10.0, width, fheight))
        self.confirmation!.setCustomPlaceholder(NSLocalizedString("checkout.field.confirmation", comment:""))
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
        
        self.savings = UserCurrentSession.sharedInstance().estimateSavingGR()
        
        self.content.addSubview(totalView)
        self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR()+self.shipmentAmount)")
        
        self.content.contentSize = CGSizeMake(self.view.frame.width, totalView.frame.maxY + 20.0)
        
        
        picker = AlertPickerView.initPickerWithDefault()
        
        self.addViewLoad();
        
        
        
        self.invokeDiscountActiveService { () -> Void in
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
                        self.picker!.cellType = TypeField.Check
                        self.picker!.showPicker()
                        
                        
                    }
                }
                
                self.discountAssociate!.onBecomeFirstResponder = { () in
                    let discountAssociateItems = [NSLocalizedString("checkout.discount.associateNumber", comment:""),NSLocalizedString("checkout.discount.dateAdmission", comment:""),NSLocalizedString("checkout.discount.determinant", comment:"")]
                    self.picker!.sender = self.discountAssociate!
                    self.picker!.titleHeader = NSLocalizedString("checkout.field.discountAssociate", comment:"")
                    self.picker!.delegate = self
                    self.picker!.selected = self.selectedConfirmation
                    self.picker!.setValues(self.discountAssociate!.nameField, values: discountAssociateItems)
                    self.picker!.hiddenRigthActionButton(true)
                    self.picker!.cellType = TypeField.Alphanumeric
                    self.picker!.showPicker()
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillShow", name: UIKeyboardWillShowNotification, object: nil)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillHide", name: UIKeyboardWillHideNotification, object: nil)
                    
                    self.removeViewLoad()
                }
                self.reloadUserAddresses()
                
            }
            //PayPal
            PayPalMobile.preconnectWithEnvironment(self.getPayPalEnvironment())
        }
        
        
        //Fill orders
        self.orderOptionsItems = self.optionsConfirmOrder()
        
        if  self.orderOptionsItems?.count > 0 {
            self.selectedConfirmation  = NSIndexPath(forRow: 0, inSection: 0)
            let first = self.orderOptionsItems![0] as! NSDictionary
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
                self.picker!.cellType = TypeField.Check
                self.picker!.showPicker()
                
            }
        }
        
        self.payPalFuturePaymentField!.onBecomeFirstResponder = { () in
          self.payPalFuturePayment = !self.payPalFuturePayment
            if self.payPalFuturePayment
            {
                self.payPalFuturePaymentField!.setSelectedCheck(true)
            }
            else{
                self.payPalFuturePaymentField!.setSelectedCheck(false)

            }
        }
        
    }
    
    
    
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPointMake(self.picker!.center.x, self.picker!.center.y - 100)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.frame.size
        //var resumeHeight:CGFloat = 75.0
        let footerHeight:CGFloat = 60.0
        
        self.totalView.frame = CGRectMake(0, self.confirmation!.frame.maxY + 10, self.view.frame.width, 60)
        self.footer!.frame = CGRectMake(0.0, self.view.frame.height - footerHeight, bounds.width, footerHeight)
        self.buttonShop!.frame = CGRectMake(16, (footerHeight / 2) - 17, bounds.width - 32, 34)
        
        self.buildSubViews()
        
    }
    
    //MARK: - Build Views
    
    func buildSubViews(){
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.content!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - (self.header!.frame.height + footerHeight))
        self.content.contentSize = CGSizeMake(self.view.frame.width, totalView.frame.maxY + 20.0)
        
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        
        let margin: CGFloat = 15.0
        let widthField = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 25.0
        
        self.payPalFuturePaymentField!.alpha = 0
        var referenceFrame = self.paymentOptions!.frame
        
        if showPayPalFuturePayment{
            self.payPalFuturePaymentField!.alpha = 1
            referenceFrame = self.payPalFuturePaymentField!.frame
        }
        
        
        self.paymentOptions!.frame = CGRectMake(margin, self.paymentOptions!.frame.minY, widthField, fheight)
        if showDiscountAsociate || UserCurrentSession.sharedInstance().isAssociated == 1
        {
            self.discountAssociate!.alpha = 1
            self.sectionTitleDiscount!.alpha = 1
            self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.paymentOptions!.frame.maxY + 10.0, widthField, fheight)
            self.sectionTitleDiscount.frame = CGRectMake(margin, referenceFrame.maxY + 20.0, widthField, lheight)
            self.discountAssociate!.frame = CGRectMake(margin,sectionTitleDiscount.frame.maxY,widthField,fheight)
            let posY = self.buildPromotionButtons()
            self.sectionTitleShipment.frame =  CGRectMake(margin, posY, widthField, lheight)
            self.address!.frame =  CGRectMake(margin, sectionTitleShipment.frame.maxY + 10.0, widthField, fheight)
            
        } else {
            self.discountAssociate!.alpha = 0
            self.sectionTitleDiscount!.alpha = 0
            self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.paymentOptions!.frame.maxY + 10.0, widthField, fheight)
            self.sectionTitleShipment.frame = CGRectMake(margin, referenceFrame.maxY + 20.0, widthField, lheight)
            self.address!.frame = CGRectMake(margin, sectionTitleShipment.frame.maxY + 10.0, widthField, fheight)
        }
        
        self.shipmentType!.frame = CGRectMake(margin, self.address!.frame.maxY + 5.0, widthField, fheight)
        self.deliveryDate!.frame = CGRectMake(margin, self.shipmentType!.frame.maxY + 5.0, widthField, fheight)
        self.deliverySchedule!.frame = CGRectMake(margin, self.deliveryDate!.frame.maxY + 5.0, widthField, fheight)
        self.comments!.frame = CGRectMake(margin, self.deliverySchedule!.frame.maxY + 5.0, widthField, fheight)
        self.sectionTitleConfirm!.frame = CGRectMake(margin, self.comments!.frame.maxY + 20.0, widthField, lheight)
        self.confirmation!.frame = CGRectMake(margin, sectionTitleConfirm.frame.maxY + 10.0, widthField, fheight)
        

    }
    
    func buildFooterView() {
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.footer!)
        
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton(type: .Custom) as UIButton
        self.buttonShop!.frame = CGRectMake(16, (footerHeight / 2) - 17, bounds.width - 32, 34)
        self.buttonShop!.backgroundColor = WMColor.shoppingCartShopBgColor
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: "sendOrder", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonShop!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        self.footer!.addSubview(self.buttonShop!)

    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.listAddressHeaderSectionColor
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func buildPromotionButtons() -> CGFloat{
        let bounds = self.view.frame.size
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        let margin: CGFloat = 15.0
        let widthField = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        var posY = discountAssociate!.frame.maxY
        var count =  0
        if promotionsDesc.count > 0 && !self.hasPromotionsButtons {
            posY -= 10
            for promotion in self.promotionsDesc{
                posY += CGFloat(40 * count)
               let promSelect = UIButton(frame: CGRectMake(margin,posY,widthField,fheight))
                promSelect.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
                promSelect.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
                promSelect.addTarget(self, action: "promCheckSelected:", forControlEvents: UIControlEvents.TouchUpInside)
                promSelect.setTitle(promotion["promotion"], forState: UIControlState.Normal)
                promSelect.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
                promSelect.titleLabel?.textAlignment = .Left
                promSelect.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
                promSelect.titleEdgeInsets = UIEdgeInsetsMake(1, 1, 0, 0)
                promSelect.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                promSelect.selected = false
                promSelect.tag = count
                self.content.addSubview(promSelect)
                count++
            }
            posY += 50
            self.hasPromotionsButtons = true
        }
        else{
            posY += CGFloat(40 * self.promotionsDesc.count)
        }
        return posY
    }
    
    //MARK: - Field Utils
    
    func promCheckSelected(sender: UIButton){
        self.promotionIds! = ""
        if(sender.selected){
            sender.selected = false
            self.promotionsDesc[sender.tag]["selected"] = "false"
        }
        else{
            sender.selected = true
            self.promotionsDesc[sender.tag]["selected"] = "true"
        }
        
        for prom in self.promotionsDesc{
            if prom["selected"] == "true" {
               self.promotionIds! += (self.promotionIds == "") ? "\(prom["idPromotion"]!)" : ",\(prom["idPromotion"]!)"
            }
        }
    }
    
    func paymentOption(atIndex index:Int) -> String {
        if self.paymentOptionsItems != nil && self.paymentOptionsItems!.count > 0 {
            var option = self.paymentOptionsItems![index] as! [String:AnyObject]
            if let text = option["paymentType"] as? String {
                return text
            }
        }
        return ""
    }
    
    func addressOption(atIndex index:Int) -> String {
        if self.addressItems != nil && self.addressItems!.count > 0 {
            var option = self.addressItems![index] as! [String:AnyObject]
            if let text = option["name"] as? String {
                return text
            }
        }
        return ""
    }
    
    func shipmentOption(atIndex index:Int) -> String {
        if self.shipmentItems != nil && self.shipmentItems!.count > 0 {
            var option = self.shipmentItems![index] as! [String:AnyObject]
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
        let date = self.deliveryDatePicker!.date
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
                self.picker!.cellType = TypeField.Check
                self.picker!.showPicker()
            }
            
            self.removeViewLoad()
            
        })
    }

    //MARK: - Services
    
    func invokeDiscountActiveService(endCallDiscountActive:(() -> Void)) {
        let discountActive  = GRDiscountActiveService()
        discountActive.callService({ (result:NSDictionary) -> Void in
            if let res = result["discountsFreeShippingAssociated"] as? Bool {
                self.discountsFreeShippingAssociated = res
            }
            if let res = result["discountsFreeShippingNotAssociated"] as? Bool {
                self.discountsFreeShippingNotAssociated = res
            }
            if let res = result["discountsAssociated"] as? Bool {
                self.showDiscountAsociate = res
            }
            endCallDiscountActive()
            }, errorBlock: { (error:NSError) -> Void in
                endCallDiscountActive()
        })
    }
    
    func invokePaymentService(endCallPaymentOptions:(() -> Void)) {
        self.addViewLoad()
        
        let service = GRPaymentTypeService()
        service.callService("2",
            successBlock: { (result:NSArray) -> Void in
                self.paymentOptionsItems = result as [AnyObject]
                if result.count > 0 {
                    let option = result[0] as! NSDictionary
                    if let text = option["paymentType"] as? String {
                        self.paymentOptions!.text = text
                        self.selectedPaymentType = NSIndexPath(forRow: 0, inSection: 0)
                    }
                    if let id = option["id"] as? String {
                        if id == "-1"{
                            self.showPayPalFuturePayment = true
                            self.buildSubViews()
                        }
                    }
                }
                self.removeViewLoad()
                endCallPaymentOptions()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at invoke payment type service")
                self.removeViewLoad()
                endCallPaymentOptions()
            }
        )
    }
    
    func invokeGetPromotionsService(pickerValues: [String:String], discountAssociateItems: [String])
    {
        if pickerValues.count == discountAssociateItems.count
        {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            self.alertView!.setMessage("Validando Promociones")
            
            //self.addViewLoad()
            var paramsDic: [String:String] = pickerValues
            paramsDic["isAssociated"] = "\(UserCurrentSession.sharedInstance().isAssociated)"
            paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR())"
            let promotionsService = GRGetPromotionsService()
            
            
            self.associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
            self.dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
            self.determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]
            
            promotionsService.setParams(paramsDic)
            promotionsService.callService(requestParams: paramsDic, succesBlock: { (resultCall:NSDictionary) -> Void in
                // self.removeViewLoad()
                if resultCall["codeMessage"] as! Int == 0
                {
                    if let listPromotions = resultCall["listPromotions"] as? [AnyObject]{
                        for promotion in listPromotions {
                            self.promotionsDesc.append(["promotion":promotion["promotion"] as! String,"idPromotion":"\(promotion["idPromotion"] as! Int)","selected":"false"])
                        }
                    }
                    self.discountAssociate!.setSelectedCheck(true)
                    self.invokeDeliveryTypesService({ () -> Void in
                        self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                        self.alertView!.showDoneIcon()
                    })
                    
                    self.discountAssociate!.onBecomeFirstResponder = { () in
                    }
                    
                }
                }, errorBlock: {(error: NSError) -> Void in
                    //self.removeViewLoad()
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    print("Error at invoke address user service")
            })
        }
    }
    
    func invokeDiscountAssociateService(pickerValues: [String:String], discountAssociateItems: [String])
    {
        if pickerValues.count == discountAssociateItems.count
        {
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            self.alertView!.setMessage("Validando descuentos")
            
            //self.addViewLoad()
            var paramsDic: [String:String] = pickerValues
            paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR())"
            let discountAssociateService = GRDiscountAssociateService()
            
            
            self.associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
            self.dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
            self.determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]
            
            discountAssociateService.setParams(paramsDic)
            discountAssociateService.callService(requestParams: paramsDic, succesBlock: { (resultCall:NSDictionary) -> Void in
               // self.removeViewLoad()
                if resultCall["codeMessage"] as! Int == 0
                {
                    var items = UserCurrentSession.sharedInstance().itemsGR as! [String:AnyObject]
                    if let savingGR = items["saving"] as? NSNumber {
                        items["saving"] = savingGR.doubleValue + (resultCall["totalDiscounts"] as! NSString).doubleValue - self.amountDiscountAssociate
                    }
                    else{
                        items["saving"] = (resultCall["totalDiscounts"] as! NSString).doubleValue - self.amountDiscountAssociate
                    }
                    self.amountDiscountAssociate = (resultCall["totalDiscounts"] as! NSString).doubleValue
                    UserCurrentSession.sharedInstance().itemsGR = items as NSDictionary
                    
                    self.totalView.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
                        subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
                        saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
                    self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR()+self.shipmentAmount)")
                    self.discountAssociate!.setSelectedCheck(true)
                    self.asociateDiscount = true
                    
                    self.invokeDeliveryTypesService({ () -> Void in
                        self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                        self.alertView!.showDoneIcon()
                    })
                    
                    self.discountAssociate!.onBecomeFirstResponder = { () in
                    }
                    
                }
                }, errorBlock: {(error: NSError) -> Void in
                //self.removeViewLoad()
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    print("Error at invoke address user service")
            })
        }
    }
    
    func invokeAddressUserService(endCallAddress:(() -> Void)) {
        self.addViewLoad()
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
                                            self.selectedAddress = idDir
                                            
                                        }
                                        if let isAddressOK = dictDir["isAddressOk"] as? String {
                                            self.selectedAddressHasStore = !(isAddressOK == "False")
                                            if !self.selectedAddressHasStore{
                                                self.showAddressPicker()
                                                self.picker!.newItemForm()
                                                let delay = 0.7 * Double(NSEC_PER_SEC)
                                                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                                dispatch_after(time, dispatch_get_main_queue()) {
                                                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
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
                self.removeViewLoad()
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
                self.picker!.cellType = TypeField.Check
                self.picker!.showPicker()
            }
            
            self.buildSlotsPicker(self.selectedDate)
        })
        }
    }
    
    func invokeDeliveryTypesService(endCallTypeService:(() -> Void)) {
        self.addViewLoad()
        let service = GRDeliveryTypeService()
        let shouldFreeShepping = (discountsFreeShippingAssociated && asociateDiscount) || (discountsFreeShippingNotAssociated && !asociateDiscount)
        service.setParams("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())", addressId: self.selectedAddress!,isFreeShiping:"\(shouldFreeShepping)")
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
                self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR()+self.shipmentAmount)")
                self.removeViewLoad()
                
                endCallTypeService()
            },
            errorBlock: { (error:NSError) -> Void in
                self.removeViewLoad()
                print("Error at invoke delivery type service")
                endCallTypeService()
            }
        )
    }
    
    
    func reloadUserAddresses(){
        self.addViewLoad()

        self.invokeAddressUserService({ () -> Void in
           self.getItemsTOSelectAddres()
            self.address!.onBecomeFirstResponder = {() in
                self.showAddressPicker()
                self.removeViewLoad()
            }
            
            let date = NSDate()
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
                            self.deliveryDatePicker!.date = date
                        }
                    }
                }
                self.slotsItems = result["slots"] as! NSArray as [AnyObject]
                self.addViewLoad()
                endCallTypeService()
            }) { (error:NSError) -> Void in
                self.removeViewLoad()
                self.slotsItems = []
                endCallTypeService()
        }
        
    }
    
    func parseDateString(dateStr:String, format:String="dd/MM/yyyy") -> NSDate {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.paymentOptions! {
                self.paymentOptions!.text = selectedStr
                self.selectedPaymentType = indexPath
                let paymentType: AnyObject = self.paymentOptionsItems![indexPath.row]
                let paymentId = paymentType["id"] as! String
                if paymentId == "-1"{
                    self.showPayPalFuturePayment = true
                    self.buildSubViews()
                }
                else{
                    self.showPayPalFuturePayment = false
                    self.buildSubViews()
                }
            }
            if formFieldObj ==  self.address! {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![indexPath.row] as! [String:AnyObject]
                if let addressId = option["id"] as? String {
                    self.selectedAddress = addressId
                    if  let selectedAddressHasStoreVal = option["isAddressOk"] as? String {
                        if selectedAddressHasStoreVal == "False" {
                            self.selectedAddressHasStore  = false
                            self.picker!.newItemForm()
                            self.picker!.stopRemoveView = true
                            let delay = 0.5 * Double(NSEC_PER_SEC)
                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(time, dispatch_get_main_queue()) {
                                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                                self.alertView!.setMessage(NSLocalizedString("gr.address.field.addressNotOk",comment:""))
                                self.alertView!.showDoneIconWithoutClose()
                                self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                            }
                            return
                        }else{
                            buildAndConfigureDeliveryType()
                      }
                    }else{
                        buildAndConfigureDeliveryType()
                    }
                }
                
                self.selectedAddressIx = indexPath
                
            }
            if formFieldObj ==  self.shipmentType! {
                  BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_DELIVERY_TYPE.rawValue , label: "")
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
            if formFieldObj ==  self.confirmation! {
                self.confirmation!.text = selectedStr
                self.selectedConfirmation = indexPath

            }
            if formFieldObj == self.discountAssociate!{
                 BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_DISCOUT_ASOCIATE.rawValue , label: "")
                if self.showDiscountAsociate{
                    self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
                }
                if UserCurrentSession.sharedInstance().isAssociated == 1{
                    self.invokeGetPromotionsService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
                }
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
        if formFieldObj == self.discountAssociate!{
           self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
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
        self.addViewLoad()
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(sAddredssForm.idAddress, delete: false)
        if dictSend != nil {
            
            self.scrollForm.resignFirstResponder()
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            if self.addressItems?.count < 12 {
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                print("Se realizao la direccion")
                self.picker!.closeNew()
                self.picker!.closePicker()
                self.selectedAddress = resultCall["addressID"] as! String!
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
            
            let total = UserCurrentSession.sharedInstance().estimateTotalGR() //- self.savings
            
            let components : NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.NSYearCalendarUnit, NSCalendarUnit.NSMonthCalendarUnit, NSCalendarUnit.NSDayCalendarUnit], fromDate: self.selectedDate)
            
            
            let dateMonth = components.month
            let dateYear = components.year
            let dateDay = components.day
            
            let slotSel = self.slotsItems![selectedTimeSlotTypeIx.row]  as! NSDictionary
            let slotSelectedId = slotSel["id"] as! Int
            
            let shipmentTypeSel = self.shipmentItems![selectedShipmentTypeIx.row] as! NSDictionary
            let shipmentType = shipmentTypeSel["key"] as! String
            self.shipmentAmount = shipmentTypeSel["cost"] as! Double
            
            let confirmTypeSel = self.orderOptionsItems![selectedConfirmation.row] as! NSDictionary
            let confirmation = confirmTypeSel["key"] as! String
            
            let paymentSel = self.paymentOptionsItems![selectedPaymentType.row] as! NSDictionary
            let paymentSelectedId = paymentSel["id"] as! String
            
            serviceDetail = OrderConfirmDetailView.initDetail()
            serviceDetail?.delegate = self
            serviceDetail!.showDetail()
            
            let freeShipping = discountsFreeShippingAssociated || discountsFreeShippingNotAssociated
            
            let paramsOrder = serviceCheck.buildParams(total, month: "\(dateMonth)", year: "\(dateYear)", day: "\(dateDay)", comments: self.comments!.text!, paymentType: paymentSelectedId, addressID: self.selectedAddress!, device: getDeviceNum(), slotId: slotSelectedId, deliveryType: shipmentType, correlationId: "", hour: self.deliverySchedule!.text!, pickingInstruction: confirmation, deliveryTypeString: self.shipmentType!.text!, authorizationId: "", paymentTypeString: self.paymentOptions!.text!,isAssociated:self.asociateDiscount,idAssociated:associateNumber,dateAdmission:dateAdmission,determinant:determinant,isFreeShipping:freeShipping,promotionIds:promotionIds,appId:self.getAppId())
            
              serviceCheck.callService(requestParams: paramsOrder, successBlock: { (resultCall:NSDictionary) -> Void in
                print(resultCall)
                let purchaseOrderArray = resultCall["purchaseOrder"] as! NSArray
                let purchaseOrder = purchaseOrderArray[0] as! NSDictionary
                
                let trakingNumber = purchaseOrder["trackingNumber"] as! String
                let deliveryDate = purchaseOrder["deliveryDate"] as! NSString
                let paymentTypeString = purchaseOrder["paymentTypeString"] as! String
                let hour = purchaseOrder["hour"] as! String
                let subTotal = purchaseOrder["subTotal"] as! NSNumber
                let total = purchaseOrder["total"] as! NSNumber
                var authorizationId = ""
                var correlationId = ""
                if let authorizationIdVal = purchaseOrder["authorizationId"] as? String {
                    authorizationId = authorizationIdVal
                }
                if let correlationIdVal = purchaseOrder["correlationId"] as? String {
                    correlationId = correlationIdVal
                }
                
                let formattedSubtotal = CurrencyCustomLabel.formatString(subTotal.stringValue)
                let formattedTotal = CurrencyCustomLabel.formatString(total.stringValue)
                
                let formattedDate = deliveryDate.substringToIndex(10)
                
                let slot = purchaseOrder["slot"] as! NSDictionary
                
                self.confirmOrderDictionary = ["paymentType": paymentSelectedId,"trackingNumber": trakingNumber,"authorizationId": authorizationId,"correlationId": correlationId,"device":self.getDeviceNum()]
                self.cancelOrderDictionary = ["slot": slot,"device": self.getDeviceNum(),"paymentType": paymentSelectedId,"deliveryType": shipmentType,"trackingNumber": trakingNumber]
                self.completeOrderDictionary = ["trakingNumber":trakingNumber, "deliveryDate": formattedDate, "deliveryHour": hour, "paymentType": paymentTypeString, "subtotal": formattedSubtotal, "total": formattedTotal]
                //PayPal
                if paymentSelectedId == "-1"{
                    if self.payPalFuturePayment{
                        self.showPayPalFuturePaymentController()
                    }else{
                        self.showPayPalPaymentController()
                    }
                    return
                }
//                
//                if paymentSelectedId == "-3"{
//                    self.invokePaypalUpdateOrderService()
//                }
                
                self.serviceDetail?.completeOrder(trakingNumber, deliveryDate: formattedDate, deliveryHour: hour, paymentType: paymentTypeString, subtotal: formattedSubtotal, total: formattedTotal)
                
                self.buttonShop?.enabled = false
         
                
                //self.performSegueWithIdentifier("showOrderDetail", sender: self)
                
                }) { (error:NSError) -> Void in
                    
                                     
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
    
    func showAddressPicker(){
        let itemsAddress : [String] = self.getItemsTOSelectAddres()
        self.picker!.selected = self.selectedAddressIx
        self.picker!.sender = self.address!
        self.picker!.delegate = self
            
        let btnNewAddress = WMRoundButton()
        btnNewAddress.setTitle("nueva", forState: UIControlState.Normal)
        //newAddressButton = WMRoundButton()  0x8EBB36
        btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        btnNewAddress.setBackgroundColor(WMColor.UIColorFromRGB(0x2970ca), size: CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
        btnNewAddress.layer.cornerRadius = 2.0
            
        self.picker!.addRigthActionButton(btnNewAddress)
        self.picker!.setValues(self.address!.nameField, values: itemsAddress)
        self.picker!.hiddenRigthActionButton(false)
        self.picker!.cellType = TypeField.Check
        if !self.selectedAddressHasStore {
            self.picker!.onClosePicker = {
                self.picker!.onClosePicker = nil
                self.navigationController?.popViewControllerAnimated(true)
                self.picker!.closePicker()
            }
        }
        
        self.picker!.showPicker()
    }
    
    func getDeviceNum() -> String {
        return  "24"
    }
    
    func validate() -> Bool{
        let error = viewError(deliverySchedule!)
        return !error
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
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    //MARK: - PayPal
    func showPayPalPaymentController()
    {
        let items :[[String:AnyObject]] = UserCurrentSession.sharedInstance().itemsGR!["items"]! as! [[String:AnyObject]]
        var payPalItems: [PayPalItem] = []
        for item in items {
            var itemPrice = item["price"] as! Double
            var quantity = item["quantity"] as! UInt
            if item["type"] as! String == "1"
            {
                //(prodCart.quantity.doubleValue / 1000.0) * prodCart.product.price.doubleValue
                itemPrice = (Double(quantity) / 1000.0) * itemPrice
                quantity = 1
            }
            let payPalItem = PayPalItem(name: item["description"] as! String, withQuantity:quantity , withPrice: NSDecimalNumber(string: String(format: "%.2f", itemPrice)), withCurrency: "MXN", withSku: item["upc"] as! String)
            payPalItems.append(payPalItem)
        }
        // Los cupones y descuentos se agregan como item negativo.
        let discounts = 0.0 - UserCurrentSession.sharedInstance().estimateSavingGR()
        if discounts < 0
        {
            payPalItems.append(PayPalItem(name: "Descuentos", withQuantity:1 , withPrice: NSDecimalNumber(double:discounts), withCurrency: "MXN", withSku: "0000000000001"))
        }
        let subtotal = PayPalItem.totalPriceForItems(payPalItems)
        // Optional: include payment details
        let shipping = NSDecimalNumber(double: self.shipmentAmount)
        let tax = NSDecimalNumber(double: 0.0)
        let paymentDetails = PayPalPaymentDetails(subtotal:subtotal, withShipping: shipping, withTax: tax)
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "MXN", shortDescription: "Walmart", intent: .Sale)
        
        payment.items = payPalItems
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.initPayPalConfig(), delegate: self)
            paymentViewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.presentViewController(paymentViewController, animated: true, completion: nil)
        }
    }
    
    func showPayPalFuturePaymentController(){
        let futurePaymentController = PayPalFuturePaymentViewController(configuration: self.initPayPalConfig(), delegate: self)
        futurePaymentController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.presentViewController(futurePaymentController, animated: true, completion: nil)
    }
    
    func initPayPalConfig() -> PayPalConfiguration{
        // Set up payPalConfig
        let payPalConfig = PayPalConfiguration()// default
        payPalConfig.acceptCreditCards = false;
        payPalConfig.merchantName = "Walmart"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.rememberUser = true
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0] 
        payPalConfig.payPalShippingAddressOption = .Provided;
        return payPalConfig
    }
    
    func getPayPalEnvironment() -> String{
        let payPalEnvironment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMPayPalEnvironment") as! NSDictionary
        let environment = payPalEnvironment.objectForKey("PayPalEnvironment") as! String
        
        if environment == "SANDBOX"{
            return PayPalEnvironmentSandbox
        }
        else if  environment == "PRODUCTION"{
             return PayPalEnvironmentProduction
        }
        
        return PayPalEnvironmentNoNetwork
    }
    
    func invokePaypalUpdateOrderService(authorizationId:String,paymentType:String){
        let updatePaypalService = GRPaypalUpdateOrderService()
        self.confirmOrderDictionary["authorizationId"] = authorizationId
        self.confirmOrderDictionary["correlationId"] = PayPalMobile.clientMetadataID()
        self.confirmOrderDictionary["paymentType"] = paymentType

        updatePaypalService.callServiceConfirmOrder(requestParams: self.confirmOrderDictionary, succesBlock: {(result:NSDictionary) -> Void in
            self.serviceDetail?.completeOrder(self.completeOrderDictionary["trakingNumber"] as! String, deliveryDate: self.completeOrderDictionary["deliveryDate"] as! String, deliveryHour: self.completeOrderDictionary["deliveryHour"] as! String, paymentType: self.completeOrderDictionary["paymentType"] as! String, subtotal: self.completeOrderDictionary["subtotal"] as! String, total: self.completeOrderDictionary["total"] as! String)
            
            }, errorBlock: { (error:NSError) -> Void in
                if error.code == -400 {
                    self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
                }
                else {
                    self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
                }
        })
    }
    
    func invokePayPalCancelService(message: String){
        let cancelPayPalService = GRPaypalUpdateOrderService()
        cancelPayPalService.callServiceCancelOrder(requestParams: self.cancelOrderDictionary, succesBlock: {(result:NSDictionary) -> Void in
            self.serviceDetail?.errorOrder(message)
            }, errorBlock: { (error:NSError) -> Void in
            if error.code == -400 {
                self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
            }
            else {
                self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
            }
        })

    }
    
    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        buttonShop?.enabled = true
        let message = "Tu pago ha sido cancelado"
        self.invokePayPalCancelService(message)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        print("PayPal Payment Success !")
        print(completedPayment!.description)
        
       
        if let completeDict = completedPayment.confirmation["response"] as? [String:AnyObject] {
            if let idPayPal = completeDict["id"] as? String {
                self.invokePaypalUpdateOrderService(idPayPal,paymentType:"-1")
            }
        }

      
        
        buttonShop?.enabled = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
     // PayPalFuturePaymentDelegate
    func payPalFuturePaymentDidCancel(futurePaymentViewController: PayPalFuturePaymentViewController!) {
        print("PayPal Future Payment Authorization Canceled")
        buttonShop?.enabled = true
        let message = "Hubo un error al momento de generar la orden, intenta más tarde"
        self.invokePayPalCancelService(message)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(futurePaymentViewController: PayPalFuturePaymentViewController!, didAuthorizeFuturePayment futurePaymentAuthorization: [NSObject : AnyObject]!) {
        print("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        print(futurePaymentAuthorization!.description)
        let futurePaymentService = GRPayPalFuturePaymentService()
        let responce = futurePaymentAuthorization["response"] as! [NSObject : AnyObject]
        futurePaymentService.callService(responce["code"] as! String, succesBlock: {(result:NSDictionary) -> Void in
            //self.invokePaypalUpdateOrderService("",paymentType:"-3")
             self.showPayPalPaymentController()
            }, errorBlock: { (error:NSError) -> Void in
                //Mandar alerta
                let message = "Hubo un error al momento de generar la orden, intenta más tarde"
                self.invokePayPalCancelService(message)
        })
        buttonShop?.enabled = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getAppId() -> String{
        IS_IPAD
        return "iOS \(UIDevice.currentDevice().systemVersion) \(IS_IPAD ? "Ipad" : "Iphone")"
    }
}