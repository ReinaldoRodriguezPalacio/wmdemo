//
//  GRCheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/22/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

//import Tune

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
    
    var paymentOptionsItems: [[String:Any]]?
    var addressItems: [[String:Any]]?
    var shipmentItems: [[String:Any]]?
    var slotsItems: [[String:Any]]?
    var orderOptionsItems: [[String:String]]?

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
    
    var dateFmt: DateFormatter?
    
    var selectedPaymentType : IndexPath!
    var selectedAddressIx : IndexPath!
    var selectedShipmentTypeIx : IndexPath!
    var selectedTimeSlotTypeIx : IndexPath!
    var selectedConfirmation : IndexPath!
    var selectedDate : Date!
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
    
    var isAssociateSend : Bool =  false
    var showDiscountAsociate : Bool = false
    var asociateDiscount : Bool = false
    var discountsFreeShippingAssociated : Bool = false
    var discountsFreeShippingNotAssociated : Bool = false
    var payPalFuturePayment : Bool = false
    var showPayPalFuturePayment : Bool = false
    
    
    var associateNumber : String! = ""
    var dateAdmission : String! = ""
    var determinant : String! = ""
    var confirmOrderDictionary: [String:Any]! = [:]
    var cancelOrderDictionary:  [String:Any]! = [:]
    var completeOrderDictionary: [String:Any]! = [:]
    var promotionIds: String! = ""
    var promotionsDesc: [[String:String]]! = []
    var promotionButtons: [UIView]! = []
    var hasPromotionsButtons: Bool! = false
    var idReferido : Int! = 0
    var idFreeShepping : Int! = 0
    var totalDiscountsOrder : Double! = 0
    var newTotal : Double!
    var idStore :String =  ""
    
    var deliveryAmount : Double!
    var discountsAssociated : Double!
    
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
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat =  "d MMMM yyyy"
        
        self.titleLabel?.text = NSLocalizedString("checkout.gr.title", comment:"")
        self.view.backgroundColor = UIColor.white
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.white
        self.view.addSubview(self.content)

        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 44),
            inputViewStyle: .keyboard,
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
        let sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.title.paymentOptions", comment:""), frame: CGRect(x: margin, y: 20.0, width: width, height: lheight))
        self.content.addSubview(sectionTitle)
        
        self.paymentOptions = FormFieldView(frame: CGRect(x: margin, y: sectionTitle.frame.maxY + 10.0, width: width, height: fheight))
        self.paymentOptions!.setCustomPlaceholder(NSLocalizedString("checkout.field.paymentOptions", comment:""))
        self.paymentOptions!.isRequired = true
        self.paymentOptions!.typeField = TypeField.list
        self.paymentOptions!.setImageTypeField()
        self.paymentOptions!.nameField = NSLocalizedString("checkout.field.paymentOptions", comment:"")
        self.content.addSubview(self.paymentOptions!)
        
        self.payPalFuturePaymentField = FormFieldView(frame: CGRect(x: margin,y: paymentOptions!.frame.maxY + 10.0,width: width,height: fheight))
        self.payPalFuturePaymentField!.setCustomPlaceholder("PayPal pagos futuros")
        self.payPalFuturePaymentField!.isRequired = true
        self.payPalFuturePaymentField!.typeField = TypeField.check
        self.payPalFuturePaymentField!.setImageTypeField()
        self.payPalFuturePaymentField!.nameField = "PayPal pagos futuros"
        self.content.addSubview(self.payPalFuturePaymentField!)

        //Descuentos
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRect(x: margin, y: self.paymentOptions!.frame.maxY + 20.0, width: width, height: lheight))
        self.content.addSubview(sectionTitleDiscount)
        
        self.discountAssociate = FormFieldView(frame: CGRect(x: margin,y: sectionTitleDiscount.frame.maxY + 10.0,width: width,height: fheight))
        self.discountAssociate!.setCustomPlaceholder(NSLocalizedString("checkout.field.discountAssociate", comment:""))
        self.discountAssociate!.isRequired = false
        self.discountAssociate!.typeField = TypeField.check
        self.discountAssociate!.setImageTypeField()
        self.discountAssociate!.nameField = NSLocalizedString("checkout.field.discountAssociate", comment:"")
        self.content.addSubview(self.discountAssociate!)
        
        sectionTitleShipment = self.buildSectionTitle(NSLocalizedString("checkout.title.shipmentOptions", comment:""), frame: CGRect(x: margin, y: self.discountAssociate!.frame.maxY + 20.0, width: width, height: lheight))
        self.content.addSubview(sectionTitleShipment)

        self.address = FormFieldView(frame: CGRect(x: margin, y: sectionTitleShipment.frame.maxY + 10.0, width: width, height: fheight))
        self.address!.setCustomPlaceholder(NSLocalizedString("checkout.field.address", comment:""))
        self.address!.isRequired = true
        self.address!.typeField = TypeField.list
        self.address!.setImageTypeField()
        self.address!.nameField = NSLocalizedString("checkout.field.address", comment:"")
        self.content.addSubview(self.address!)

        self.shipmentType = FormFieldView(frame: CGRect(x: margin, y: self.address!.frame.maxY + 5.0, width: width, height: fheight))
        self.shipmentType!.setCustomPlaceholder(NSLocalizedString("checkout.field.shipmentType", comment:""))
        self.shipmentType!.isRequired = true
        self.shipmentType!.typeField = TypeField.list
        self.shipmentType!.setImageTypeField()
        self.shipmentType!.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
        self.content.addSubview(self.shipmentType!)


        self.deliveryDate = FormFieldView(frame: CGRect(x: margin, y: self.shipmentType!.frame.maxY + 5.0, width: width, height: fheight))
        self.deliveryDate!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliveryDate", comment:""))
        self.deliveryDate!.isRequired = true
        self.deliveryDate!.typeField = TypeField.list
        self.deliveryDate!.setImageTypeField()
        self.deliveryDate!.nameField = NSLocalizedString("checkout.field.deliveryDate", comment:"")
        self.deliveryDate!.inputAccessoryView = viewAccess
        self.deliveryDate!.disablePaste = true
        self.content.addSubview(self.deliveryDate!)
        
        self.deliveryDatePicker = UIDatePicker()
        self.deliveryDatePicker!.datePickerMode = .date
        self.deliveryDatePicker!.date = Date()
        
         let SECS_IN_DAY:TimeInterval = 60 * 60 * 24
         var maxDate =  Date()
         maxDate = maxDate.addingTimeInterval(SECS_IN_DAY * 5.0)
        
        self.deliveryDatePicker!.minimumDate = Date()
        self.deliveryDatePicker!.maximumDate = maxDate
        
        
        self.deliveryDatePicker!.addTarget(self, action: #selector(GRCheckOutViewController.dateChanged), for: .valueChanged)
        self.deliveryDate!.inputView = self.deliveryDatePicker!
        
        self.deliverySchedule = FormFieldView(frame: CGRect(x: margin, y: self.deliveryDate!.frame.maxY + 5.0, width: width, height: fheight))
        self.deliverySchedule!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliverySchedule", comment:""))
        self.deliverySchedule!.isRequired = true
        self.deliverySchedule!.typeField = TypeField.list
        self.deliverySchedule!.setImageTypeField()
        self.deliverySchedule!.nameField = NSLocalizedString("checkout.field.deliverySchedule", comment:"")
        self.content.addSubview(self.deliverySchedule!)

        self.comments = FormFieldView(frame: CGRect(x: margin, y: self.deliverySchedule!.frame.maxY + 5.0, width: width, height: fheight))
        self.comments!.setCustomPlaceholder(NSLocalizedString("checkout.field.comments", comment:""))
        self.comments!.isRequired = true
        self.comments!.typeField = TypeField.string
        self.comments!.nameField = NSLocalizedString("checkout.field.comments", comment:"")
        self.comments!.inputAccessoryView = viewAccess
        self.comments!.maxLength = 100
        self.content.addSubview(self.comments!)
        self.comments!.inputAccessoryView = viewAccess

        sectionTitleConfirm = self.buildSectionTitle(NSLocalizedString("checkout.title.confirmation", comment:""), frame: CGRect(x: margin, y: self.comments!.frame.maxY + 20.0, width: width, height: lheight))
        self.content.addSubview(sectionTitleConfirm)

        self.confirmation = FormFieldView(frame: CGRect(x: margin, y: sectionTitleConfirm.frame.maxY + 10.0, width: width, height: fheight))
        self.confirmation!.setCustomPlaceholder(NSLocalizedString("checkout.field.confirmation", comment:""))
        self.confirmation!.isRequired = true
        self.confirmation!.typeField = TypeField.list
        self.confirmation!.setImageTypeField()
        self.confirmation!.nameField = NSLocalizedString("checkout.field.confirmation", comment:"")
        
        self.content.addSubview(self.confirmation!)

        self.buildFooterView()
        
        totalView = IPOCheckOutTotalView(frame:CGRect(x: 0, y: self.confirmation!.frame.maxY + 10, width: self.view.frame.width, height: 60))
        
        totalView.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
            subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
            saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
        
        self.savings = UserCurrentSession.sharedInstance.estimateSavingGR()
        
        self.content.addSubview(totalView)
        self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR()-UserCurrentSession.sharedInstance.estimateSavingGR()+self.shipmentAmount)")
        
        self.content.contentSize = CGSize(width: self.view.frame.width, height: totalView.frame.maxY + 20.0)
        
        
        picker = AlertPickerView.initPickerWithDefault()
        
        self.addViewLoad()
        
        
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
                        self.picker!.cellType = TypeField.check
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
                    self.picker!.cellType = TypeField.alphanumeric
                    self.picker!.showPicker()
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(GRCheckOutViewController.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(GRCheckOutViewController.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                    
                    //self.removeViewLoad()
                }
                
                
                self.invokeGetPromotionsService(self.picker.textboxValues!, discountAssociateItems: self.picker.itemsToShow, endCallPromotions: { (finish) -> Void in
                    print("end service viewDidLoad ::: invokeGetPromotionsService")
                })
                self.reloadUserAddresses()
                
            }
            //PayPal
            PayPalMobile.preconnect(withEnvironment: self.getPayPalEnvironment())
        }
        
    
        
        
        //Fill orders
        self.orderOptionsItems = self.optionsConfirmOrder()
        
        if  self.orderOptionsItems?.count > 0 {
            self.selectedConfirmation  = IndexPath(row: 0, section: 0)
            let first = self.orderOptionsItems![0]
            let text = first["desc"]
            self.confirmation!.text = text
        }
        
        self.confirmation!.onBecomeFirstResponder = {() in

            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_PAYMENTOPTIONS.rawValue , label: "")
            
            let _ = self.comments?.resignFirstResponder()
            if self.paymentOptionsItems != nil && self.paymentOptionsItems!.count > 0 {
                var itemsOrderOptions : [String] = []
                for option in self.orderOptionsItems! {
                    let text = option["desc"]
                    itemsOrderOptions.append(text!)
                }
                
                self.picker!.selected = self.selectedConfirmation
                self.picker!.sender = self.confirmation!
                self.picker!.delegate = self
                self.picker!.setValues(self.confirmation!.nameField, values: itemsOrderOptions)
                self.picker!.hiddenRigthActionButton(true)
                self.picker!.cellType = TypeField.check
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
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.buildSubViews()
    }
    
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPoint(x: self.picker!.center.x, y: self.picker!.center.y - 100)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.frame.size
        //var resumeHeight:CGFloat = 75.0
        let footerHeight:CGFloat = 60.0
        self.footer!.frame = CGRect(x: 0.0, y: self.view.frame.height - footerHeight, width: bounds.width, height: footerHeight)
        self.buttonShop!.frame = CGRect(x: 16, y: (footerHeight / 2) - 17, width: bounds.width - 32, height: 34)
        
        //self.buildSubViews()
        
    }
    
    //MARK: - Build Views
    
    func buildSubViews(){
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.content!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - (self.header!.frame.height + footerHeight))
        for view in self.promotionButtons{
            view.removeFromSuperview()
        }
        
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
        
        
        self.paymentOptions!.frame = CGRect(x: margin, y: self.paymentOptions!.frame.minY, width: widthField, height: fheight)
        
        if showDiscountAsociate
        {
            self.discountAssociate!.alpha = 1
            self.sectionTitleDiscount!.alpha = 1
            self.payPalFuturePaymentField!.frame = CGRect(x: margin, y: self.paymentOptions!.frame.maxY + 10.0, width: widthField, height: fheight)
            self.sectionTitleDiscount.frame = CGRect(x: margin, y: referenceFrame.maxY + 20.0, width: widthField, height: lheight)
            self.discountAssociate!.frame = CGRect(x: margin,y: sectionTitleDiscount.frame.maxY,width: widthField,height: fheight)
            
            let posY = self.buildPromotionButtons()
            self.sectionTitleShipment.frame =  CGRect(x: margin, y: posY, width: widthField, height: lheight)
            self.address!.frame =  CGRect(x: margin, y: sectionTitleShipment.frame.maxY + 10.0, width: widthField, height: fheight)
            
        } else {
            if self.promotionsDesc.count > 0 {
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 1
                self.payPalFuturePaymentField!.frame = CGRect(x: margin, y: self.paymentOptions!.frame.maxY + 10.0, width: widthField, height: fheight)
                let posY = self.buildPromotionButtons()
                print("posY ::: posY \(posY)")
                self.sectionTitleShipment.frame = CGRect(x: margin, y: posY, width: widthField, height: lheight)
                self.address!.frame = CGRect(x: margin, y: sectionTitleShipment.frame.maxY + 10.0, width: widthField, height: fheight)
            }else{
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 0
                self.payPalFuturePaymentField!.frame = CGRect(x: margin, y: self.paymentOptions!.frame.maxY + 10.0, width: widthField, height: fheight)
                self.sectionTitleShipment.frame = CGRect(x: margin, y: referenceFrame.maxY + 20.0, width: widthField, height: lheight)
                self.address!.frame = CGRect(x: margin, y: sectionTitleShipment.frame.maxY + 10.0, width: widthField, height: fheight)
            }
        }
        
        self.shipmentType!.frame = CGRect(x: margin, y: self.address!.frame.maxY + 5.0, width: widthField, height: fheight)
        self.deliveryDate!.frame = CGRect(x: margin, y: self.shipmentType!.frame.maxY + 5.0, width: widthField, height: fheight)
        self.deliverySchedule!.frame = CGRect(x: margin, y: self.deliveryDate!.frame.maxY + 5.0, width: widthField, height: fheight)
        self.comments!.frame = CGRect(x: margin, y: self.deliverySchedule!.frame.maxY + 5.0, width: widthField, height: fheight)
        self.sectionTitleConfirm!.frame = CGRect(x: margin, y: self.comments!.frame.maxY + 20.0, width: widthField, height: lheight)
        self.confirmation!.frame = CGRect(x: margin, y: sectionTitleConfirm.frame.maxY + 10.0, width: widthField, height: fheight)
        self.totalView.frame = CGRect(x: 0, y: self.confirmation!.frame.maxY + 10, width: self.view.frame.width, height: 60)
        self.content.contentSize = CGSize(width: self.view.frame.width, height: totalView.frame.maxY + 20.0)

    }
    
    func buildFooterView() {
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.white
        self.view.addSubview(self.footer!)
        
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton(type: .custom) as UIButton
        self.buttonShop!.frame = CGRect(x: 16, y: (footerHeight / 2) - 17, width: bounds.width - 32, height: 34)
        self.buttonShop!.backgroundColor = WMColor.green
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: #selector(GRCheckOutViewController.shopButtonTaped), for: UIControlEvents.touchUpInside)
        self.buttonShop!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        self.footer!.addSubview(self.buttonShop!)

    }
    
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    func buildPromotionButtons() -> CGFloat{
        let bounds = self.view.frame.size
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        let margin: CGFloat = 15.0
        let widthField = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        
        var posY = self.showDiscountAsociate ? discountAssociate!.frame.maxY : sectionTitleDiscount.frame.maxY + 10.0
        var count =  0
        if promotionsDesc.count > 0 {
            posY -= 10
            for promotion in self.promotionsDesc{
                posY += CGFloat(40 * count)
                
                let titleLabel = UILabel(frame:CGRect(x: 22, y: 0, width: widthField-22,height: fheight))
                titleLabel.font = WMFont.fontMyriadProRegularOfSize(13)
                titleLabel.text = promotion["promotion"]
                titleLabel.numberOfLines = 2
                titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                titleLabel.textColor = WMColor.dark_gray
                
               let promSelect = UIButton(frame: CGRect(x: margin,y: posY,width: widthField,height: fheight))
                promSelect.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
                promSelect.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
                promSelect.addTarget(self, action: #selector(GRCheckOutViewController.promCheckSelected(_:)), for: UIControlEvents.touchUpInside)
                promSelect.addSubview(titleLabel)
                promSelect.isSelected = false
                promSelect.tag = count
                promSelect.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,widthField - 20)
                self.content.addSubview(promSelect)
                self.promotionButtons.append(promSelect)
                count += 1
            }
            posY += 50
           // self.hasPromotionsButtons = true
        }
        else{
            posY += CGFloat(40 * self.promotionsDesc.count)
        }
        return posY
    }
    
    //MARK: - Field Utils
    var afterButton :UIButton?
    var promotionSelect: String! = ""
    func promCheckSelected(_ sender: UIButton){
        //self.promotionIds! = ""
        if promotionSelect != ""{
            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: ",\(promotionSelect)", with: "")
        }
        if(sender.isSelected){
            sender.isSelected = false
            self.promotionsDesc[sender.tag]["selected"] = "false"
        }
        else{
            
            if afterButton != nil{
                afterButton!.isSelected = false
                if afterButton!.tag < self.promotionsDesc.count {
                    self.promotionsDesc[afterButton!.tag]["selected"] = "false"
                }
            }

            
            sender.isSelected = true
            afterButton = sender
            self.promotionsDesc[sender.tag]["selected"] = "true"
        }
        
        for prom in self.promotionsDesc{
            if prom["selected"] == "true" {
                
                let idPromotion = prom["idPromotion"]!
                //promotionSelect =  idPromotion
                promotionSelect = idPromotion
               self.promotionIds! += (self.promotionIds == "") ? "\(idPromotion)" : ",\(idPromotion)"
            }
        }
        
        print("promosiones:::: \(self.promotionIds) :::")
    }
    
    func paymentOption(atIndex index:Int) -> String {
        if self.paymentOptionsItems != nil && self.paymentOptionsItems!.count > 0 {
            var option = self.paymentOptionsItems![index] 
            if let text = option["paymentType"] as? String {
                return text
            }
        }
        return ""
    }
    
    func addressOption(atIndex index:Int) -> String {
        if self.addressItems != nil && self.addressItems!.count > 0 {
            var option = self.addressItems![index] 
            if let text = option["name"] as? String {
                return text
            }
        }
        return ""
    }
    
    func shipmentOption(atIndex index:Int) -> String {
        if self.shipmentItems != nil && self.shipmentItems!.count > 0 {
            var option = self.shipmentItems![index] 
            if let text = option["name"] as? String {
                return text
            }
        }
        return ""
    }

    //MARK: - TPKeyboardAvoidingScrollViewDelegate

    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        if let scroll = sender as? TPKeyboardAvoidingScrollView {
            if scrollForm != nil {
                if scroll == scrollForm {
                    return CGSize(width: self.scrollForm.frame.width, height: self.scrollForm.contentSize.height)
                }
            }
        }
        return CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
    }
    
    func textFieldDidBeginEditing(_ sender: UITextField!) {
    }
    
    func textFieldDidEndEditing(_ sender: UITextField!) {
        
    }
    
     //MARK: - UIDatePicker
    
    func dateChanged() {
        let date = self.deliveryDatePicker!.date
        self.deliveryDate!.text = self.dateFmt!.string(from: date)
        self.selectedDate = date
        buildSlotsPicker(date)
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_DATE.rawValue , label: "")
        
    }
    
    func buildSlotsPicker(_ date:Date?) {
        //self.addViewLoad()
        var strDate = ""
        if date != nil {
            let formatService  = DateFormatter()
            formatService.dateFormat = "dd/MM/yyyy"
            strDate = formatService.string(from: date!)
        }
        self.invokeTimeBandsService(strDate, endCallTypeService: { () -> Void in
            if  self.slotsItems?.count > 0 {
                if self.errorView != nil {
                    self.errorView!.removeFromSuperview()
                    self.errorView!.focusError = nil
                    self.errorView = nil
                    self.deliverySchedule!.layer.borderColor = self.deliverySchedule!.textBorderOff
                }
                let selectedSlot = self.slotsItems![0] 
                self.selectedTimeSlotTypeIx = IndexPath(row: 0, section: 0)
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
                self.picker!.cellType = TypeField.check
                self.picker!.showPicker()
            }
            self.removeViewLoad()//ok
            
            self.removeViewLoad()//ok
            
        })
    }

    //MARK: - Services
    var discountAssociateAply:Double = 0.0
    func invokeDiscountActiveService(_ endCallDiscountActive:@escaping (() -> Void)) {
        let discountActive  = GRDiscountActiveService()
        discountActive.callService({ (result:[String:Any]) -> Void in

            if let res = result["discountsAssociated"] as? Bool {
                self.showDiscountAsociate = res//TODO validar flujo
            }
            if let listPromotions = result["listPromotions"] as? [[String:Any]]{
                for promotionln in listPromotions {
                    let promotionDiscount = promotionln["promotionDiscount"] as! Int
                    self.discountAssociateAply = Double(promotionDiscount) / 100.0
                    print("promotionDiscount: \(self.discountAssociateAply)")
                }
            }
            
            endCallDiscountActive()
            }, errorBlock: { (error:NSError) -> Void in
                endCallDiscountActive()
        })
    }
    
    func invokePaymentService(_ endCallPaymentOptions:@escaping (() -> Void)) {
        //self.addViewLoad()
        
        let service = GRPaymentTypeService()
        service.callService("2",
            successBlock: { (result:[Any]) -> Void in
                self.paymentOptionsItems = result as? [[String:Any]]
                if result.count > 0 {
                    let option = result[0] as! [String:Any]
                    if let text = option["paymentType"] as? String {
                        self.paymentOptions!.text = text
                        self.selectedPaymentType = IndexPath(row: 0, section: 0)
                    }
                    if let id = option["id"] as? String {
                        if id == "-1"{
                            self.showPayPalFuturePayment = true
                            self.buildSubViews()
                        }
                    }
                }
                //self.removeViewLoad()
                endCallPaymentOptions()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at invoke payment type service")
                self.removeViewLoad()
                endCallPaymentOptions()
            }
        )
    }
    
    func invokeGetPromotionsService(_ pickerValues: [String:String], discountAssociateItems: [String],endCallPromotions:@escaping ((Bool) -> Void))
    {
        /*if pickerValues.count == discountAssociateItems.count
        {*/
            //self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            //self.alertView!.setMessage("Validando Promociones")
            
            //self.addViewLoad()
        var savinAply : Double = 0.0
        var items = UserCurrentSession.sharedInstance.itemsGR!
        if let savingGR = items["saving"] as? NSNumber {
          savinAply =  savingGR.doubleValue
        
        }
        
            var paramsDic: [String:String] = pickerValues
            paramsDic["isAssociated"] = self.isAssociateSend ? "1":"0"//self.showDiscountAsociate ? "1":"0"
            paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance.estimateTotalGR() - savinAply)"
        paramsDic["addressId"] = self.selectedAddress == nil ? "" : self.selectedAddress
            let promotionsService = GRGetPromotionsService()
        
        print("TOTAL::::\(paramsDic)")
            
            
        self.associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")] ==  nil ? "" : paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        self.dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")] == nil ? "" : paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
        self.determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")] ==  nil ? "" :  paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]

        
            //self.promotionIds! = ""
        
            promotionsService.setParams(paramsDic)
            promotionsService.callService(requestParams: paramsDic as AnyObject, succesBlock: { (resultCall:[String:Any]) -> Void in
                // self.removeViewLoad()
                if resultCall["codeMessage"] as! Int == 0
                {
                    
                    self.newTotal = resultCall["newTotal"] as? Double
                    
                  
                    let totalDiscounts =  resultCall["totalDiscounts"] as? Double
                    self.totalDiscountsOrder = totalDiscounts!
                    self.promotionsDesc = []
                    
                    if let listSamples = resultCall["listSamples"] as? [[String:Any]]{
                        for promotionln in listSamples {
                            let isAsociate = promotionln["isAssociated"] as! Bool
                            self.isAssociateSend = isAsociate
                            let idPromotion = promotionln["idPromotion"] as! Int
                            let promotion = (promotionln["promotion"] as! String).trimmingCharacters(in: CharacterSet.whitespaces)
                            self.promotionsDesc.append(["promotion":promotion,"idPromotion":"\(idPromotion)","selected":"false"])
                        }
                    }
                    if let listPromotions = resultCall["listPromotions"] as? [[String:Any]]{
                        for promotionln in listPromotions {
                            let promotion = promotionln["idPromotion"] as! Int
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: ",\(promotion)", with: "")
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(promotion),", with: "")
                            self.promotionIds! += (self.promotionIds == "") ? "\(promotion)" : ",\(promotion)"
                            print("listPromotions: \(promotion)")
                        }
                    }
                    
                    if let listFreeshippins = resultCall["listFreeshippins"] as? [[String:Any]]{
                        for freeshippin in listFreeshippins {
                             self.idFreeShepping = freeshippin["idPromotion"] as! Int
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: ",\(self.idFreeShepping)", with: "")
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(self.idFreeShepping),", with: "")
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(self.idFreeShepping)", with: "")
                            self.promotionIds! += (self.promotionIds == "") ? "\(self.idFreeShepping)" : ",\(self.idFreeShepping)"
                          
                        }
                    }
                    
                    if self.idFreeShepping == 0 {
                        if let listReferidos = resultCall["listReferidos"] as? [String:Any]{
                            
                            //for promotionln in listReferidos {
                            
                                self.idReferido = listReferidos["idReferido"] as! Int//promotionln["idReferido"] as? Int
                            let  addIdRefered =  listReferidos["numEnviosReferidos"] as! Int
                            if addIdRefered > 0 {
                                self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: ",\(self.idReferido)", with: "")
                                self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(self.idReferido),", with: "")
                                self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(self.idReferido)", with: "")
                                self.promotionIds! += (self.promotionIds == "") ? "\(self.idReferido)" : ",\(self.idReferido)"
                                print("listReferidos: \(self.idReferido)")
                                self.discountsFreeShippingAssociated =  true
                            }
                            //}
                        }
                    }

                    //self.discountAssociate!.setSelectedCheck(true)
                    self.invokeDeliveryTypesService({ () -> Void in
                        //self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                        //self.alertView!.showDoneIcon()
                        self.removeViewLoad()//--
                    })
                    if self.newTotal != nil {
                        self.updateShopButton("\(self.newTotal)")
                        var savinAply : Double = 0.0
                        var items = UserCurrentSession.sharedInstance.itemsGR!
                        if let savingGR = items["saving"] as? NSNumber {
                            savinAply =  savingGR.doubleValue
                        }
                        //NSDecimalNumber(string: String(format: "%.2f", itemPrice)
                        let total = "\(UserCurrentSession.sharedInstance.numberOfArticlesGR())"
                        let subTotal = String(format: "%.2f", self.newTotal)//"\(self.newTotal)"
                        let saving = String(format: "%.2f", self.totalDiscountsOrder + savinAply)//"\(self.totalDiscountsOrder + savinAply)"
                        
                        self.totalView.setTotalValues(total,
                            subtotal: subTotal,
                            saving: saving)
                      
                    }
                    self.buildSubViews()
                    endCallPromotions(true)
                }
                }, errorBlock: {(error: NSError) -> Void in
                    //endCallPromotions()
                    endCallPromotions(false)
                     self.removeViewLoad()//--
                    //self.removeViewLoad()
                    //self.alertView!.setMessage(error.localizedDescription)
                    //self.alertView!.showErrorIcon("Ok")
                    print("Error at invoke address user service")
            })
    }
    
    func invokeDiscountAssociateService(_ pickerValues: [String:String], discountAssociateItems: [String])
    {
        if pickerValues.count == discountAssociateItems.count
        {
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            self.alertView!.setMessage("Validando descuentos")
            
            //self.addViewLoad()
            var paramsDic: [String:String] = pickerValues
            paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance.estimateTotalGR()-UserCurrentSession.sharedInstance.estimateSavingGR())"
            paramsDic["addressId"] = self.selectedAddress == nil ? "" : self.selectedAddress
            
            let discountAssociateService = GRDiscountAssociateService()
            
            
            self.associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
            self.dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
            self.determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]
            
            discountAssociateService.setParams([:])
            discountAssociateService.callService(requestParams: paramsDic as AnyObject, succesBlock: { (resultCall:[String:Any]) -> Void in
               // self.removeViewLoad()
                if resultCall["codeMessage"] as! Int == 0{
                    var items = UserCurrentSession.sharedInstance.itemsGR!
                    //if let savingGR = items["saving"] as? Double {
                    
                    items["saving"] = resultCall["saving"] as? Double //(resultCall["totalDiscounts"] as! NSString).doubleValue - self.amountDiscountAssociate
                    
                    print("\(resultCall["saving"] as? Double)")
           
                    UserCurrentSession.sharedInstance.itemsGR = items as [String:Any]
                    
                    self.totalView.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
                        subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
                        saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
                    self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR() - UserCurrentSession.sharedInstance.estimateSavingGR() + self.shipmentAmount)")
                    
               
                    
                    self.invokeGetPromotionsService(self.picker.textboxValues!,discountAssociateItems: self.picker.itemsToShow, endCallPromotions: { (finish) -> Void in
                        if finish {
                            print("end service from asociate")
                            self.discountAssociate!.setSelectedCheck(true)
                            self.asociateDiscount = true
                            self.isAssociateSend =  true
                            self.discountAssociate!.onBecomeFirstResponder = { () in
                            }
                        }else{
                             self.discountAssociate!.setSelectedCheck(false)
                            self.asociateDiscount = false
                            self.isAssociateSend =  false
                        }
                        
                            self.invokeDeliveryTypesService({ () -> Void in
                                //self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                                //self.alertView!.showDoneIcon()
                            })
                            self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                            self.alertView!.showDoneIcon()
                      
                    })
           
                    
                }else{
                    self.alertView!.setMessage(resultCall["message"] as! String)
                    self.alertView!.showErrorIcon("Ok")
                    print("Error at invoke address user service")
                }
                }, errorBlock: {(error: NSError) -> Void in
                //self.removeViewLoad()
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    print("Error at invoke address user service")
            })
        }else{
        self.validateAssociate(pickerValues, completion: { (result:String) -> Void in
        if result != "" {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        self.alertView?.setMessage("Error en los datos del asociado\(result)")
        self.alertView!.showErrorIcon("Ok")
        }
        })
        }
    }
    
    func invokeAddressUserService(_ endCallAddress:@escaping (() -> Void)) {
        //--self.addViewLoad()
        let service = GRAddressByUserService()
        service.callService(
            { (result:[String:Any]) -> Void in
                if let items = result["responseArray"] as? [[String:Any]] {
                    self.addressItems = items as [[String:Any]]
                    if items.count > 0 {
                        let ixCurrent = 0
                        for dictDir in items {
                            if let preferred = dictDir["preferred"] as? NSNumber {
                                if self.selectedAddress == nil {
                                    if preferred.boolValue == true {
                                        self.selectedAddressIx = IndexPath(row: ixCurrent, section: 0)
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
                                                self.picker!.viewButtonClose.isHidden = true
                                                let delay = 0.7 * Double(NSEC_PER_SEC)
                                                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                                                DispatchQueue.main.asyncAfter(deadline: time) {
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
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
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
                        self.picker!.cellType = TypeField.check
                        self.picker!.showPicker()
                    }
                }

                self.buildSlotsPicker(self.selectedDate)
            })
        }
    }
    
    func invokeDeliveryTypesService(_ endCallTypeService:@escaping (() -> Void)) {
        //--self.addViewLoad()
        let service = GRDeliveryTypeService()
        let shouldFreeShepping = (discountsFreeShippingAssociated && asociateDiscount) || (discountsFreeShippingNotAssociated && !asociateDiscount)
        //Validar self.selectedAddress != nil
        if self.selectedAddress != nil {
            service.setParams("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())", addressId: self.selectedAddress!,isFreeShiping:"\(shouldFreeShepping)")
            service.callService(requestParams: [:],
                successBlock: { (result:[String:Any]) -> Void in
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
                    
                    if self.discountsFreeShippingAssociated {
                        self.shipmentItems!.removeAll()
                        let expressDeliveryCostVal = 0.0
                        self.shipmentItems!.append(["name":"Envio sin costo", "key":"4","cost":expressDeliveryCostVal])
                    }
                    
                    if self.shipmentItems!.count > 0 {
                        let shipName = self.shipmentItems![0] 
                        self.selectedShipmentTypeIx = IndexPath(row: 0, section: 0)
                        self.shipmentType!.text = shipName["name"] as? String
                    }
                    self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR()-UserCurrentSession.sharedInstance.estimateSavingGR()+self.shipmentAmount)")
                    
                    if self.newTotal != nil {
                        var savinAply : Double = 0.0
                        var items = UserCurrentSession.sharedInstance.itemsGR!
                        if let savingGR = items["saving"] as? NSNumber {
                            savinAply =  savingGR.doubleValue
                        }
                        
                        let total = "\(UserCurrentSession.sharedInstance.numberOfArticlesGR())"
                        let subTotal = String(format: "%.2f", self.newTotal)//"\(self.newTotal)"
                        let saving = String(format: "%.2f", self.totalDiscountsOrder + savinAply)//"\(self.totalDiscountsOrder + savinAply)"
                        
                        self.totalView.setTotalValues(total,
                            subtotal: subTotal,
                            saving: saving)
                        
                        self.updateShopButton("\(self.newTotal)")
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
    
    func validateAssociate(_ pickerValues: [String:String], completion: (_ result:String) -> Void) {
        var message = ""
        if pickerValues[NSLocalizedString("checkout.discount.associateNumber", comment:"")] == nil ||  pickerValues[NSLocalizedString("checkout.discount.associateNumber", comment:"")]?.trim() == "" {
            message =  ", Número de asociado requerido"
        }
        else if pickerValues[NSLocalizedString("checkout.discount.dateAdmission", comment:"")] == nil ||  pickerValues[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]?.trim() == ""{
            message =  ", Fecha de ingreso requerida"
        }
        else if pickerValues[NSLocalizedString("checkout.discount.determinant", comment:"")] == nil || pickerValues[NSLocalizedString("checkout.discount.determinant", comment:"")]?.trim() == ""{
            message =  ", Determinante requerido"
        }
        
        completion(message)
        
    }
    
    func reloadUserAddresses(){
        //--self.addViewLoad()

        self.invokeAddressUserService({ () -> Void in
           let _ = self.getItemsTOSelectAddres()
            self.address!.onBecomeFirstResponder = {() in
                self.showAddressPicker()
                //--self.removeViewLoad()
            }
            //TODO 
            let date = Date()
            self.selectedDate = date
            self.deliveryDate!.text = self.dateFmt!.string(from: date)
            //self.buildAndConfigureDeliveryType()

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
                            self.selectedAddressIx = IndexPath(row: ixSelected, section: 0)
                            self.address!.text = text
                        }
                    }
                }
                ixSelected += 1
            }
        }
        return itemsAddress
    }
    
    func invokeTimeBandsService(_ date:String,endCallTypeService:@escaping (() -> Void)) {

            let service = GRTimeBands()
            let params = service.buildParams(date, addressId: self.selectedAddress!)
            service.callService(requestParams: params, successBlock: { (result:[String:Any]) -> Void in
                // var date = self.deliveryDatePicker!.date
                if let day = result["day"] as? String {
                    if let month = result["month"] as? String {
                        if let year = result["year"] as? String {
                            let dateSlot = "\(day)/\(month)/\(year)"
                            let date = self.parseDateString(dateSlot)
                            self.deliveryDate!.text = self.dateFmt!.string(from: date)
                            self.selectedDate = date
                            self.deliveryDatePicker!.date = date
                        }
                    }
                }
                self.slotsItems = result["slots"] as? [[String:Any]]
                //--self.addViewLoad()
                endCallTypeService()
                }) { (error:NSError) -> Void in
                    self.removeViewLoad()
                    self.slotsItems = []
                    endCallTypeService()
            }
        
    }
    
    func parseDateString(_ dateStr:String, format:String="dd/MM/yyyy") -> Date {
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone.current
        dateFmt.dateFormat = format
        return dateFmt.date(from: dateStr)!
    }
    
    //MARK: AlertPickerViewDelegate
    
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            
            if formFieldObj ==  self.paymentOptions! {
                self.addViewLoad()//--ok
                self.paymentOptions!.text = selectedStr
                self.selectedPaymentType = indexPath
                let paymentType: [String:Any] = self.paymentOptionsItems![indexPath.row]
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
                self.addViewLoad()//--ok
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![indexPath.row] 
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddress = addressId
                    
                  
                    
                    
                    self.invokeGetPromotionsService(self.picker.textboxValues!, discountAssociateItems:self.picker.itemsToShow , endCallPromotions: { (finish:Bool) -> Void in
                        print("invokeGetPromotionsService:::promo")
                        if  let selectedAddressHasStoreVal = option["isAddressOk"] as? String {
                            if selectedAddressHasStoreVal == "False" {
                                self.selectedAddressHasStore  = false
                                self.picker!.newItemForm()
                                self.picker!.stopRemoveView = true
                                let delay = 0.5 * Double(NSEC_PER_SEC)
                                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                                DispatchQueue.main.asyncAfter(deadline: time) {
                                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                                    self.alertView!.setMessage(NSLocalizedString("gr.address.field.addressNotOk",comment:""))
                                    self.alertView!.showDoneIconWithoutClose()
                                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                                }
                                return
                            }
                        }
                    })
                  
                }
                
                self.selectedAddressIx = indexPath
                
            }
            if formFieldObj ==  self.shipmentType! {
                  //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_OK.rawValue , label: "")
                self.shipmentType!.text = selectedStr
                self.selectedShipmentTypeIx = indexPath
                let shipment: [String:Any] = self.shipmentItems![indexPath.row]
                self.shipmentAmount = shipment["cost"] as! Double
            }
            if formFieldObj ==  self.deliverySchedule! {
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_TIME_DELIVERY.rawValue , label: "")
                self.deliverySchedule!.text = selectedStr
                self.selectedTimeSlotTypeIx = indexPath
            }
            if formFieldObj ==  self.confirmation! {
                self.confirmation!.text = selectedStr
                self.selectedConfirmation = indexPath

            }
            if formFieldObj == self.discountAssociate!{
                self.addViewLoad()//--ok
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_DISCOUT_ASOCIATE.rawValue , label: "")
                if self.showDiscountAsociate {
                    self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
                    //self.invokeGetPromotionsService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
                 
                }
            }
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {

        if formFieldObj ==  self.paymentOptions! {
            self.paymentOptions!.text = ""
            //self.selectedPaymentType = indexPath
        }
        if formFieldObj ==  self.address! {
            self.address!.text = ""
            //var option = self.addressItems![indexPath.row] as [String:Any]
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
    
    
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    

    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSize(width: frame.width, height: 720)
        sAddredssForm = FormSuperAddressView(frame: CGRect(x: scrollForm.frame.minX, y: 0, width: scrollForm.frame.width, height: 700))
        sAddredssForm.allAddress = self.addressItems as [Any]!
        sAddredssForm.idAddress = ""
        if !self.selectedAddressHasStore{
                let serviceAddress = GRAddressesByIDService()
                serviceAddress.addressId = self.selectedAddress!
                serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
                self.sAddredssForm.addressName.text = result["name"] as! String!
                self.sAddredssForm.outdoornumber.text = result["outerNumber"] as! String!
                self.sAddredssForm.indoornumber.text = result["innerNumber"] as! String!
                self.sAddredssForm.betweenFisrt.text = result["reference1"] as! String!
                self.sAddredssForm.betweenSecond.text = result["reference2"] as! String!
                self.sAddredssForm.zipcode.text = result["zipCode"] as! String!
                self.sAddredssForm.street.text = result["street"] as! String!
                let neighborhoodID = result["neighborhoodID"] as! String!
                let storeID = result["storeID"] as! String!
                self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: neighborhoodID!, storeID: storeID!)
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
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
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
                
                self.picker!.titleLabel.textAlignment = .center
                self.picker!.titleLabel.frame =  CGRect(x: 40, y: self.picker!.titleLabel.frame.origin.y, width: self.picker!.titleLabel.frame.width, height: self.picker!.titleLabel.frame.height)
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
    
    func updateShopButton(_ total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop!.bounds)
            customlabel.backgroundColor = UIColor.clear
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop!.addSubview(customlabel)
            buttonShop!.sendSubview(toBack: customlabel)
        }
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total as NSString)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
        
    }
    
    func shopButtonTaped(){
        if self.payPalFuturePayment{
            self.showPayPalFuturePaymentController()
        }else{
            sendOrderWalmart()
        }
    }


    func sendOrderWalmart() {


        buttonShop?.isEnabled = false
    
        if validate() {
            
            if selectedTimeSlotTypeIx == nil {
                let _ = self.deliverySchedule?.validate()
                buttonShop?.isEnabled = true
                return
            }
            
            if selectedShipmentTypeIx == nil {
                let _ = self.shipmentType?.validate()
                buttonShop?.isEnabled = true
                return
            }
            
            if selectedConfirmation == nil {
                let _ = self.confirmation?.validate()
                buttonShop?.isEnabled = true
                return
            }
            
            let serviceCheck = GRSendOrderService()
            let total = UserCurrentSession.sharedInstance.estimateTotalGR() //- self.savings
            
            let components : DateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: self.selectedDate)
            
            
            let dateMonth = components.month
            let dateYear = components.year
            let dateDay = components.day
            
            let slotSel = self.slotsItems![selectedTimeSlotTypeIx.row]
            let slotSelectedId = slotSel["id"] as! Int
            
            let shipmentTypeSel = self.shipmentItems![selectedShipmentTypeIx.row]
            let shipmentType = shipmentTypeSel["key"] as! String
            self.shipmentAmount = shipmentTypeSel["cost"] as! Double
            
            let confirmTypeSel = self.orderOptionsItems![selectedConfirmation.row]
            let confirmation = confirmTypeSel["key"]
            
            let paymentSel = self.paymentOptionsItems![selectedPaymentType.row]
            let paymentSelectedId = paymentSel["id"] as! String
            
            serviceDetail = OrderConfirmDetailView.initDetail()
            serviceDetail?.delegate = self
            serviceDetail!.showDetail()
            
            let freeShipping = discountsFreeShippingAssociated || discountsFreeShippingNotAssociated
            let discount : Double = self.totalDiscountsOrder
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
           let totalDis = formatter.string(from: NSNumber(value: discount as Double))!

            
            let paramsOrder = serviceCheck.buildParams(total, month: "\(dateMonth)", year: "\(dateYear)", day: "\(dateDay)", comments: self.comments!.text!, paymentType: paymentSelectedId, addressID: self.selectedAddress!, device: getDeviceNum(), slotId: slotSelectedId, deliveryType: shipmentType, correlationId: "", hour: self.deliverySchedule!.text!, pickingInstruction: confirmation!, deliveryTypeString: self.shipmentType!.text!, authorizationId: "", paymentTypeString: self.paymentOptions!.text!,isAssociated:self.asociateDiscount,idAssociated:associateNumber,dateAdmission:dateAdmission,determinant:determinant,isFreeShipping:freeShipping,promotionIds:promotionIds,appId:self.getAppId(),totalDiscounts: Double(totalDis)!)
            
              serviceCheck.callService(requestParams: paramsOrder, successBlock: { (resultCall:[String:Any]) -> Void in
                
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BUY_GR.rawValue , label: "")
                // deliveryAmount
//                let userEmail = UserCurrentSession.sharedInstance.userSigned!.email as String
//                let userName = UserCurrentSession.sharedInstance.userSigned!.profile.name as String
//                let idUser = UserCurrentSession.sharedInstance.userSigned!.profile.user.idUser as String
//                let items :[[String:Any]] = UserCurrentSession.sharedInstance.itemsGR!["items"]! as! [[String:Any]]

                
                
                let purchaseOrderArray = resultCall["purchaseOrder"] as! [Any]
                let purchaseOrder = purchaseOrderArray[0] as! [String:Any]
                
                let trakingNumber = purchaseOrder["trackingNumber"] as! String
                let deliveryDate = purchaseOrder["deliveryDate"] as! NSString
                let paymentTypeString = purchaseOrder["paymentTypeString"] as! String
                let hour = purchaseOrder["hour"] as! String
                let subTotal = purchaseOrder["subTotal"] as! NSNumber
                let total = purchaseOrder["total"] as! NSNumber 
                var authorizationId = ""
                var correlationId = ""
                var deliveryAmount = purchaseOrder["deliveryAmount"] as! Double
                
                //BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: userEmail, userName:userName, gender: "", idUser: idUser, itesShop: items,total:total,refId:trakingNumber)
                
                let discountsAssociated:Double = UserCurrentSession.sharedInstance.estimateTotalGR() * self.discountAssociateAply //
                
                
                if let authorizationIdVal = purchaseOrder["authorizationId"] as? String {
                    authorizationId = authorizationIdVal
                }
                if let correlationIdVal = purchaseOrder["correlationId"] as? String {
                    correlationId = correlationIdVal
                }
                
                if self.idFreeShepping != 0 || self.idReferido != 0{
                    deliveryAmount =  0.0
                }
                let formattedSubtotal = CurrencyCustomLabel.formatString(subTotal.stringValue as NSString)
                let formattedTotal = CurrencyCustomLabel.formatString(total.stringValue as NSString)
                let formattedDeliveryAmount = CurrencyCustomLabel.formatString("\(deliveryAmount)" as NSString)
                let formattedDate = deliveryDate.substring(to: 10)
                let slot = purchaseOrder["slot"] as! [String:Any]
                
                self.confirmOrderDictionary = ["paymentType": paymentSelectedId,"trackingNumber": trakingNumber,"authorizationId": authorizationId,"correlationId": correlationId,"device":self.getDeviceNum()]
                self.cancelOrderDictionary = ["slot": slot,"device": self.getDeviceNum(),"paymentType": paymentSelectedId,"deliveryType": shipmentType,"trackingNumber": trakingNumber]
                self.completeOrderDictionary = ["trakingNumber":trakingNumber, "deliveryDate": formattedDate, "deliveryHour": hour, "paymentType": paymentTypeString, "subtotal": formattedSubtotal, "total": formattedTotal, "deliveryAmount" : "\(formattedDeliveryAmount)","discountsAssociated" : "\(discountsAssociated)"]
                
                
                
                
                //PayPal
                if paymentSelectedId == "-1"{
                    self.showPayPalPaymentController()
                 return
                }
//                
//                if paymentSelectedId == "-3"{
//                    self.invokePaypalUpdateOrderService()
//                }
                
                if !self.asociateDiscount {
                    self.serviceDetail?.completeOrder(trakingNumber, deliveryDate: formattedDate, deliveryHour: hour, paymentType: paymentTypeString, subtotal: formattedSubtotal, total: formattedTotal, deliveryAmount : formattedDeliveryAmount ,discountsAssociated : "0.0")
                }else{
                    self.serviceDetail?.completeOrder(trakingNumber, deliveryDate: formattedDate, deliveryHour: hour, paymentType: paymentTypeString, subtotal: formattedSubtotal, total: formattedTotal, deliveryAmount : formattedDeliveryAmount ,discountsAssociated :self.showDiscountAsociate ? "\(discountsAssociated)" :"0.0")
                
                }
               self.buttonShop?.isEnabled = false
                //self.performSegueWithIdentifier("showOrderDetail", sender: self)
                }) { (error:NSError) -> Void in
                    
                                     
                    self.buttonShop?.isEnabled = true
                   // println("Error \(error)")
                    
                    if error.code == -400 {
                          self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
                    }
                    else {
                       self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
                    }
                    
                    
            }

        }else {
            buttonShop?.isEnabled = true
        }
    }
    
    func showAddressPicker(){
        let itemsAddress : [String] = self.getItemsTOSelectAddres()
        self.picker!.selected = self.selectedAddressIx
        self.picker!.sender = self.address!
        self.picker!.delegate = self
            
        let btnNewAddress = WMRoundButton()
        btnNewAddress.setTitle("nueva", for: UIControlState())
        btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        btnNewAddress.setBackgroundColor(WMColor.light_blue, size: CGSize(width: 64.0, height: 22), forUIControlState: UIControlState())
        btnNewAddress.layer.cornerRadius = 2.0
            
        self.picker!.addRigthActionButton(btnNewAddress)
        self.picker!.setValues(self.address!.nameField, values: itemsAddress)
        self.picker!.hiddenRigthActionButton(false)
        self.picker!.cellType = TypeField.check
        if !self.selectedAddressHasStore {
            self.picker!.onClosePicker = {
                //--self.removeViewLoad()
                self.picker!.onClosePicker = nil
                let _ = self.navigationController?.popViewController(animated: true)
                self.picker!.closePicker()
            }
        }        
        self.picker!.showPicker()
    }
    func closeAlertPk() {
       print("closeAlertPk")
    }
    
    func getDeviceNum() -> String {
        return  IS_IPAD ? "25" : "24"
    }
    
    func validate() -> Bool{
        let error = viewError(deliverySchedule!)
        return !error
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
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: false)
            return true
        }
        return false
    }
    
    func didErrorConfirm() {
        self.dateChanged()
    }
    
    
    func didFinishConfirm() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
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
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    

    
    //MARK: - PayPal
    func showPayPalPaymentController()
    {
        let items :[[String:Any]] = UserCurrentSession.sharedInstance.itemsGR!["items"]! as! [[String:Any]]
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
            let payPalItem = PayPalItem(name: item["description"] as! String, withQuantity:quantity , withPrice: NSDecimalNumber(string: String(format: "%.2f", itemPrice)), withCurrency: "MXN", withSku: item["upc"] as? String)
            payPalItems.append(payPalItem)
        }
        // Los cupones y descuentos se agregan como item negativo.
        let discounts = 0.0 - UserCurrentSession.sharedInstance.estimateSavingGR()
        if discounts < 0
        {
            payPalItems.append(PayPalItem(name: "Descuentos", withQuantity:1 , withPrice: NSDecimalNumber(value: discounts as Double), withCurrency: "MXN", withSku: "0000000000001"))
        }
        let subtotal = PayPalItem.totalPrice(forItems: payPalItems)
        // Optional: include payment details
        let shipping = NSDecimalNumber(value: self.shipmentAmount as Double)
        let tax = NSDecimalNumber(value: 0.0 as Double)
        let paymentDetails = PayPalPaymentDetails(subtotal:subtotal, withShipping: shipping, withTax: tax)
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "MXN", shortDescription: "Walmart", intent: .authorize)
        //payment.custom =
       // payment.items = payPalItems
        //payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.initPayPalConfig(), delegate: self)
            paymentViewController!.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(paymentViewController!, animated: true, completion: nil)
        }
    }
    
    func showPayPalFuturePaymentController(){
        let futurePaymentController = PayPalFuturePaymentViewController(configuration: self.initPayPalConfig(), delegate: self)
        futurePaymentController!.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.present(futurePaymentController!, animated: true, completion: nil)
    }
    
    func initPayPalConfig() -> PayPalConfiguration{
        // Set up payPalConfig
        let payPalConfig = PayPalConfiguration()// default
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Walmart"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.rememberUser = true
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0] 
        payPalConfig.payPalShippingAddressOption = .provided
        return payPalConfig
    }
    
    func getPayPalEnvironment() -> String{
        let payPalEnvironment =  Bundle.main.object(forInfoDictionaryKey: "WMPayPalEnvironment") as! [String:Any]
        let environment = payPalEnvironment["PayPalEnvironment"] as! String
        
        if environment == "SANDBOX"{
            return PayPalEnvironmentSandbox
        }
        else if  environment == "PRODUCTION"{
             return PayPalEnvironmentProduction
        }
        
        return PayPalEnvironmentNoNetwork
    }
    
    func invokePaypalUpdateOrderService(_ authorizationId:String,paymentType:String,idAuthorization:String){
        let updatePaypalService = GRPaypalUpdateOrderService()
        self.confirmOrderDictionary["authorizationId"] = authorizationId
        self.confirmOrderDictionary["correlationId"] = PayPalMobile.clientMetadataID()
        self.confirmOrderDictionary["paymentType"] = paymentType
        self.confirmOrderDictionary["authorization"] = idAuthorization
        self.confirmOrderDictionary["amount"] = (UserCurrentSession.sharedInstance.estimateTotalGR() + Double(self.completeOrderDictionary["deliveryAmount"] as! String)!)
        print("idAuthorization::::\(idAuthorization)::::")

        updatePaypalService.callServiceConfirmOrder(requestParams: self.confirmOrderDictionary, succesBlock: {(result:[String:Any]) -> Void in
        self.serviceDetail?.completeOrder(self.completeOrderDictionary["trakingNumber"] as! String, deliveryDate: self.completeOrderDictionary["deliveryDate"] as! String, deliveryHour: self.completeOrderDictionary["deliveryHour"] as! String, paymentType: self.completeOrderDictionary["paymentType"] as! String, subtotal: self.completeOrderDictionary["subtotal"] as! String, total: self.completeOrderDictionary["total"] as! String, deliveryAmount : self.completeOrderDictionary["deliveryAmount"] as! String, discountsAssociated: self.completeOrderDictionary["discountsAssociated"] as! String)

               
            
            }, errorBlock: { (error:NSError) -> Void in
                if error.code == -400 {
                    self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
                }
                else {
                    self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
                }
        })
    }
    
    func invokePayPalCancelService(_ message: String){
        let cancelPayPalService = GRPaypalUpdateOrderService()
        cancelPayPalService.callServiceCancelOrder(requestParams: self.cancelOrderDictionary, succesBlock: {(result:[String:Any]) -> Void in
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
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        buttonShop?.isEnabled = true
        let message = "Tu pago ha sido cancelado"
        self.invokePayPalCancelService(message)
        self.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        print(completedPayment.description)
        
       
        if let completeDict = completedPayment.confirmation["response"] as? [String:Any] {
            if let idPayPal = completeDict["id"] as? String {
                if let idAuthorization = completeDict["authorization_id"] as? String {
                    self.invokePaypalUpdateOrderService(idPayPal,paymentType:"-1",idAuthorization:idAuthorization)
                }
            }
        }

      
        
        buttonShop?.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
     // PayPalFuturePaymentDelegate
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        buttonShop?.isEnabled = true
        //let message = "Hubo un error al momento de generar la orden, intenta más tarde"
        //self.invokePayPalCancelService(message)
        self.sendOrderWalmart()
        self.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        
        // send authorization to your server to get refresh token.
        print(futurePaymentAuthorization.description)
        let futurePaymentService = GRPayPalFuturePaymentService()
        let responce = futurePaymentAuthorization["response"] as! [AnyHashable: Any]
        futurePaymentService.callService(responce["code"] as! String, succesBlock: {(result:[String:Any]) -> Void in
            //self.invokePaypalUpdateOrderService("",paymentType:"-3")
             //self.showPayPalPaymentController()
                self.sendOrderWalmart()
            }, errorBlock: { (error:NSError) -> Void in
                //Mandar alerta
                //let message = "Hubo un error al momento de generar la orden, intenta más tarde"
                //self.invokePayPalCancelService(message)
                self.sendOrderWalmart()
        })
        buttonShop?.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func getAppId() -> String{
        return "\(UserCurrentSession.systemVersion()) \(UserCurrentSession.currentDevice())"
    }
    
    
    override func back() {
        super.back()
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BACK_TO_SHOPPING_CART.rawValue , label: "")
    }
    
    

}
