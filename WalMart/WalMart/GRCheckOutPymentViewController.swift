//
//  GRCheckOutPymentViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import Tune


class GRCheckOutPymentViewController : NavigationViewController,UIWebViewDelegate,TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate,UIPickerViewDelegate,AlertPickerViewDelegate,OrderConfirmDetailViewDelegate,PayPalPaymentDelegate, PayPalFuturePaymentDelegate,GenerateOrderViewDelegate{
    
    var content: TPKeyboardAvoidingScrollView!
    
    var cancelShop : UIButton?
    var confirmShop : UIButton?
    var sectionTitleDiscount : UILabel!
    var sectionTitlePayments : UILabel!
    
    var sectionPaypalTitle : UILabel!
    
    var contenPayments  : UIView!
    var stepLabel: UILabel!
    
    var alertView : IPOWMAlertViewController? = nil
    var selectedAddress: String? = nil
    
    //asiciate
    var associateNumber : String! = ""
    var dateAdmission : String! = ""
    var determinant : String! = ""
    var asociateDiscount : Bool = false
    var isAssociateSend : Bool =  false
    var discountsFreeShippingAssociated : Bool = false
    var totalDiscountsOrder : Double! = 0
    var newTotal : Double!
    
    let margin:  CGFloat = 15.0
    let fheight: CGFloat = 44.0
    let lheight: CGFloat = 25.0
    
    let itemsPayments = [NSLocalizedString("En linea", comment:""), NSLocalizedString("Contra entrega", comment:"")]
    
    //Services
    var paymentOptionsItems: [AnyObject]?
    var paymentOptions: FormFieldView?
    var selectedPaymentType : NSIndexPath!
   
    var promotionsDesc: [[String:String]]! = []
    var showDiscountAsociate : Bool = false
    var promotionButtons: [UIView]! = []
    var discountAssociateAply:Double = 0.0 //descuento del Asociado
    var discountAssociate: FormFieldView?
    var picker : AlertPickerView!
    var selectedConfirmation : NSIndexPath!
    var idFreeShepping : Int! = 0
    var idReferido : Int! = 0
    var shipmentAmount: Double!
    
    var paymentOptionsView : PaymentOptionsView!
    var paymentId = "0"
    var paymentString = ""
    var paramsToOrder : NSMutableDictionary?
    var paramsToConfirm : NSMutableDictionary?
    
    //Paypal
    var payPalFuturePaymentField: FormFieldView?
    var payPalFuturePayment : Bool = false
    var showPayPalFuturePayment : Bool = false //iniciar en false
    
    var confirmOrderDictionary: [String:AnyObject]! = [:]
    var cancelOrderDictionary:  [String:AnyObject]! = [:]
    var completeOrderDictionary: [String:AnyObject]! = [:]
    
    //Confirmation view
    var serviceDetail : OrderConfirmDetailView? = nil
    var confirmOrderView : GenerateOrderView? = nil
    
    var generateOrderTotal = ""
    var generateOrderSubtotal = ""
    var generateOrderDiscounts = ""
    var generateOrderPaymentType = ""
    
    var viewLoad : WMLoadingView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
//    
//    func paramsFromOrder(month:String, year:String, day:String, comments:String, addressID:String, deliveryType:String,hour:String, pickingInstruction:String, deliveryTypeString:String,slotId:Int,shipmentAmount:Double!){
//        self.shipmentAmount = shipmentAmount
//        self.paramsToOrder = ["month":month, "year":year, "day":day, "comments":comments, "AddressID":addressID,  "slotId":slotId, "deliveryType":deliveryType, "hour":hour, "pickingInstruction":pickingInstruction, "deliveryTypeString":deliveryTypeString,"shipmentAmount":shipmentAmount]
//    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 25.0
        
        self.view.backgroundColor =  UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("Método de Pago", comment:"")
        
        if IS_IPAD {
            self.backButton?.hidden = true
        }
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "3 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, 46, self.view.bounds.width, self.view.bounds.height - (46 + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.view.addSubview(self.content)
        
