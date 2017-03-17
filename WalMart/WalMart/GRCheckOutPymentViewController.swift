//
//  GRCheckOutPymentViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
//import Tune


class GRCheckOutPymentViewController : NavigationViewController,UIWebViewDelegate,TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate,UIPickerViewDelegate,AlertPickerViewDelegate,OrderConfirmDetailViewDelegate,PayPalPaymentDelegate, PayPalFuturePaymentDelegate,GenerateOrderViewDelegate{
    
    var content: TPKeyboardAvoidingScrollView!
    
    var cancelShop : UIButton?
    var confirmShop : UIButton?
    var sectionTitleDiscount : UILabel!
    var sectionTitlePayments : UILabel!
    var layerLine: CALayer!
    
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
    var paymentOptionsItems: [Any]?
    //var paymentOptions: FormFieldView?
    var selectedPaymentType : IndexPath!
   
    var promotionsDesc: [[String:String]]! = []
    var showDiscountAsociate : Bool = false
    var promotionButtons: [UIView]! = []
    var discountAssociateAply:Double = 0.0 //descuento del Asociado
    var discountAssociate: FormFieldView?
    var picker : AlertPickerView!
    var selectedConfirmation : IndexPath!
    var idFreeShepping : Int! = 0
    var idReferido : Int! = 0
    var shipmentAmount: Double!
    //freshepping
    var isFistShip = false
    
    var paymentOptionsView : PaymentOptionsView!
    var paymentId = "0"
    var paymentString = ""
    var paramsToOrder : [String:Any]?
    var paramsToConfirm : [String:Any]!
    
    //Paypal
    var showOnilePayments: Bool = false
    var payPalPaymentField: UIButton?
    var payPalFuturePaymentField: UIButton?
    var payPalFuturePayment : Bool = false
    var showPayPalFuturePayment : Bool = false //iniciar en false
    
    var confirmOrderDictionary: [String:Any]! = [:]
    var cancelOrderDictionary:  [String:Any]! = [:]
    var completeOrderDictionary: [String:Any]! = [:]
    
    //Confirmation view
    var serviceDetail : OrderConfirmDetailView? = nil
    var confirmOrderView : GenerateOrderView? = nil
    
    var generateOrderTotal = ""
    var generateOrderSubtotal = ""
    var generateOrderDiscounts = ""
    var generateOrderPaymentType = ""
    var deliveryAmountSend = 0.0
    
    var viewLoad : WMLoadingView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 25.0
        
        self.view.backgroundColor =  UIColor.white
        self.titleLabel?.text = NSLocalizedString("Método de Pago", comment:"")
        
        if IS_IPAD {
            self.backButton?.isHidden = true
        }
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "3 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - (46 + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.view.addSubview(self.content)
        
        sectionPaypalTitle = self.buildSectionTitle(NSLocalizedString("Pago en línea", comment:""), frame: CGRect(x: 16,y: 16.0, width: self.view.frame.width, height: lheight))
        sectionPaypalTitle.isHidden =  true
        
        self.content.addSubview(sectionPaypalTitle)
        
        sectionTitlePayments = self.buildSectionTitle(NSLocalizedString("Pago contra entrega", comment:""), frame: CGRect(x: 16,y: 16.0, width: self.view.frame.width, height: lheight))
        self.content.addSubview(sectionTitlePayments)
        
        
        self.contenPayments =  UIView()
        self.content.addSubview(self.contenPayments)
        
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRect(x: 16, y: self.contenPayments!.frame.maxY + 10.0, width: self.view.frame.width, height: lheight))
        self.content.addSubview(self.sectionTitleDiscount)
        
        picker = AlertPickerView.initPickerWithDefault()
        
        self.discountAssociate = FormFieldView(frame: CGRect(x: margin,y: sectionTitleDiscount.frame.maxY ,width: width,height: fheight))
        self.discountAssociate!.setCustomPlaceholder(NSLocalizedString("checkout.field.discountAssociate", comment:""))
        self.discountAssociate!.isRequired = false
        self.discountAssociate!.typeField = TypeField.check
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
            self.picker!.cellType = TypeField.alphanumeric
            self.picker!.showPicker()
            
            NotificationCenter.default.addObserver(self, selector: #selector(GRCheckOutPymentViewController.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(GRCheckOutPymentViewController.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            //self.removeViewLoad()
        }
        
        //views
        
        self.content.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.maxY + 20.0)
        
        //self.paymentOptions = FormFieldView(frame: CGRectMake(margin, 10.0, width, fheight))
