//
//  GRCheckOutPymentViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class GRCheckOutPymentViewController : NavigationViewController,UIWebViewDelegate,TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate,UIPickerViewDelegate,AlertPickerViewDelegate {

    var content: TPKeyboardAvoidingScrollView!
    
    var cancelShop : UIButton?
    var confirmShop : UIButton?
    var sectionTitleDiscount : UILabel!
    var sectionTitlePayments : UILabel!
    
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
    
    let margin:  CGFloat = 15.0
    let fheight: CGFloat = 44.0
    let lheight: CGFloat = 25.0
    
    let itemsPayments = [NSLocalizedString("En linea", comment:""), NSLocalizedString("Contra entrega", comment:"")]
    
    //Services
    var paymentOptionsItems: [AnyObject]?
    var paymentOptions: FormFieldView?
    var selectedPaymentType : NSIndexPath!
    var showPayPalFuturePayment : Bool = false
    var promotionsDesc: [[String:String]]! = []
    var showDiscountAsociate : Bool = false
    var promotionButtons: [UIView]! = []
    var discountAssociateAply:Double = 0.0 //descuento del Asociado
    var discountAssociate: FormFieldView?
    var picker : AlertPickerView!
    var selectedConfirmation : NSIndexPath!
    var idFreeShepping : Int! = 0
    var idReferido : Int! = 0
    
    var paymentOptionsView : PaymentOptionsView!
    var paymentId = "0"
    var paymentString = ""
    var paramsToOrder : NSDictionary?
    
    //Purche array
    
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
    
    func paramsFromOrder(month:String, year:String, day:String, comments:String, addressID:String, deliveryType:String,hour:String, pickingInstruction:String, deliveryTypeString:String,slotId:Int){
    
        self.paramsToOrder = ["month":month, "year":year, "day":day, "comments":comments, "AddressID":addressID,  "slotId":slotId, "deliveryType":deliveryType, "hour":hour, "pickingInstruction":pickingInstruction, "deliveryTypeString":deliveryTypeString]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 25.0
        
        self.view.backgroundColor =  UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("Método de Pago", comment:"")
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "3 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, 46, self.view.bounds.width, self.view.bounds.height - (46 + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        
        sectionTitlePayments = self.buildSectionTitle(NSLocalizedString("Pago contra entrega", comment:""), frame: CGRectMake(16,16.0, self.view.frame.width, lheight))
        self.content.addSubview(sectionTitlePayments)
        

        self.contenPayments =  UIView()
        self.content.addSubview(self.contenPayments)
        
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRectMake(16, self.contenPayments!.frame.maxY + 20.0, self.view.frame.width, lheight))
        self.content.addSubview(self.sectionTitleDiscount)
        
        picker = AlertPickerView.initPickerWithDefault()
        
        self.discountAssociate = FormFieldView(frame: CGRectMake(margin,sectionTitleDiscount.frame.maxY + 10.0,width,fheight))
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
       
        //Services
        self.invokeDiscountActiveService { () -> Void in
            self.invokeGetPromotionsService([:], discountAssociateItems: []) { (finish:Bool) -> Void in
                self.buildPromotionButtons()
                self.buildSubViews()
            }
            
        }
        
       
        
        self.invokePaymentService { () -> Void in print("End")
            self.paymentOptionsView =  PaymentOptionsView(frame: CGRectMake(0, 0,self.view!.frame.width,self.view!.frame.height) , items:self.paymentOptionsItems!)
            self.paymentOptionsView.selectedOption  = {(selected :String, stringselected:String) -> Void in
                self.paymentString = stringselected
                self.paymentId = selected
            }
            //self.paymentOptionsView.delegate =  self
            self.contenPayments?.addSubview(self.paymentOptionsView)
        
        }
        
        
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
        self.sectionTitlePayments.frame =  CGRectMake(16,16.0, self.view.frame.width, lheight)
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
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func continuePurche (){
        print("::::Informacion para la compra:::::")
        print(":::::::::::::::::::::::::::::::::::")
        let serviceCheck = GRSendOrderService()
        let total = UserCurrentSession.sharedInstance().estimateTotalGR()
        
        let freeShipping = discountsFreeShippingAssociated
        let discount : Double = self.totalDiscountsOrder
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let totalDis = formatter.stringFromNumber(NSNumber(double:discount))!
        
       
        //Recibir por parametros
        let dateMonth = self.paramsToOrder!["month"] as! String//03
        let dateYear = self.paramsToOrder!["year"] as! String//2016
        let dateDay = self.paramsToOrder!["day"] as! String//20
        let commensOrder = self.paramsToOrder!["comments"] as? String//"Recibios por parametros"
        let addresId =  self.paramsToOrder!["AddressID"]  as?  String //"4567890cuytrcts"
        let slotId = self.paramsToOrder!["slotId"] as? Int//1
        let deliveryType = self.paramsToOrder!["deliveryType"] as? String//"3"
        let deliveryTypeString = self.paramsToOrder!["deliveryTypeString"] as? String//"Entrega Programada - $44"
        let deliverySchedule = self.paramsToOrder!["hour"] as? String//"11:00 - 12:00"
        let pickingInstruction = self.paramsToOrder!["pickingInstruction"] as? String//"3"
        
        let paramsOrder = serviceCheck.buildParams(total, month: "\(dateMonth)", year: "\(dateYear)", day: "\(dateDay)", comments: commensOrder!, paymentType: self.paymentId, addressID: addresId!, device: getDeviceNum(), slotId: slotId!, deliveryType: deliveryType!, correlationId: "", hour: deliverySchedule!, pickingInstruction: pickingInstruction!, deliveryTypeString: deliveryTypeString!, authorizationId: "", paymentTypeString:
            self.paymentString,isAssociated:self.asociateDiscount,idAssociated:associateNumber,dateAdmission:dateAdmission,determinant:determinant,isFreeShipping:freeShipping,promotionIds:promotionIds,appId:self.getAppId(),totalDiscounts: Double(totalDis)!)
        
        serviceCheck.jsonFromObject(paramsOrder)
        
    
    }
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPointMake(self.picker!.center.x, self.picker!.center.y - 100)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }
    
    
    //MARK : InvokeServices
    
    func invokeGetPromotionsService(pickerValues: [String:String], discountAssociateItems: [String],endCallPromotions:((Bool) -> Void))
    {
        /*if pickerValues.count == discountAssociateItems.count
        {*/
        //self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        //self.alertView!.setMessage("Validando Promociones")
        
        //self.addViewLoad()
        var savinAply : Double = 0.0
        var items = UserCurrentSession.sharedInstance().itemsGR as! [String:AnyObject]
        if let savingGR = items["saving"] as? NSNumber {
            savinAply =  savingGR.doubleValue
            
        }
        
        var paramsDic: [String:String] = pickerValues
        paramsDic["isAssociated"] = "0"
        paramsDic[NSLocalizedString("checkout.discount.total", comment:"")] = "\(UserCurrentSession.sharedInstance().estimateTotalGR() - savinAply)"
        paramsDic["addressId"] = ""
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
                
               // self.newTotal = resultCall["newTotal"] as? Double
                
                
                let totalDiscounts =  resultCall["totalDiscounts"] as? Double
                self.totalDiscountsOrder = totalDiscounts!
                self.promotionsDesc = []
                
                if let listSamples = resultCall["listSamples"] as? [AnyObject]{
                    for promotionln in listSamples {
                        let isAsociate = promotionln["isAssociated"] as! Bool
                        //self.isAssociateSend = isAsociate
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
                        
                        //for promotionln in listReferidos {
                        
                        self.idReferido = listReferidos["idReferido"] as! Int//promotionln["idReferido"] as? Int
                        let  addIdRefered =  listReferidos["numEnviosReferidos"] as! Int
                        if addIdRefered > 0 {
                            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString(",\(self.idReferido)", withString: "")
                            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(self.idReferido),", withString: "")
                            self.promotionIds! =  self.promotionIds!.stringByReplacingOccurrencesOfString("\(self.idReferido)", withString: "")
                            self.promotionIds! += (self.promotionIds == "") ? "\(self.idReferido)" : ",\(self.idReferido)"
                            print("listReferidos: \(self.idReferido)")
                            self.discountsFreeShippingAssociated =  true
                        }
                        //}
                    }
                }
                
                //self.discountAssociate!.setSelectedCheck(true)
                //TODO: Validar si se recargara servicio
//                self.invokeDeliveryTypesService({ () -> Void in
//                    //self.alertView!.setMessage(NSLocalizedString("gr.checkout.discount",comment:""))
//                    //self.alertView!.showDoneIcon()
//                    self.removeViewLoad()//--
//                })
                
//                if self.newTotal != nil {
//                    //self.updateShopButton("\(self.newTotal)")
//                    var savinAply : Double = 0.0
//                    var items = UserCurrentSession.sharedInstance().itemsGR as! [String:AnyObject]
//                    if let savingGR = items["saving"] as? NSNumber {
//                        savinAply =  savingGR.doubleValue
//                    }
//                    
//                    //NSDecimalNumber(string: String(format: "%.2f", itemPrice)
//                   // let total = "\(UserCurrentSession.sharedInstance().numberOfArticlesGR())"
//                   // let subTotal = String(format: "%.2f", self.newTotal)//"\(self.newTotal)"
//                   // let saving = String(format: "%.2f", self.totalDiscountsOrder + savinAply)//"\(self.totalDiscountsOrder + savinAply)"
//                    
////                    self.totalView.setTotalValues(total,
////                        subtotal: subTotal,
////                        saving: saving)
//                    
//                }
               // self.buildSubViews()
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
                self.showDiscountAsociate = true //res
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
                    
//                    self.totalView.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
//                        subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
//                        saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
//                    self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR() - UserCurrentSession.sharedInstance().estimateSavingGR() + self.shipmentAmount)")
                    
                    
                    
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
    
    
    //MARK : Actions
    
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
                posY += CGFloat(40 * count)
                
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
            }
            posY += 50
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
        let lheight: CGFloat = 25.0
        