        sectionPaypalTitle = self.buildSectionTitle(NSLocalizedString("Pago en linea", comment:""), frame: CGRectMake(16,16.0, self.view.frame.width, lheight))
        sectionPaypalTitle.hidden =  true
        
        self.content.addSubview(sectionPaypalTitle)
        
        sectionTitlePayments = self.buildSectionTitle(NSLocalizedString("Pago contra entrega", comment:""), frame: CGRectMake(16,16.0, self.view.frame.width, lheight))
        self.content.addSubview(sectionTitlePayments)
        
        
        self.contenPayments =  UIView()
        self.content.addSubview(self.contenPayments)
        
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRectMake(16, self.contenPayments!.frame.maxY + 20.0, self.view.frame.width, lheight))
        self.content.addSubview(self.sectionTitleDiscount)
        
        picker = AlertPickerView.initPickerWithDefault()
        
        self.discountAssociate = FormFieldView(frame: CGRectMake(margin,sectionTitleDiscount.frame.maxY ,width,fheight))
        self.discountAssociate!.setCustomPlaceholder(NSLocalizedString("checkout.field.discountAssociate", comment:""))
        self.discountAssociate!.isRequired = false
        self.discountAssociate!.typeField = TypeField.Check
        self.discountAssociate!.setImageTypeField()
        self.discountAssociate!.nameField = NSLocalizedString("checkout.field.discountAssociate", comment:"")
        self.content.addSubview(self.discountAssociate!)
        
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
            
            //self.removeViewLoad()
        }
        
        //views
        
        self.content.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.maxY + 20.0)
        
        self.paymentOptions = FormFieldView(frame: CGRectMake(margin, 10.0, width, fheight))
        self.paymentOptions!.setCustomPlaceholder(NSLocalizedString("checkout.field.paymentOptions", comment:""))
        self.paymentOptions!.isRequired = true
        self.paymentOptions!.typeField = TypeField.List
        self.paymentOptions!.setImageTypeField()
        self.paymentOptions!.nameField = NSLocalizedString("checkout.field.paymentOptions", comment:"")
        
        //Buttons
        self.cancelShop =  UIButton()
        cancelShop?.setTitle(NSLocalizedString("Cancelar", comment: ""), forState:.Normal)
        cancelShop?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelShop?.backgroundColor = WMColor.empty_gray_btn
        cancelShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelShop?.layer.cornerRadius = 16
        cancelShop?.addTarget(self, action: "cancelPurche", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelShop!)
        
        self.confirmShop =  UIButton()
        confirmShop?.setTitle(NSLocalizedString("Confirmar", comment: ""), forState:.Normal)
        confirmShop?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        confirmShop?.backgroundColor = WMColor.green
        confirmShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        confirmShop?.layer.cornerRadius = 16
        confirmShop?.addTarget(self, action: "continuePurche", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(confirmShop!)
        
        
        
        self.payPalFuturePaymentField = FormFieldView(frame: CGRectMake(margin,paymentOptions!.frame.maxY + 10.0,width,fheight))
        self.payPalFuturePaymentField!.setCustomPlaceholder("PayPal pagos futuros")
        self.payPalFuturePaymentField!.isRequired = true
        self.payPalFuturePaymentField!.typeField = TypeField.Check
        self.payPalFuturePaymentField!.setImageTypeField()
        self.payPalFuturePaymentField!.nameField = "PayPal pagos futuros"
        self.content.addSubview(self.payPalFuturePaymentField!)
        
        //Services
        self.invokeDiscountActiveService { () -> Void in
            self.invokeGetPromotionsService([:], discountAssociateItems: []) { (finish:Bool) -> Void in
                self.buildPromotionButtons()
                self.buildSubViews()
                //--
                self.invokePaymentService { () -> Void in
                    print("End")
                    self.paymentOptionsView =  PaymentOptionsView(frame: CGRectMake(0, 0,self.view!.frame.width,self.view!.frame.height) , items:self.paymentOptionsItems!)
                    self.paymentOptionsView.selectedOption  = {(selected :String, stringselected:String) -> Void in
                        self.paymentString = stringselected
                        self.paymentId = selected
                    }
                    
                    self.contenPayments?.addSubview(self.paymentOptionsView)
                    self.removeViewLoad()
                }
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
        
        self.addViewLoad()
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width - (2 * margin)
        let bounds = self.view.frame.size
        let footerHeight : CGFloat = 60.0
        
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)
        
        self.content!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - (self.header!.frame.height + footerHeight))
        if self.showPayPalFuturePayment {
            self.sectionPaypalTitle.frame = CGRectMake(16,16.0, self.view.frame.width, lheight)
            self.sectionTitlePayments.frame =  CGRectMake(16,self.payPalFuturePaymentField!.frame.maxY, self.view.frame.width, lheight)
            sectionPaypalTitle.hidden =  false
        }else{
            sectionPaypalTitle.hidden =  true
            self.sectionTitlePayments.frame =  CGRectMake(16,16.0, self.view.frame.width, lheight)
        }
        
        
        
        self.contenPayments.frame = CGRectMake(16,self.sectionTitlePayments.frame.maxY ,self.view.frame.width - 32 , 320)
        sectionTitleDiscount.frame = CGRectMake(16, self.contenPayments!.frame.maxY + 16, width, lheight)
        
        self.paymentOptions!.frame = CGRectMake(16, self.sectionTitleDiscount!.frame.minY,  self.paymentOptions!.frame.width , fheight)
        
        self.cancelShop!.frame = CGRectMake((self.view.frame.width/2) - 148,self.view.bounds.height - 65 + 16, 140, 34)
        self.confirmShop!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.view.bounds.height - 65 + 16, 140, 34)
        
    }
    
    
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    
    
    func cancelPurche (){
        self.back()
    }
    
    
    func continuePurche (){
        
        self.confirmOrderView  = GenerateOrderView.initDetail()
        self.confirmOrderView!.delegate  =  self
        self.confirmOrderView?.showDetail()
        self.generateOrderPaymentType =  self.paymentString
        
        self.paramsToConfirm!["total"] = "1500"
        self.paramsToConfirm!["total"] = "1339"
        self.paramsToConfirm!["subtotal"] = "1300"
        self.paramsToConfirm!["Discounts"] = "200"
        self.paramsToConfirm!["PaymentType"] = "Efectivo"
        self.confirmOrderView?.showGenerateOrder(self.paramsToConfirm!)
        self.paramsToConfirm!["shipmentAmount"] = self.discountsFreeShippingAssociated ? "0.0" :self.paramsToConfirm!["shipmentAmount"]
        self.paramsToConfirm!["total"] = generateOrderTotal
        self.paramsToConfirm!["subtotal"] = generateOrderSubtotal
        self.paramsToConfirm!["Discounts"] = generateOrderDiscounts
        self.paramsToConfirm!["PaymentType"] = generateOrderPaymentType
        self.confirmOrderView?.showConfirmOrder(self.paramsToConfirm!)
    }
    
    func sendOrder(){
        
        let serviceCheck = GRSendOrderService()
        
        serviceDetail = OrderConfirmDetailView.initDetail()
        serviceDetail?.delegate = self
        serviceDetail!.showDetail()
        
        let total = UserCurrentSession.sharedInstance().estimateTotalGR()
        
        let freeShipping = discountsFreeShippingAssociated
        let discount : Double = self.totalDiscountsOrder
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let totalDis = formatter.stringFromNumber(NSNumber(double:discount))!
        
        
        //Recibir por parametros
        let dateMonth = self.paramsToOrder!["month"] as! Int//03
        let dateYear = self.paramsToOrder!["year"] as! Int//2016
        let dateDay = self.paramsToOrder!["day"] as! Int//20
        let commensOrder = self.paramsToOrder!["comments"] as? String//"Recibios por parametros"
        let addresId =  self.paramsToOrder!["AddressID"]  as?  String //"4567890cuytrcts"
        let slotId = self.paramsToOrder!["slotId"] as? Int//1
        let deliveryType = self.paramsToOrder!["deliveryType"] as? String//"3"
        let deliveryTypeString = self.paramsToOrder!["deliveryTypeString"] as? String//"Entrega Programada - $44"
        let deliverySchedule = self.paramsToOrder!["hour"] as? String//"11:00 - 12:00"
        let pickingInstruction = self.paramsToOrder!["pickingInstruction"] as! Int//"3"
        
        let paramsOrder = serviceCheck.buildParams(total, month: "\(dateMonth)", year: "\(dateYear)", day: "\(dateDay)", comments: commensOrder!, paymentType: self.paymentId, addressID: addresId!, device: getDeviceNum(), slotId: slotId!, deliveryType: deliveryType!, correlationId: "", hour: deliverySchedule!, pickingInstruction:"\(pickingInstruction)" , deliveryTypeString: deliveryTypeString!, authorizationId: "", paymentTypeString:
            self.paymentString,isAssociated:self.asociateDiscount,idAssociated:associateNumber,dateAdmission:dateAdmission,determinant:determinant,isFreeShipping:freeShipping,promotionIds:promotionIds,appId:self.getAppId(),totalDiscounts: Double(totalDis)!)
        
        serviceCheck.jsonFromObject(paramsOrder)
        
        
        serviceCheck.callService(requestParams: paramsOrder, successBlock: { (resultCall:NSDictionary) -> Void in
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BUY_GR.rawValue , label: "")
            // deliveryAmount
            let userEmail = UserCurrentSession.sharedInstance().userSigned!.email as String
            let userName = UserCurrentSession.sharedInstance().userSigned!.profile.name as String
            let idUser = UserCurrentSession.sharedInstance().userSigned!.profile.user.idUser as String
            let items :[[String:AnyObject]] = UserCurrentSession.sharedInstance().itemsGR!["items"]! as! [[String:AnyObject]]
            
            
            
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
            var deliveryAmount = purchaseOrder["deliveryAmount"] as! Double
            
            BaseController.sendTuneAnalytics(TUNE_EVENT_PURCHASE, email: userEmail, userName:userName, gender: "", idUser: idUser, itesShop: items,total:total,refId:trakingNumber)
            
            let discountsAssociated:Double = UserCurrentSession.sharedInstance().estimateTotalGR() * self.discountAssociateAply //
            
            
            if let authorizationIdVal = purchaseOrder["authorizationId"] as? String {
                authorizationId = authorizationIdVal
            }
            if let correlationIdVal = purchaseOrder["correlationId"] as? String {
                correlationId = correlationIdVal
            }
            
            if self.idFreeShepping != 0 || self.idReferido != 0{
                deliveryAmount =  0.0
            }
            let formattedSubtotal = CurrencyCustomLabel.formatString(subTotal.stringValue)
            let formattedTotal = CurrencyCustomLabel.formatString(total.stringValue)
            let formattedDeliveryAmount = CurrencyCustomLabel.formatString("\(deliveryAmount)")
            let formattedDate = deliveryDate.substringToIndex(10)
            let slot = purchaseOrder["slot"] as! NSDictionary
            
            self.confirmOrderDictionary = ["paymentType": self.paymentId,"trackingNumber": trakingNumber,"authorizationId": authorizationId,"correlationId": correlationId,"device":self.getDeviceNum()]
            self.cancelOrderDictionary = ["slot": slot,"device": self.getDeviceNum(),"paymentType": self.paymentId,"deliveryType": deliveryType!,"trackingNumber": trakingNumber]
            self.completeOrderDictionary = ["trakingNumber":trakingNumber, "deliveryDate": formattedDate, "deliveryHour": hour, "paymentType": paymentTypeString, "subtotal": formattedSubtotal, "total": formattedTotal, "deliveryAmount" : "\(formattedDeliveryAmount)","discountsAssociated" : "\(discountsAssociated)"]
            
            
            
            
            //PayPal
            if self.paymentId == "-1"{
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
            
            
            //self.buttonShop?.enabled = false
            
            
            //self.performSegueWithIdentifier("showOrderDetail", sender: self)
            
            }) { (error:NSError) -> Void in
                
                
                //  self.buttonShop?.enabled = true
                // println("Error \(error)")
                
                if error.code == -400 {
                    self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
                }
                else {
                    self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
                }
          }
        
    }
    
    //MARK : OrderConfirmDetailViewDelegate
    func didFinishConfirm() {
        self.navigationController?.popToRootViewControllerAnimated(true)
          //self.dateChanged()
    }
    
    func didErrorConfirm() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRectMake(0, 0, 341, 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
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
        
        let payment = PayPalPayment(amount: total, currencyCode: "MXN", shortDescription: "Walmart", intent: .Authorize)
        
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
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Walmart"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.rememberUser = true
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        payPalConfig.payPalShippingAddressOption = .Provided
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
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPointMake(self.picker!.center.x, self.picker!.center.y - 100)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }
    
    
    //MARK: InvokeServices
    
    func invokeGetPromotionsService(pickerValues: [String:String], discountAssociateItems: [String],endCallPromotions:((Bool) -> Void))
    {
        var savinAply : Double = 0.0
        var items = UserCurrentSession.sharedInstance().itemsGR as! [String:AnyObject]
        if let savingGR = items["saving"] as? NSNumber {
            savinAply =  savingGR.doubleValue
            
        }
        
        var paramsDic: [String:String] = pickerValues
        paramsDic["isAssociated"] =  self.isAssociateSend ? "1":"0"
        paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance().estimateTotalGR() - savinAply)"
        paramsDic["addressId"] = self.paramsToOrder!["AddressID"] as? String
        let promotionsService = GRGetPromotionsService()
        
        //        self.associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")] ==  nil ? "" : paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        //        self.dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")] == nil ? "" : paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
        //        self.determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")] ==  nil ? "" :  paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]
        
        
        //self.promotionIds! = ""
        
        promotionsService.setParams(paramsDic)
        promotionsService.callService(requestParams: paramsDic, succesBlock: { (resultCall:NSDictionary) -> Void in
            // self.removeViewLoad()
            if resultCall["codeMessage"] as! Int == 0
            {
                
                self.newTotal = resultCall["newTotal"] as? Double
                
                let totalDiscounts =  resultCall["totalDiscounts"] as? Double
                self.totalDiscountsOrder = totalDiscounts!
                self.promotionsDesc = []
                
                if let listSamples = resultCall["listSamples"] as? [AnyObject]{
                    for promotionln in listSamples {
                        let isAsociate = promotionln["isAssociated"] as! Bool
                        self.isAssociateSend = isAsociate
                        let idPromotion = promotionln["idPromotion"] as! Int
                        let promotion = (promotionln["promotion"] as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        self.promotionsDesc.append(["promotion":promotion,"idPromotion":"\(idPromotion)","selected":"false"])
                    }
                }
                if let listPromotions = resultCall["listPromotions"] as? [AnyObject]{
                    for promotionln in listPromotions {
                        let promotion = promotionln["idPromotion"] as! Int
                        self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString(",\(promotion)", withString: "")
                        self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(promotion),", withString: "")
                        self.promotionIds! += (self.promotionIds == "") ? "\(promotion)" : ",\(promotion)"
                        print("listPromotions: \(promotion)")
                    }
                }
                
                if let listFreeshippins = resultCall["listFreeshippins"] as? [AnyObject]{
                    for freeshippin in listFreeshippins {
                        self.idFreeShepping = freeshippin["idPromotion"] as! Int
                        self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString(",\(self.idFreeShepping)", withString: "")
                        self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(self.idFreeShepping),", withString: "")
                        self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(self.idFreeShepping)", withString: "")
                        self.promotionIds! += (self.promotionIds == "") ? "\(self.idFreeShepping)" : ",\(self.idFreeShepping)"
                        
                    }
                }
                
                if self.idFreeShepping == 0 {
                    if let listReferidos = resultCall["listReferidos"] as? NSDictionary{
                        self.idReferido = listReferidos["idReferido"] as! Int
                        let  addIdRefered =  listReferidos["numEnviosReferidos"] as! Int
                        if addIdRefered > 0 {
                            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString(",\(self.idReferido)", withString: "")
                            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(self.idReferido),", withString: "")
                            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(self.idReferido)", withString: "")
                            self.promotionIds! += (self.promotionIds == "") ? "\(self.idReferido)" : ",\(self.idReferido)"
                            print("listReferidos: \(self.idReferido)")
                            self.discountsFreeShippingAssociated =  true
                        }
                    }
                }
                
                //                self.invokeDeliveryTypesService({ () -> Void in
                //                    //self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                //                    //self.alertView!.showDoneIcon()
                //                    self.removeViewLoad()//--
                //                })
                
                if self.newTotal != nil {
                    print("Boton Comprar :: \(self.newTotal)")
                    //self.updateShopButton("\(self.newTotal)")
                    var savinAply : Double = 0.0
                    var items = UserCurrentSession.sharedInstance().itemsGR as! [String:AnyObject]
                    if let savingGR = items["saving"] as? NSNumber {
                        savinAply =  savingGR.doubleValue
                    }
                    let total = "\(UserCurrentSession.sharedInstance().numberOfArticlesGR())"
                    let subTotal = String(format: "%.2f", self.newTotal)
                    let saving = String(format: "%.2f", self.totalDiscountsOrder + savinAply)
                    
                    let dSaving = NSNumberFormatter().numberFromString(saving)
                    let dSubtotal = NSNumberFormatter().numberFromString(subTotal)
                    let subNewTotal = dSubtotal!.doubleValue + dSaving!.doubleValue
                    
                    self.generateOrderTotal = "\(total)"
                    self.generateOrderSubtotal = "\(subNewTotal)"
                    self.generateOrderDiscounts = "\(saving)"
                    self.generateOrderPaymentType =  self.paymentString
                    
                    print("Total de artiulos \(total)")
                    print("subTotal :: \(subTotal)")
                    print("saving::\(saving)")
                    print("subNewTotal :: \(subNewTotal)")
                    
                    //                    self.totalView.setTotalValues(total,
                    //                        subtotal: subTotal,
                    //                        saving: saving)
                    
                }
                self.buildSubViews()
                
                endCallPromotions(true)
            }
            }, errorBlock: {(error: NSError) -> Void in
                endCallPromotions(false)
                print("Error at invoke address user service")
        })
    }
    
    
    //valida si se presenta el descuento de asociado
    
    func invokeDiscountActiveService(endCallDiscountActive:(() -> Void)) {
        let discountActive  = GRDiscountActiveService()
        discountActive.callService({ (result:NSDictionary) -> Void in
            
            if let res = result["discountsAssociated"] as? Bool {
                self.showDiscountAsociate = res
            }
            if let listPromotions = result["listPromotions"] as? [AnyObject]{
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
    
    
    
    func invokePaymentService(endCallPaymentOptions:(() -> Void)) {
        
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
                            //self.buildSubViews()
                        }
                    }
                }
                //self.removeViewLoad()
                endCallPaymentOptions()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at invoke payment type service")
                //self.removeViewLoad()
                endCallPaymentOptions()
            }
        )
    }
    
    func invokeDiscountAssociateService(pickerValues: [String:String], discountAssociateItems: [String])
    {
        if pickerValues.count == discountAssociateItems.count
        {
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),
                imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            
            self.alertView!.setMessage("Validando descuentos")
            
            //self.addViewLoad()
            var paramsDic: [String:String] = pickerValues
            paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR())"
            paramsDic["addressId"] = self.selectedAddress == nil ? "" : self.selectedAddress
            
            let discountAssociateService = GRDiscountAssociateService()
            
            
            self.associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
            self.dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
            self.determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]
            
            discountAssociateService.setParams([:])
            discountAssociateService.callService(requestParams: paramsDic, succesBlock: { (resultCall:NSDictionary) -> Void in
                // self.removeViewLoad()
                if resultCall["codeMessage"] as! Int == 0{
                    var items = UserCurrentSession.sharedInstance().itemsGR as! [String:AnyObject]
                    //if let savingGR = items["saving"] as? Double {
                    
                    items["saving"] = resultCall["saving"] as? Double //(resultCall["totalDiscounts"] as! NSString).doubleValue - self.amountDiscountAssociate
                    
                    print("\(resultCall["saving"] as? Double)")
                    
                    UserCurrentSession.sharedInstance().itemsGR = items as NSDictionary
                    
                    print("# de productos:: \(UserCurrentSession.sharedInstance().numberOfArticlesGR())")
                    print("Subtotal:: \(UserCurrentSession.sharedInstance().estimateTotalGR())")
                    print("Saving:: \( UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")")
                    print("Comprar:: \(UserCurrentSession.sharedInstance().estimateTotalGR() - UserCurrentSession.sharedInstance().estimateSavingGR() + self.shipmentAmount)")
                    
                    
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
                        //TODO invocar servico para actualizar cosntos de envio
                        //                        self.invokeDeliveryTypesService({ () -> Void in
                        //
                        //                        })
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
    
    //MARK: InvokeServices - Paypal
    
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
    
    func invokePaypalUpdateOrderService(authorizationId:String,paymentType:String,idAuthorization:String){
        let updatePaypalService = GRPaypalUpdateOrderService()
        self.confirmOrderDictionary["authorizationId"] = authorizationId
        self.confirmOrderDictionary["correlationId"] = PayPalMobile.clientMetadataID()
        self.confirmOrderDictionary["paymentType"] = paymentType
        self.confirmOrderDictionary["authorization"] = idAuthorization
        print("idAuthorization::::\(idAuthorization)::::")
        
        updatePaypalService.callServiceConfirmOrder(requestParams: self.confirmOrderDictionary, succesBlock: {(result:NSDictionary) -> Void in
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
    

    //MARK: Actions
    
    func validateAssociate(pickerValues: [String:String], completion: (result:String) -> Void) {
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
        
        completion(result: message)
        
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
                //posY += CGFloat(40 * count)
                
                let titleLabel = UILabel(frame:CGRectMake(22, 0, widthField-22,fheight))
                titleLabel.font = WMFont.fontMyriadProRegularOfSize(13)
                titleLabel.text = promotion["promotion"]
                titleLabel.numberOfLines = 2
                titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                titleLabel.textColor = WMColor.dark_gray
                
                let promSelect = UIButton(frame: CGRectMake(margin,posY,widthField,fheight))
                promSelect.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
                promSelect.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
                promSelect.addTarget(self, action: "promCheckSelected:", forControlEvents: UIControlEvents.TouchUpInside)
                promSelect.addSubview(titleLabel)
                promSelect.selected = false
                promSelect.tag = count
                promSelect.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,widthField - 20)
                self.content.addSubview(promSelect)
                self.promotionButtons.append(promSelect)
                count++
                posY += 50
            }
            
            // self.hasPromotionsButtons = true
        }
        else{
            posY += CGFloat(40 * self.promotionsDesc.count)
        }
        return posY
    }
    
    func buildSubViews(){
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.content!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - (self.header!.frame.height + footerHeight))
        for view in self.promotionButtons{
            view.removeFromSuperview()
        }
        
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        
        let margin: CGFloat = 15.0
        let widthField = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        //let lheight: CGFloat = 25.0
        
        self.payPalFuturePaymentField!.alpha = 0
        
        if showPayPalFuturePayment{
            self.payPalFuturePaymentField!.alpha = 1
        }
        
        
        self.paymentOptions!.frame = CGRectMake(margin, self.paymentOptions!.frame.minY, widthField, fheight)
        
        var posY  = self.view.frame.maxY
        if showDiscountAsociate
        {
            self.discountAssociate!.alpha = 1
            self.sectionTitleDiscount!.alpha = 1
            
            self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.sectionPaypalTitle!.frame.maxY , widthField, fheight)
            self.discountAssociate!.frame = CGRectMake(margin,sectionTitleDiscount.frame.maxY,widthField,fheight)
            posY = self.buildPromotionButtons()
            print("posY ::: posY \(posY)")
            
        } else {
            if self.promotionsDesc.count > 0 {
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 1
                self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.sectionPaypalTitle!.frame.maxY + 10.0, widthField, fheight)
                posY = self.buildPromotionButtons()
                print("posY ::: posY \(posY)")
            }else{
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 0
                self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.sectionPaypalTitle!.frame.maxY + 10.0, widthField, fheight)
            }
        }
        
        self.content.contentSize = CGSizeMake(self.view.frame.width, posY + 10.0)
        
    }
    
    var afterButton :UIButton?
    var promotionSelect: String! = ""
    var promotionIds: String! = ""
    
    func promCheckSelected(sender: UIButton){
        //self.promotionIds! = ""
        if promotionSelect != ""{
            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString(",\(promotionSelect)", withString: "")
            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(promotionSelect)", withString: "")
        }
        if(sender.selected){
            sender.selected = false
            self.promotionsDesc[sender.tag]["selected"] = "false"
        }
        else{
            
            if afterButton != nil{
                afterButton!.selected = false
                if afterButton!.tag < self.promotionsDesc.count {
                    self.promotionsDesc[afterButton!.tag]["selected"] = "false"
                }
            }
            
            sender.selected = true
            afterButton = sender
            self.promotionsDesc[sender.tag]["selected"] = "true"
        }
        
        for prom in self.promotionsDesc{
            if prom["selected"] == "true" {
                
                let idPromotion = prom["idPromotion"]!
                promotionSelect = idPromotion
                self.promotionIds! += (self.promotionIds == "") ? "\(idPromotion)" : ",\(idPromotion)"
            }
        }
        
        print("promosiones:::: \(self.promotionIds) :::")
    }
    
    func getDeviceNum() -> String {
        return  "24"
    }
    
    func getAppId() -> String{
        return "\(UserCurrentSession.systemVersion()) \(UserCurrentSession.currentDevice())"
    }
    
    
    
    //MARK: AlertPickerViewDelegate
    
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            
            if formFieldObj == self.discountAssociate!{
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_DISCOUT_ASOCIATE.rawValue , label: "")
                if self.showDiscountAsociate {
                    //self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
                    
                }
            }
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            
            if formFieldObj == self.discountAssociate!{
                self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
            }
            
        }
    }
    
    func viewReplaceContent(frame: CGRect) -> UIView! {
        let view =  UIView()
        return view
    }
    
    func saveReplaceViewSelected() {
        
    }
    func buttomViewSelected(sender: UIButton) {
        
    }
    
    
    //MARK: PayPalPaymentDelegate
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        let message = "Tu pago ha sido cancelado"
        self.invokePayPalCancelService(message)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        print("PayPal Payment Success !")
        print(completedPayment!.description)
        
        
        if let completeDict = completedPayment.confirmation["response"] as? [String:AnyObject] {
            if let idPayPal = completeDict["id"] as? String {
                if let idAuthorization = completeDict["authorization_id"] as? String {
                    self.invokePaypalUpdateOrderService(idPayPal,paymentType:"-1",idAuthorization:idAuthorization)
                }
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: PayPalFuturePaymentDelegate
    func payPalFuturePaymentDidCancel(futurePaymentViewController: PayPalFuturePaymentViewController!) {
        print("PayPal Future Payment Authorization Canceled")
        //buttonShop?.enabled = true
        //let message = "Hubo un error al momento de generar la orden, intenta más tarde"
        //self.invokePayPalCancelService(message)
        self.sendOrder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(futurePaymentViewController: PayPalFuturePaymentViewController!, didAuthorizeFuturePayment futurePaymentAuthorization: [NSObject : AnyObject]!) {
        
        // send authorization to your server to get refresh token.
        print(futurePaymentAuthorization!.description)
        let futurePaymentService = GRPayPalFuturePaymentService()
        let responce = futurePaymentAuthorization["response"] as! [NSObject : AnyObject]
        futurePaymentService.callService(responce["code"] as! String, succesBlock: {(result:NSDictionary) -> Void in
            //self.invokePaypalUpdateOrderService("",paymentType:"-3")
            //self.showPayPalPaymentController()
            self.sendOrder()
            }, errorBlock: { (error:NSError) -> Void in
                //Mandar alerta
                //let message = "Hubo un error al momento de generar la orden, intenta más tarde"
                //self.invokePayPalCancelService(message)
                self.sendOrder()
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: PaymentOptionsViewDelegate
    
    func paymentSelected(index: String, paymentString: String) {
        self.paymentString = paymentString
        self.paymentId = index
    }
    
    //MARK: GenerateOrderViewDelegate
    func sendOrderConfirm() {
        print("Creando su orden")
        self.sendOrder()
    }
    
    
    
    
}