//        self.paymentOptions!.setCustomPlaceholder(NSLocalizedString("checkout.field.paymentOptions", comment:""))
//        self.paymentOptions!.isRequired = true
//        self.paymentOptions!.typeField = TypeField.List
//        self.paymentOptions!.setImageTypeField()
//        self.paymentOptions!.nameField = NSLocalizedString("checkout.field.paymentOptions", comment:"")
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view!.layer.insertSublayer(layerLine, at: 1000)
        
        //Buttons
        self.cancelShop =  UIButton()
        cancelShop?.setTitle(NSLocalizedString("Cancelar", comment: ""), for:UIControlState())
        cancelShop?.setTitleColor(UIColor.white, for: UIControlState())
        cancelShop?.backgroundColor = WMColor.empty_gray_btn
        cancelShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelShop?.layer.cornerRadius = 16
        cancelShop?.addTarget(self, action: #selector(GRCheckOutPymentViewController.cancelPurche), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelShop!)
        
        self.confirmShop =  UIButton()
        confirmShop?.setTitle(NSLocalizedString("Confirmar", comment: ""), for:UIControlState())
        confirmShop?.setTitleColor(UIColor.white, for: UIControlState())
        confirmShop?.backgroundColor = WMColor.green
        confirmShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        confirmShop?.layer.cornerRadius = 16
        confirmShop?.addTarget(self, action: #selector(GRCheckOutPymentViewController.continuePurche), for: UIControlEvents.touchUpInside)
        self.view.addSubview(confirmShop!)
        
        let titleLabelPayPal = UILabel(frame:CGRect(x: 22, y: 0, width: width - 22,height: 22))
        titleLabelPayPal.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabelPayPal.text = "PayPal"
        titleLabelPayPal.numberOfLines = 2
        titleLabelPayPal.lineBreakMode = NSLineBreakMode.byTruncatingTail
        titleLabelPayPal.textColor = WMColor.dark_gray
        titleLabelPayPal.tag = -1
        
        self.payPalPaymentField = UIButton()
        self.payPalPaymentField!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.payPalPaymentField!.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
        self.payPalPaymentField!.addTarget(self, action: #selector(GRCheckOutPymentViewController.paypalCheckSelected(_:)), for: UIControlEvents.touchUpInside)
        self.payPalPaymentField!.addSubview(titleLabelPayPal)
        self.payPalPaymentField!.isSelected = false
        self.payPalPaymentField!.tag = -1
        self.content.addSubview(payPalPaymentField!)
        
        let titleLabelPayPalFuture = UILabel(frame:CGRect(x: 22, y: 0, width: width - 38,height: 22))
        titleLabelPayPalFuture.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabelPayPalFuture.text = "PayPal pagos futuros"
        titleLabelPayPalFuture.numberOfLines = 2
        titleLabelPayPalFuture.lineBreakMode = NSLineBreakMode.byTruncatingTail
        titleLabelPayPalFuture.textColor = WMColor.dark_gray
        titleLabelPayPal.tag = -3
        
        
        self.payPalFuturePaymentField = UIButton()
        self.payPalFuturePaymentField!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.payPalFuturePaymentField!.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
        self.payPalFuturePaymentField!.addTarget(self, action: #selector(GRCheckOutPymentViewController.paypalCheckSelected(_:)), for: UIControlEvents.touchUpInside)
        self.payPalFuturePaymentField!.addSubview(titleLabelPayPalFuture)
        self.payPalFuturePaymentField!.isSelected = false
        self.payPalFuturePaymentField!.tag = -3
        
        self.payPalFuturePaymentField!.isSelected = false
        self.content.addSubview(payPalFuturePaymentField!)
        
        //Services
        self.invokeDiscountActiveService { () -> Void in
            self.shipmentAmount = self.paramsToOrder!["shipmentAmount"] as! Double
            self.invokeGetPromotionsService([:], discountAssociateItems: []) { (finish:Bool) -> Void in
               
                //self.buildSubViews()
                //--
                self.invokePaymentService { () -> Void in
                    print("End")
                    if self.paymentOptionsItems != nil {
                        self.paymentOptionsView =  PaymentOptionsView(frame: CGRect(x: 0, y: 0,width: self.view!.frame.width,height: self.view!.frame.height) , items:self.paymentOptionsItems!)
                        self.paymentOptionsView.selectedOption  = {(selected :String, stringselected:String) -> Void in
                            self.paymentString = stringselected
                            self.paymentId = selected
                            self.payPalPaymentField!.isSelected = false
                            self.payPalFuturePaymentField!.isSelected = false
                            self.payPalFuturePayment = false
                            self.changeButonTitleColor(self.payPalPaymentField!)
                            self.changeButonTitleColor(self.payPalFuturePaymentField!)
                        }
                        
                        self.contenPayments?.addSubview(self.paymentOptionsView)
                        
                        self.buildSubViews()
                    }//Presentar Empty
                    self.removeViewLoad()
                    
                }
            }
            
        }
        
        self.addViewLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GRCheckOutPymentViewController.reloadPromotios), name: NSNotification.Name(rawValue: "INVOKE_RELOAD_PROMOTION"), object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "INVOKE_RELOAD_PROMOTION"), object: nil)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width - (2 * margin)
        let bounds = self.view.frame.size
        let footerHeight : CGFloat = 60.0
        
        self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 8.0, width: self.titleLabel!.bounds.height, height: 35)
        
        self.content!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - (self.header!.frame.height + footerHeight + 44))
        if self.showOnilePayments {
            self.sectionPaypalTitle.frame = CGRect(x: 16,y: 16.0, width: self.view.frame.width, height: lheight)
            if self.showPayPalFuturePayment {
                self.sectionTitlePayments.frame =  CGRect(x: 16,y: self.payPalFuturePaymentField!.frame.maxY + 10, width: self.view.frame.width, height: lheight)
            }else{
                self.sectionTitlePayments.frame =  CGRect(x: 16,y: self.payPalPaymentField!.frame.maxY + 10, width: self.view.frame.width, height: lheight)
            }
            sectionPaypalTitle.isHidden =  false
        }else{
            sectionPaypalTitle.isHidden =  true
            self.sectionTitlePayments.frame =  CGRect(x: 16,y: 16.0, width: self.view.frame.width, height: lheight)
        }
        
        self.contenPayments.frame = CGRect(x: 16,y: self.sectionTitlePayments.frame.maxY ,width: self.view.frame.width - 32 , height: 320)
        sectionTitleDiscount.frame = CGRect(x: 16, y: self.contenPayments!.frame.maxY, width: width, height: lheight)
        self.discountAssociate!.frame = CGRect(x: margin,y: sectionTitleDiscount.frame.maxY,width: width,height: fheight)
        self.layerLine.frame = CGRect(x: 0, y: self.content!.frame.maxY,  width: self.view.frame.width, height: 1)
        self.cancelShop!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.content!.frame.maxY + 16, width: 140, height: 34)
        self.confirmShop!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.content!.frame.maxY + 16, width: 140, height: 34)
        let _ = self.buildPromotionButtons()
    }
    
    
    /**
     call service getPromotios, to validate more promotions
     */
    func reloadPromotios(){
        self.addViewLoad()
        self.invokeGetPromotionsService(self.picker.textboxValues!,discountAssociateItems: self.picker.itemsToShow,endCallPromotions: { (finish) -> Void in
            self.removeViewLoad()
        })
    
    }
    
    /**
     Create title label to sections in payments options
     
     - parameter title: title to show
     - parameter frame: frame of title
     
     - returns: label with title
     */
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    /**
     Call function back, to return before section
     */
    func cancelPurche (){
        self.back()
    }
    
    /**
     Show confirm order before call to service shopping
     */
    func continuePurche (){
        
        self.confirmOrderView  = GenerateOrderView.initDetail()
        self.confirmOrderView!.delegate  =  self
        self.confirmOrderView?.isFreshepping =  self.isFistShip
        self.confirmOrderView?.showDetail()
        self.generateOrderPaymentType =  self.paymentString
        
        self.paramsToConfirm!["shipmentAmount"] = self.discountsFreeShippingAssociated ? "0.0" :self.paramsToConfirm!["shipmentAmount"]
        let amoutnShip = self.paramsToConfirm!["shipmentAmount"] as? String
        self.paramsToConfirm!["total"] = "\(generateOrderTotal.toDouble()! + (self.isFistShip ? 0 : (amoutnShip!.toDouble()!)))"
        self.paramsToConfirm!["subtotal"] = generateOrderSubtotal
        self.paramsToConfirm!["Discounts"] = generateOrderDiscounts
        self.paramsToConfirm!["PaymentType"] = generateOrderPaymentType
        self.confirmOrderView?.showGenerateOrder(self.paramsToConfirm!)
        BaseController.sendAnalyticsPreviewCart(generateOrderPaymentType)
        
    }
    
    /**
      Call service sendOrderWithSlotPromo, and present confirm order view
     */
    func sendOrder(){
        
        let serviceCheck = GRSendOrderService()
        
        serviceDetail = OrderConfirmDetailView.initDetail()
        serviceDetail?.delegate = self
        serviceDetail!.showDetail()
        let total = UserCurrentSession.sharedInstance.estimateTotalGR()
        
        let freeShipping = discountsFreeShippingAssociated
        let discount : Double = self.totalDiscountsOrder
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let totalDis = formatter.string(from: NSNumber(value: discount as Double))!
        
        
        //Recibir por parametros
        let dateMonth = self.paramsToOrder!["month"] as! Int
        let dateYear = self.paramsToOrder!["year"] as! Int
        let dateDay = self.paramsToOrder!["day"] as! Int
        let commensOrder = self.paramsToOrder!["comments"] as? String
        let addresId =  self.paramsToOrder!["AddressID"]  as?  String
        let slotId = self.paramsToOrder!["slotId"] as? Int
        let deliveryType = self.paramsToOrder!["deliveryType"] as? String
        let deliveryTypeString = self.paramsToOrder!["deliveryTypeString"] as? String
        let deliverySchedule = self.paramsToOrder!["hour"] as? String
        let pickingInstruction = self.paramsToOrder!["pickingInstruction"] as! Int
        
        let paramsOrder = serviceCheck.buildParams(total, month: "\(dateMonth)", year: "\(dateYear)", day: "\(dateDay)", comments: commensOrder!, paymentType: self.paymentId, addressID: addresId!, device: getDeviceNum(), slotId: slotId!, deliveryType: deliveryType!, correlationId: "", hour: deliverySchedule!, pickingInstruction:"\(pickingInstruction)" , deliveryTypeString: deliveryTypeString!, authorizationId: "", paymentTypeString:
            self.paymentString,isAssociated:self.asociateDiscount,idAssociated:associateNumber,dateAdmission:dateAdmission,determinant:determinant,isFreeShipping:freeShipping,promotionIds:promotionIds,appId:self.getAppId(),totalDiscounts: Double(totalDis)!)
        
        
        serviceCheck.callService(requestParams: paramsOrder, successBlock: { (resultCall:[String:Any]) -> Void in
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_BUY_GR.rawValue , label: "")
            // deliveryAmount
//            let userEmail = UserCurrentSession.sharedInstance.userSigned!.email as String
//            let userName = UserCurrentSession.sharedInstance.userSigned!.profile.name as String
//            let idUser = UserCurrentSession.sharedInstance.userSigned!.profile.user.idUser as String
//            let items :[[String:Any]] = UserCurrentSession.sharedInstance.itemsGR!["items"]! as! [[String:Any]]
           
            
           
            if let shipmentAmount = self.paramsToOrder!["shipmentAmount"] as? Double {
                self.deliveryAmountSend = shipmentAmount
            }
            
            //PayPal
            if self.paymentId == "-3"{
                
                self.confirmOrderDictionary = paramsOrder
                self.showPayPalPaymentController(resultCall)
                return
            }
            
           
            let purchaseOrderArray = resultCall["purchaseOrder"] as! [Any]
            let purchaseOrder = purchaseOrderArray[0] as! [String:Any]
            let trakingNumber = purchaseOrder["trackingNumber"] as! String
            let deliveryDate = purchaseOrder["deliveryDate"] as! NSString
            let paymentTypeString = purchaseOrder["paymentTypeString"] as! String
            let hour = purchaseOrder["hour"] as! String
            let subTotal = purchaseOrder["subTotal"] as! NSNumber
            var total = NSNumber(value:0.0)
            if let totalVal = purchaseOrder["total"] as? NSNumber {
                total = totalVal
            }
            
            
            var authorizationId = ""
            var correlationId = ""
            
            var deliveryAmount = 0.0
            if let shippingVal  = purchaseOrder["deliveryAmount"] as? Double {
                deliveryAmount = shippingVal
            }
            
            
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
            
            
            self.cancelOrderDictionary = ["slot": slot,"device": self.getDeviceNum(),"paymentType": self.paymentId,"deliveryType": deliveryType!,"trackingNumber": trakingNumber]
            self.completeOrderDictionary = ["trakingNumber":trakingNumber, "deliveryDate": formattedDate, "deliveryHour": hour, "paymentType": paymentTypeString, "subtotal": formattedSubtotal, "total": formattedTotal, "deliveryAmount" : "\(formattedDeliveryAmount)","discountsAssociated" : "\(discountsAssociated)"]
            
            
            let storeId = slot["storeId"]! as AnyObject
            let purchaseId = slot["orderId"]! as AnyObject
            let shipmentAmount = self.paramsToConfirm!["shipmentAmount"] as! String
            
            
           BaseController.sendAnalyticsPurchase(storeId, paymentType: paymentTypeString, deliveryType: deliveryType!, deliveryDate: deliveryDate as String, deliveryHour: hour, purchaseId: purchaseId, affiliation: "Groceries", revenue: String(describing: total), tax: "", shipping: shipmentAmount, coupon: "")
            
            
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
    /**
    Close shopping cart when finishing confirm order
    */
    func didFinishConfirm() {

        if IS_IPAD {
             let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: Notification.Name(rawValue: "CLOSE_GRSHOPPING_CART"), object: nil)
        }else{
            UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                let _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }

    }
    
    /**
     Close cart when tap ok action in confirm view
     */
    func didErrorConfirm() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     Show loading animation in view
     */
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRect(x: 0, y: 0, width: 341, height: 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    //MARK: - PayPal
    /**
    Show paypal controller
    */
    func showPayPalPaymentController(_ responsePaypal : [String:Any])
    {
        /*let items :[[String:Any]] = UserCurrentSession.sharedInstance.itemsGR!["items"]! as! [[String:Any]]
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
 */
        
        
        let subtotal = NSDecimalNumber(string: (responsePaypal["subtotal"] as! String))
        let shippingCost = NSDecimalNumber(string: (responsePaypal["shippingCost"] as! String))
        let tax = NSDecimalNumber(string: (responsePaypal["tax"] as! String))
        let currency = responsePaypal["currency"] as! String
        let cartId = responsePaypal["cartId"] as! String
        confirmOrderDictionary["cartId"] = cartId
        
        //Address
        let responseAddress = responsePaypal["address"] as! [String:Any]
        let addressLine1 = responseAddress["address1"] as! String
        let addressLine2 = responseAddress["address2"] as! String
        let city = responseAddress["city"] as! String
        let state = responseAddress["state"] as! String
        let postalCode = responseAddress["postalCode"] as! String
        let country = "MX"
        
        //Name
        let firstName = responseAddress["firstName"] as! String
        let middleName = responseAddress["middleName"] as! String
        let lastName = responseAddress["lastName"] as? String ?? ""
        
        
        //let subtotal = PayPalItem.totalPrice(forItems: payPalItems)
        // Optional: include payment details
        //let shipping = NSDecimalNumber(value: shippingCost)
        let paymentDetails = PayPalPaymentDetails(subtotal:subtotal, withShipping: shippingCost, withTax: tax)
        let total = subtotal.adding(shippingCost).adding(tax)
 
        let payment = PayPalPayment(amount: total, currencyCode: currency, shortDescription: "Walmart", intent: .authorize)
        
       let shippingAddress =  PayPalShippingAddress(recipientName: "\(firstName) \(middleName) \(lastName)", withLine1: addressLine1, withLine2: addressLine2, withCity: city, withState    : state, withPostalCode: postalCode, withCountryCode: country)
        
        //payment.items = payPalItems
        payment.paymentDetails = paymentDetails
        payment.shippingAddress = shippingAddress
        payment.custom = cartId
        
        
        if (payment.processable) {
            PayPalMobile.preconnect(withEnvironment: self.getPayPalEnvironment())
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.initPayPalConfig(), delegate: self)
            paymentViewController!.modalPresentationStyle = UIModalPresentationStyle.formSheet
            
            NotificationCenter.default.addObserver(self, selector: #selector(GRCheckOutPymentViewController.cancelFromBg), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            
            self.present(paymentViewController!, animated: true, completion: nil)
            
        } else {
            let message = "Tu pago ha sido cancelado"
            self.invokePayPalCancelService(message)
        }
    }
    
    func cancelFromBg() {
            self.invokePayPalCancelService("Se canceló el pago intenta nuevamente")
    }
    
    /**
     Show paypal future payments controller
     */
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
        payPalConfig.rememberUser = false
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
    
    /**
     Remove loading from superview
     */
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPoint(x: self.picker!.center.x, y: self.picker!.center.y - 100)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }
    
    
    //MARK: InvokeServices
    /**
      Call getPromotions service, paint totals
    
    - parameter pickerValues:           array values parameters to service
    - parameter discountAssociateItems: values from associate
    - parameter endCallPromotions:       call when finished service
    */
    func invokeGetPromotionsService(_ pickerValues: [String:String], discountAssociateItems: [String],endCallPromotions:@escaping ((Bool) -> Void))
    {
        var savinAply : Double = 0.0
        var items =  UserCurrentSession.sharedInstance.itemsGR ==  nil ? [:] : UserCurrentSession.sharedInstance.itemsGR!
        
        if let savingGR = items["saving"] as? NSNumber {
            savinAply =  savingGR.doubleValue
            
        }
        
        var paramsDic: [String:String] = pickerValues
        paramsDic["isAssociated"] =  self.isAssociateSend ? "1":"0"
        paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance.estimateTotalGR() - savinAply)"
        paramsDic["addressId"] = self.paramsToOrder!["AddressID"] as? String
        
        let promotionsService = GRGetPromotionsService()
        
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
                self.isFistShip = (self.idFreeShepping != 0)
                
                if self.idFreeShepping == 0 {
                    if let listReferidos = resultCall["listReferidos"] as? [String:Any]{
                        self.idReferido = listReferidos["idReferido"] as! Int
                        let  addIdRefered =  listReferidos["numEnviosReferidos"] as! Int
                        if addIdRefered > 0 {
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: ",\(self.idReferido)", with: "")
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(self.idReferido),", with: "")
                            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(self.idReferido)", with: "")
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
                    var items = UserCurrentSession.sharedInstance.itemsGR!
                    if let savingGR = items["saving"] as? NSNumber {
                        savinAply =  savingGR.doubleValue
                    }
                    let total = "\(UserCurrentSession.sharedInstance.numberOfArticlesGR())"
                    let subTotal = String(format: "%.2f", self.newTotal)
                    let saving = String(format: "%.2f", self.totalDiscountsOrder + savinAply)
                    
                    let dSaving = NumberFormatter().number(from: saving)
                    let dSubtotal = NumberFormatter().number(from: subTotal)
                    let subNewTotal = dSubtotal!.doubleValue + dSaving!.doubleValue
                    
                    self.generateOrderTotal = "\(subTotal)"
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
    
    
    /**
    Validate if the associate discount is showing in display
    
    - parameter endCallDiscountActive: finish to call service
    */
    func invokeDiscountActiveService(_ endCallDiscountActive:@escaping (() -> Void)) {
        let discountActive  = GRDiscountActiveService()
        discountActive.callService({ (result:[String:Any]) -> Void in
            
            if let res = result["discountsAssociated"] as? Bool {
                self.showDiscountAsociate = res // TODO
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
    
    /**
     Call getPaymentTypeService
     
     - parameter endCallPaymentOptions: block to end service success
     */
    func invokePaymentService(_ endCallPaymentOptions:@escaping (() -> Void)) {
        
        let service = GRPaymentTypeService()
        service.callService("2",
            successBlock: { (result:[Any]) -> Void in
                print(result)
                self.paymentOptionsItems = result as [Any]
                
                
                for paymentOption in self.paymentOptionsItems!{
                    if let payment = paymentOption as? [String:Any] {
                        if let option = payment["id"] as? String {
                            if option == "-1"{
                               self.showOnilePayments = true
                               self.showPayPalFuturePayment = true
                               break
                            }
                            if option == "-3"{
                                self.showOnilePayments = true
                                self.showPayPalFuturePayment = false
                                break
                            }
                        }
                    }
                }
                //Delete duplicate paypal
                self.paymentOptionsItems = self.paymentOptionsItems?.filter({ (element) -> Bool in
                    if let payment = element as? [String:Any] {
                        if let option = payment["id"] as? String {
                            if option == "-1" || option == "-3" {
                                return false
                            }
                        }
                    }
                    return true
                })
                
                endCallPaymentOptions()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at invoke payment type service")
                //self.removeViewLoad()
                endCallPaymentOptions()
            }
        )
    }
    
    /**
     Call getSavingService, this service validate information of associate
     
     - parameter pickerValues:            values from cart,(total,addresId,associateNumber,date and determinat)
     - parameter discountAssociateItems:  values from associate
     */
    func invokeDiscountAssociateService(_ pickerValues: [String:String], discountAssociateItems: [String])
    {
        if pickerValues.count == discountAssociateItems.count
        {
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),
                imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            
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
                    
                    print("# de productos:: \(UserCurrentSession.sharedInstance.numberOfArticlesGR())")
                    print("Subtotal:: \(UserCurrentSession.sharedInstance.estimateTotalGR())")
                    print("Saving:: \( UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")")
                    self.shipmentAmount = self.paramsToOrder!["shipmentAmount"] as! Double
                    print("Comprar:: \(UserCurrentSession.sharedInstance.estimateTotalGR() - UserCurrentSession.sharedInstance.estimateSavingGR() + self.shipmentAmount)")
                    
                    
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
                        self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
                        self.alertView!.showDoneIcon()
                        let _ = self.buildPromotionButtons()
                        
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
    /**
    call updateOrderStatusPaypal Service
    
    - parameter message:   Message to show in orderDetail
    */
    func invokePayPalCancelService(_ message: String){
        let updatePaypalService = GRPaypalUpdateOrderService()
        self.confirmOrderDictionary["paypalAuthorizationNumber"] = ""
        self.confirmOrderDictionary["payPalPaymentStatus"] = "2"
        self.confirmOrderDictionary["amount"] = UserCurrentSession.sharedInstance.estimateTotalGR() + self.deliveryAmountSend
        //self.confirmOrderDictionary["correlationId"] = PayPalMobile.clientMetadataID()
        //self.confirmOrderDictionary["paymentType"] = paymentType
        //self.confirmOrderDictionary["authorization"] = idAuthorization
        //print("idAuthorization::::\(idAuthorization)::::")
        
        
        
        updatePaypalService.callServiceConfirmOrder(requestParams: self.confirmOrderDictionary, succesBlock: {(result:[String:Any]) -> Void in
            self.serviceDetail?.errorOrder(message)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        }, errorBlock: { (error:NSError) -> Void in
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            if error.code == -400 {
                self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
            }
            else {
                self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
            }
        })
        
        
    }
    
    /**
     Call updateOrderStatusPaypal Service
     
     - parameter authorizationId: authorizationId
     - parameter paymentType:     paymentType selected
     - parameter idAuthorization: idAuthorization
     */
    func invokePaypalUpdateOrderService(_ authorizationId:String,paymentType:String,idAuthorization:String,status:String){
        let updatePaypalService = GRPaypalUpdateOrderService()
        self.confirmOrderDictionary["paypalAuthorizationNumber"] = authorizationId
        self.confirmOrderDictionary["payPalPaymentStatus"] = "1"
        self.confirmOrderDictionary["amount"] = UserCurrentSession.sharedInstance.estimateTotalGR() + self.deliveryAmountSend
        //self.confirmOrderDictionary["correlationId"] = PayPalMobile.clientMetadataID()
        //self.confirmOrderDictionary["paymentType"] = paymentType
        //self.confirmOrderDictionary["authorization"] = idAuthorization
        print("idAuthorization::::\(idAuthorization)::::")
        
        updatePaypalService.callServiceConfirmOrder(requestParams: self.confirmOrderDictionary, succesBlock: {(result:[String:Any]) -> Void in
            
            let deliveryDate = result["deliveryDate"] as! NSString
            let trackingNumber = result["trackingNumber"] as! NSString
            let subTotal = result["subTotal"] as! NSNumber
            let total = result["total"] as! NSNumber
            let deliveryAmount = result["deliveryAmount"] as! NSString
            let slotH = result["hour"] as! NSString
            let formattedDate = deliveryDate.substring(to: 10)
            let formattedSubtotal = CurrencyCustomLabel.formatString(subTotal.stringValue as NSString)
            let formattedTotal = CurrencyCustomLabel.formatString(total.stringValue as NSString)
            let formattedDeliveryAmount = CurrencyCustomLabel.formatString(deliveryAmount)
            
            self.completeOrderDictionary = ["trakingNumber":trackingNumber, "deliveryDate": formattedDate, "deliveryHour": slotH, "paymentType": self.paymentString, "subtotal": formattedSubtotal, "total": formattedTotal, "deliveryAmount" : "\(formattedDeliveryAmount)","discountsAssociated" : ""]
            
            
            self.serviceDetail?.completeOrder(self.completeOrderDictionary["trakingNumber"] as! String, deliveryDate: self.completeOrderDictionary["deliveryDate"] as! String, deliveryHour: self.completeOrderDictionary["deliveryHour"] as! String, paymentType: self.completeOrderDictionary["paymentType"] as! String, subtotal: self.completeOrderDictionary["subtotal"] as! String, total: self.completeOrderDictionary["total"] as! String, deliveryAmount : self.completeOrderDictionary["deliveryAmount"] as! String, discountsAssociated: self.completeOrderDictionary["discountsAssociated"] as! String)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            
            }, errorBlock: { (error:NSError) -> Void in
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
                if error.code == -400 {
                    self.serviceDetail?.errorOrder("Hubo un error \(error.localizedDescription)")
                } else if error.code == -20 {
                    self.serviceDetail?.errorOrder(error.localizedDescription,false)
                }
                else {
                    self.serviceDetail?.errorOrder("Hubo un error al momento de generar la orden, intenta más tarde")
                }
        })
    }
    

    //MARK: Actions
    
    /**
    Validate Required vaues from asociate form
    
    - parameter pickerValues: array wich fields asociate
    - parameter completion:   if error in any field return a meessage
    */
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
    
    /**
     Create views witch any promotios, adding label and button select
     
     - returns: Last frame
     */
    func buildPromotionButtons() -> CGFloat{
        let bounds = self.view.frame.size
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        let margin: CGFloat = 15.0
        let widthField = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        
        var posY = self.showDiscountAsociate ? discountAssociate!.frame.maxY : sectionTitleDiscount.frame.maxY + 5.0
        
        var count =  0
        if promotionsDesc.count > 0 {
            posY -= 10
            for promotion in self.promotionsDesc{
                //posY += CGFloat(40 * count)
                
                let titleLabel = UILabel(frame:CGRect(x: 22, y: 0, width: widthField-22,height: fheight))
                titleLabel.font = WMFont.fontMyriadProRegularOfSize(13)
                titleLabel.text = promotion["promotion"]
                titleLabel.numberOfLines = 2
                titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                titleLabel.textColor = WMColor.dark_gray
                
                let promSelect = UIButton(frame: CGRect(x: margin,y: posY,width: widthField,height: fheight))
                promSelect.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
                promSelect.setImage(UIImage(named:"checkAddressOn"), for: UIControlState.selected)
                promSelect.addTarget(self, action: #selector(GRCheckOutPymentViewController.promCheckSelected(_:)), for: UIControlEvents.touchUpInside)
                promSelect.addSubview(titleLabel)
                promSelect.isSelected = false
                promSelect.tag = count
                promSelect.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,widthField - 20)
                self.content.addSubview(promSelect)
                self.promotionButtons.append(promSelect)
                count += 1
                posY += 50
            }
            
            // self.hasPromotionsButtons = true
        }
        else{
            posY += CGFloat(40 * self.promotionsDesc.count)
        }
        self.content.contentSize = CGSize(width: self.view.frame.width, height: posY + 10.0)
        
        return posY
    }
    
    /**
     Reorganizing payment options an promotions
     */
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
        //let lheight: CGFloat = 25.0
        
        self.payPalFuturePaymentField!.alpha = 0
        self.payPalPaymentField!.alpha = 0
        
        if showOnilePayments{
            self.payPalFuturePaymentField!.alpha = self.showPayPalFuturePayment ? 1 : 0
            self.payPalPaymentField!.alpha = 1
        }
        
        let posY  = self.view.frame.maxY
        if showDiscountAsociate
        {
            self.discountAssociate!.alpha = 1
            self.sectionTitleDiscount!.alpha = 1
            self.payPalPaymentField!.frame = CGRect(x: margin, y: self.sectionPaypalTitle!.frame.maxY , width: widthField, height: 22)
            self.discountAssociate!.frame = CGRect(x: margin,y: sectionTitleDiscount.frame.maxY,width: widthField,height: fheight)
            //posY = self.buildPromotionButtons()
            print("posY ::: posY \(posY)")
            
        } else {
            if self.promotionsDesc.count > 0 {
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 1
                self.payPalPaymentField!.frame = CGRect(x: margin, y: self.sectionPaypalTitle!.frame.maxY + 10.0, width: widthField, height: 22)
                self.payPalPaymentField!.imageEdgeInsets = UIEdgeInsetsMake(0,0, 0, self.payPalPaymentField!.frame.width - 22 )
                //posY = self.buildPromotionButtons()
                print("posY ::: posY \(posY)")
            }else{
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 0
                self.payPalPaymentField!.frame = CGRect(x: margin, y: self.sectionPaypalTitle!.frame.maxY + 10.0, width: widthField, height: 22)
                self.payPalPaymentField!.imageEdgeInsets = UIEdgeInsetsMake(0,0, 0, self.payPalPaymentField!.frame.width - 22 )
            }
        }
        if showPayPalFuturePayment{
            self.payPalFuturePaymentField!.frame = CGRect(x: margin + 16, y: self.payPalPaymentField!.frame.maxY + 10 , width: widthField - 16, height: 22)
            self.payPalFuturePaymentField!.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,self.payPalFuturePaymentField!.frame.width - 22)
        }
        self.content.contentSize = CGSize(width: self.view.frame.width, height: posY + 10.0)
    }
    
    var afterButton :UIButton?
    var promotionSelect: String! = ""
    var promotionIds: String! = ""
    
    /**
     Mark the promotions selected
     - parameter sender: button to promotion select, 
       and add to dictionary to send service
     */
    func promCheckSelected(_ sender: UIButton){
        //self.promotionIds! = ""
        if promotionSelect != ""{
            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: ",\(promotionSelect)", with: "")
            self.promotionIds! =  self.promotionIds!.replacingOccurrences(of: "\(promotionSelect)", with: "")
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
                promotionSelect = idPromotion
                self.promotionIds! += (self.promotionIds == "") ? "\(idPromotion)" : ",\(idPromotion)"
            }
        }
        
        print("promosiones:::: \(self.promotionIds) :::")
    }
    
    func getDeviceNum() -> String {
        return IS_IPAD ? "25" : "24"
    }
    /**
     Get appId
     
     - returns: version device
     */
    func getAppId() -> String{
        return "\(UserCurrentSession.systemVersion()) \(UserCurrentSession.currentDevice())"
    }
    
    
    
    //MARK: AlertPickerViewDelegate
    
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            
            if formFieldObj == self.discountAssociate!{
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_DISCOUT_ASOCIATE.rawValue , label: "")
                if self.showDiscountAsociate {
                    //self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
                    
                }
            }
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            
            if formFieldObj == self.discountAssociate!{
                self.invokeDiscountAssociateService(picker.textboxValues!,discountAssociateItems: picker.itemsToShow)
            }
            
        }
    }
    
    func viewReplaceContent(_ frame: CGRect) -> UIView! {
        let view =  UIView()
        return view
    }
    
    func saveReplaceViewSelected() {
        
    }
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    
    
    //MARK: PayPalPaymentDelegate
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        let message = "Tu pago ha sido cancelado"
        self.invokePayPalCancelService(message)
        self.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        print(completedPayment.description)
        if let completeDict = completedPayment.confirmation["response"] as? [String:Any] {
            if let idPayPal = completeDict["authorization_id"] as? String {
                var autorization = ""
                if let idAuthorization = completeDict["authorization_id"] as? String {
                    autorization = idAuthorization
                }
                let statePaypal = completeDict["state"] as? String
                let status = statePaypal == "approved" ? "1" : "0"
                self.invokePaypalUpdateOrderService(idPayPal,paymentType:self.paymentId,idAuthorization:autorization,status:status)
            }
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: PayPalFuturePaymentDelegate
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        //buttonShop?.enabled = true
        //let message = "Hubo un error al momento de generar la orden, intenta más tarde"
        //self.invokePayPalCancelService(message)
        self.sendOrder()
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
            self.sendOrder()
            }, errorBlock: { (error:NSError) -> Void in
                //Mandar alerta
                //let message = "Hubo un error al momento de generar la orden, intenta más tarde"
                //self.invokePayPalCancelService(message)
                self.sendOrder()
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    func paypalCheckSelected(_ sender:UIButton){
       self.paymentOptionsView!.deselectOptions()
        if sender == self.payPalPaymentField {
            self.paymentString = "Paypal"
            self.paymentId = "-3"
        }
//        if sender == self.payPalFuturePaymentField {
//            if !sender.isSelected {
//                self.paymentString = "Paypal"
//                self.paymentId = "-3"
//                self.payPalPaymentField!.isSelected = true
//                self.payPalFuturePayment = true
//            }
//        }
        sender.isSelected = (sender == self.payPalPaymentField) ? true : !sender.isSelected
        self.changeButonTitleColor(sender)
    }
    /**
     Change title color.
     
     - parameter sender: button cahnge color
     */
    func changeButonTitleColor(_ sender:UIButton){
        for btnView in sender.subviews {
            if  btnView.isKind(of: UILabel.self) {
                let view : UILabel  = btnView as! UILabel
                if sender.isSelected{
                    view.textColor = WMColor.light_blue
                }else{
                    view.textColor = WMColor.dark_gray
                }
            }
        }
    }
    
    /**
     Validate send order or present paymentFuetureController
     */
    func sendOrderConfirm() {
        print("Creando su orden")
        if self.payPalFuturePayment{
            self.showPayPalFuturePaymentController()
        }else{
            sendOrder()
        }
    }
    
    
    
    
}