//        self.payPalFuturePaymentField!.alpha = 0
//        var referenceFrame = self.paymentOptions!.frame
//        
//        if showPayPalFuturePayment{
//            self.payPalFuturePaymentField!.alpha = 1
//            referenceFrame = self.payPalFuturePaymentField!.frame
//        }
        
        
        self.paymentOptions!.frame = CGRectMake(margin, self.paymentOptions!.frame.minY, widthField, fheight)
        
        if showDiscountAsociate
        {
            self.discountAssociate!.alpha = 1
            self.sectionTitleDiscount!.alpha = 1
           // self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.paymentOptions!.frame.maxY + 10.0, widthField, fheight)
           // self.sectionTitleDiscount.frame = CGRectMake(margin, referenceFrame.maxY + 20.0, widthField, lheight)
            self.discountAssociate!.frame = CGRectMake(margin,sectionTitleDiscount.frame.maxY,widthField,fheight)
            
            let posY = self.buildPromotionButtons()
           // self.sectionTitleShipment.frame =  CGRectMake(margin, posY, widthField, lheight)
         //   self.address!.frame =  CGRectMake(margin, sectionTitleShipment.frame.maxY + 10.0, widthField, fheight)
            
        } else {
            if self.promotionsDesc.count > 0 {
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 1
               // self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.paymentOptions!.frame.maxY + 10.0, widthField, fheight)
                let posY = self.buildPromotionButtons()
                print("posY ::: posY \(posY)")
               // self.sectionTitleShipment.frame = CGRectMake(margin, posY, widthField, lheight)
               // self.address!.frame = CGRectMake(margin, sectionTitleShipment.frame.maxY + 10.0, widthField, fheight)
            }else{
                self.discountAssociate!.alpha = 0
                self.sectionTitleDiscount!.alpha = 0
               // self.payPalFuturePaymentField!.frame = CGRectMake(margin, self.paymentOptions!.frame.maxY + 10.0, widthField, fheight)
               // self.sectionTitleShipment.frame = CGRectMake(margin, referenceFrame.maxY + 20.0, widthField, lheight)
               // self.address!.frame = CGRectMake(margin, sectionTitleShipment.frame.maxY + 10.0, widthField, fheight)
            }
        }

        self.content.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.maxY + 20.0)
        
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
    
    //MARK :PaymentOptionsViewDelegate
    
    func paymentSelected(index: String, paymentString: String) {
        self.paymentString = paymentString
        self.paymentId = index
    }
    
    
    

}