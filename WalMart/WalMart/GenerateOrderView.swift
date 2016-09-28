//
//  GenerateOrderView.swift
//  WalMart
//
//  Created by Alejandro MIranda on 16/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import AVFoundation

protocol GenerateOrderViewDelegate {
    func sendOrderConfirm()

}

 class GenerateOrderView : UIView {
    var delegate : GenerateOrderViewDelegate!
    
    
    var viewContent : UIView!
    var titleLabel : UILabel!
    var bgView : UIView!
    
    var buttonClose : UIButton!
    var buttonCreateOrder : UIButton!
    var buttonEditOrder : UIButton!


    var lblValueSubtotal : UILabel!
    var lblValueTotal : UILabel!
    var lblValueDeliveryAmount : UILabel!
    var lblValueDiscounts : UILabel!
    var lbldiscount : UILabel!
    
    
    var lblValueAddress : UILabel!
    var lblValueDeliveryDate : UILabel!
    var lblValueDeliveryHour : UILabel!
    var lblValuePaymentType : UILabel!
    var lblValueCommenst : UILabel!
    
    var imgBgView : UIImageView!
    let marginViews : CGFloat = 16.0
    var isFreshepping : Bool =  false

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.clearColor()
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRectMake(0, 0, 288, 464))
        viewContent.layer.cornerRadius = 8.0
        viewContent.clipsToBounds = true
        viewContent.backgroundColor = UIColor.whiteColor()
        let backgroundImage = UIImageView(frame: viewContent.frame)
        backgroundImage.image = UIImage(named: "generateorderimage")
        self.viewContent.insertSubview(backgroundImage, atIndex: 0)
        
        
        buttonClose = UIButton(frame: CGRectMake(marginViews, marginViews, 23, 23))
        buttonClose.addTarget(self, action: #selector(GenerateOrderView.editAction), forControlEvents: UIControlEvents.TouchUpInside)
        buttonClose.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)

        
        titleLabel = UILabel(frame: CGRectMake(buttonClose.frame.maxX - 35 , marginViews, viewContent.frame.width, 23))//
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.text = NSLocalizedString("gr.generate.title",comment: "")
        titleLabel.textAlignment = .Center
        titleLabel.textColor = WMColor.light_blue
        
        
        
        let lblNumberItems = labelTitle(CGRectMake(marginViews, titleLabel.frame.maxY + 14, self.viewContent.frame.width - 32, 14))
        lblNumberItems.textColor = WMColor.blue
        lblNumberItems.font = WMFont.fontMyriadProSemiboldOfSize(14)
        lblNumberItems.text = "\(UserCurrentSession.sharedInstance().numberOfArticlesGR()) \(NSLocalizedString("artículos", comment: ""))"
        
        
        //right
        let lblTitleSubtotal = labelTitle(CGRectMake(marginViews, lblNumberItems.frame.maxY + 16, self.viewContent.frame.width - (32 + 75) , 14))
        lblTitleSubtotal.text = NSLocalizedString("gr.generate.subtotal", comment: "")
        lblTitleSubtotal.textColor = WMColor.reg_gray
        lblTitleSubtotal.font = WMFont.fontMyriadProRegularOfSize(14)
        
        
        let lblTitledeliveryAmount = labelTitle(CGRectMake(marginViews, lblTitleSubtotal.frame.maxY + 8,lblTitleSubtotal.frame.width,15))
        lblTitledeliveryAmount.text = NSLocalizedString("gr.generate.deliveryAmount", comment: "")
        lblTitledeliveryAmount.textColor = WMColor.reg_gray
        lblTitledeliveryAmount.font = WMFont.fontMyriadProRegularOfSize(14)
        lblTitledeliveryAmount.tag =  100
        
        let lbldiscounts = labelTitle(CGRectMake(marginViews, lblTitledeliveryAmount.frame.maxY + 8, lblTitleSubtotal.frame.width, 14))
        lbldiscounts.text = NSLocalizedString("gr.generate.discount", comment: "")
        lbldiscounts.textColor = WMColor.reg_gray
        lbldiscounts.font = WMFont.fontMyriadProRegularOfSize(14)
        
        
        let lblTitleTotal = labelTitle(CGRectMake(marginViews, lbldiscounts.frame.maxY + 8, lblTitleSubtotal.frame.width , 14))
        lblTitleTotal.text = NSLocalizedString("gr.confirma.total", comment: "")
        lblTitleTotal.textColor = WMColor.blue
        lblTitleTotal.font = WMFont.fontMyriadProSemiboldOfSize(14)
        
        //left
        let lbldeliveryAddress = labelTitleBlue(CGRectMake(marginViews, lblTitleTotal.frame.maxY + 40, self.viewContent.frame.width - 32, 10))
        lbldeliveryAddress.text = NSLocalizedString("gr.generate.shipping", comment: "")
        lbldeliveryAddress.textColor = WMColor.light_blue
        lbldeliveryAddress.font = WMFont.fontMyriadProRegularOfSize(10)
        
        lblValueAddress = labelValue(CGRectMake(marginViews, lbldeliveryAddress.frame.maxY, self.viewContent.frame.width - 32, 28))
        lblValueAddress.numberOfLines = 2
        lblValueAddress.textColor = WMColor.reg_gray


        let lblTitleDeliveryDate = labelTitleBlue(CGRectMake(marginViews, lblValueAddress.frame.maxY + 6, self.viewContent.frame.width - 32, 10))
        lblTitleDeliveryDate.text = NSLocalizedString("gr.generate.deliverydate", comment: "")
        lbldeliveryAddress.textColor = WMColor.light_blue
        lbldeliveryAddress.font = WMFont.fontMyriadProRegularOfSize(10)
        
        lblValueDeliveryDate = labelValue(CGRectMake(marginViews, lblTitleDeliveryDate.frame.maxY, self.viewContent.frame.width - 32, 14))
        lblValueDeliveryDate.textColor = WMColor.reg_gray
        lblValueDeliveryDate.numberOfLines = 2
        
        
        let lblTitleDeliveryHour = labelTitleBlue(CGRectMake(marginViews, lblValueDeliveryDate.frame.maxY + 6,self.viewContent.frame.width - 32,10))
        lblTitleDeliveryHour.text = NSLocalizedString("gr.generate.deliveryhour", comment: "")
        lblTitleDeliveryHour.textColor = WMColor.light_blue
        lblTitleDeliveryHour.font = WMFont.fontMyriadProRegularOfSize(10)
        
        lblValueDeliveryHour = labelValue(CGRectMake(marginViews, lblTitleDeliveryHour.frame.maxY, self.viewContent.frame.width - 32, lblValueDeliveryDate.frame.height))
        lblValueDeliveryHour.textColor = WMColor.reg_gray
        lblValueDeliveryHour.numberOfLines = 2

        
        
        let lblTitlePaymentType = labelTitleBlue(CGRectMake(marginViews, lblValueDeliveryHour.frame.maxY + 6,self.viewContent.frame.width - 32, 10))
        lblTitlePaymentType.text = NSLocalizedString("gr.generate.paymenttype", comment: "")
        
        lblValuePaymentType = labelValue(CGRectMake(marginViews, lblTitlePaymentType.frame.maxY, self.viewContent.frame.width - 32, lblValueDeliveryDate.frame.height))
        lblValuePaymentType.textColor = WMColor.reg_gray

        

        let lblTitleCommens = labelTitleBlue(CGRectMake(marginViews, lblValuePaymentType.frame.maxY + 6,self.viewContent.frame.width - 32, 10))
        lblTitleCommens.text = NSLocalizedString("checkout.title.confirm", comment: "")
        
        lblValueCommenst = labelValue(CGRectMake(marginViews, lblTitleCommens.frame.maxY, self.viewContent.frame.width - 32, 28))
        lblValueCommenst.textColor = WMColor.reg_gray
        lblValueCommenst.numberOfLines = 2
        
        //
        lblValueSubtotal = labelValueCurrency(CGRectMake(lblTitleSubtotal.frame.maxX + 10, lblTitleSubtotal.frame.minY , lblNumberItems.frame.maxX - (lblTitleSubtotal.frame.width + 26 ) , lblTitleSubtotal.frame.height))//subtotal
        lblValueDeliveryAmount = labelValueCurrency(CGRectMake(lblValueSubtotal.frame.origin.x, lblTitledeliveryAmount.frame.minY, lblValueSubtotal.frame.width, lblTitleSubtotal.frame.height))//envio
        lblValueDiscounts = UILabel(frame:CGRectMake(lblValueSubtotal.frame.origin.x, lbldiscounts.frame.minY,lblValueSubtotal.frame.width, lblTitleSubtotal.frame.height))//descuentos
        lblValueTotal = labelValueCurrency(CGRectMake(lblValueSubtotal.frame.origin.x, lblTitleTotal.frame.minY,  lblValueSubtotal.frame.width, lblTitleSubtotal.frame.height))//total


      
        

        
        buttonEditOrder = UIButton(frame: CGRectMake(marginViews, 418, 120, 34))
        buttonEditOrder.backgroundColor = WMColor.light_blue
        buttonEditOrder.layer.cornerRadius = 17
        buttonEditOrder.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonEditOrder.setTitle("Editar", forState: UIControlState.Normal)
        buttonEditOrder.addTarget(self, action: #selector(GenerateOrderView.editAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonCreateOrder = UIButton(frame: CGRectMake((self.viewContent.frame.width / 2) + 4, 418, 120, 34))
        buttonCreateOrder.backgroundColor = WMColor.green
        buttonCreateOrder.layer.cornerRadius = 17
        buttonCreateOrder.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonCreateOrder.setTitle("Generar Pedido", forState: UIControlState.Normal)
        buttonCreateOrder.addTarget(self, action: #selector(GenerateOrderView.createOrderAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewContent.addSubview(titleLabel)
        viewContent.addSubview(lblNumberItems)
        viewContent.addSubview(lblTitleSubtotal)
        viewContent.addSubview(lblTitledeliveryAmount)
        viewContent.addSubview(lbldiscounts)
        viewContent.addSubview(lblTitleTotal)
        
        viewContent.addSubview(lbldeliveryAddress)
        viewContent.addSubview(lblTitleDeliveryDate)
        viewContent.addSubview(lblTitleDeliveryHour)
        viewContent.addSubview(lblTitlePaymentType)
        viewContent.addSubview(lblTitleCommens)
       
        viewContent.addSubview(lblValueAddress)
        viewContent.addSubview(lblValueDeliveryDate)
        viewContent.addSubview(lblValueDeliveryAmount)
        viewContent.addSubview(lblValueDiscounts)
        viewContent.addSubview(lblValueCommenst)
        
        viewContent.addSubview(lblValueDeliveryHour)
        viewContent.addSubview(lblValuePaymentType)
        viewContent.addSubview(lblValueSubtotal)
        viewContent.addSubview(lblValueTotal)
 
        viewContent.addSubview(buttonClose)
        viewContent.addSubview(buttonEditOrder)
        viewContent.addSubview(buttonCreateOrder)
        self.addSubview(viewContent)
        
        imgBgView = UIImageView(frame: self.bgView.bounds)
        self.bgView.addSubview(imgBgView)

    }
    
    
    
    
    class func initDetail()  -> GenerateOrderView? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            return initDetail(vc!)
        }
        return nil
    }
    
    class func initDetail(controller:UIViewController) -> GenerateOrderView? {
        let newConfirm = GenerateOrderView(frame:controller.view.bounds)
        return newConfirm
    }
    
    func showDetail() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        self.frame = vc!.view.bounds
        vc!.view.addSubview(self)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
    }
    
    
    func showGenerateOrder(paramsToOrder:NSDictionary) {
        //right
        
        var stringValue =  CurrencyCustomLabel.formatString(paramsToOrder["subtotal"] as! String)
        lblValueSubtotal.text = stringValue
        lblValueSubtotal.font = WMFont.fontMyriadProRegularOfSize(14)
        lblValueSubtotal.textColor = WMColor.dark_gray
        lblValueSubtotal.text = stringValue
        
        stringValue =  CurrencyCustomLabel.formatString(paramsToOrder["total"] as! String)
        lblValueTotal.text = stringValue
        lblValueTotal.font = WMFont.fontMyriadProSemiboldOfSize(14)
        lblValueTotal.textColor = WMColor.blue
        
        stringValue =  CurrencyCustomLabel.formatString(paramsToOrder["shipmentAmount"] as! String)
        lblValueDeliveryAmount.text = self.isFreshepping ? "sin costo" :  stringValue
        lblValueDeliveryAmount.font = WMFont.fontMyriadProRegularOfSize(14)
        lblValueDeliveryAmount.textColor = WMColor.dark_gray

        stringValue =  CurrencyCustomLabel.formatNegativeString(paramsToOrder["Discounts"] as! String)
        lblValueDiscounts.font = WMFont.fontMyriadProRegularOfSize(14)
        lblValueDiscounts.textAlignment = .Right
        lblValueDiscounts.textColor = WMColor.dark_gray
        lblValueDiscounts.text = stringValue
        //left
        lblValueAddress.text = paramsToOrder["address"] as? String
        lblValueDeliveryDate.text = paramsToOrder["date"] as? String
        lblValueDeliveryHour.text = paramsToOrder["hour"] as? String
        lblValuePaymentType.text = paramsToOrder["PaymentType"] as? String
        lblValueCommenst.text = paramsToOrder["pickingInstruction"] as? String

        self.viewContent.center = self.center
    }
    
    func btnClose() {
        self.removeFromSuperview()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame =  self.bounds
        viewContent.center = self.center
    }
    
    func createOrderAction() {
        self.delegate.sendOrderConfirm()
        self.removeFromSuperview()
    }
    
    func editAction() {
        self.removeFromSuperview()
    }

    
    func labelTitle(frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(14)
        labelTitleItem.textColor = WMColor.dark_gray
        labelTitleItem.textAlignment = .Right
        return labelTitleItem
    }
    
    func labelTitleBlue(frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(10)
        labelTitleItem.textColor = WMColor.light_blue
        labelTitleItem.textAlignment = .Left
        return labelTitleItem
    }
    
    func labelValue(frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(14)
        labelTitleItem.textColor = WMColor.dark_gray
        return labelTitleItem
    }
    
    func labelValueCurrency(frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.textAlignment = .Right
        return labelTitleItem
    }
    
}