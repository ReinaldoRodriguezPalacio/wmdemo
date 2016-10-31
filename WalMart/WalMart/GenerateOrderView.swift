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
        
        self.backgroundColor = UIColor.clear
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRect(x: 0, y: 0, width: 288, height: 464))
        viewContent.layer.cornerRadius = 8.0
        viewContent.clipsToBounds = true
        viewContent.backgroundColor = UIColor.white
        let backgroundImage = UIImageView(frame: viewContent.frame)
        backgroundImage.image = UIImage(named: "generateorderimage")
        self.viewContent.insertSubview(backgroundImage, at: 0)
        
        
        buttonClose = UIButton(frame: CGRect(x: marginViews, y: marginViews, width: 23, height: 23))
        buttonClose.addTarget(self, action: #selector(GenerateOrderView.editAction), for: UIControlEvents.touchUpInside)
        buttonClose.setImage(UIImage(named: "detail_close"), for: UIControlState())

        
        titleLabel = UILabel(frame: CGRect(x: buttonClose.frame.maxX - 35 , y: marginViews, width: viewContent.frame.width, height: 23))//
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.text = NSLocalizedString("gr.generate.title",comment: "")
        titleLabel.textAlignment = .center
        titleLabel.textColor = WMColor.light_blue
        
        
        
        let lblNumberItems = labelTitle(CGRect(x: marginViews, y: titleLabel.frame.maxY + 14, width: self.viewContent.frame.width - 32, height: 14))
        lblNumberItems.textColor = WMColor.blue
        lblNumberItems.font = WMFont.fontMyriadProSemiboldOfSize(14)
        lblNumberItems.text = "\(UserCurrentSession.sharedInstance().numberOfArticlesGR()) \(NSLocalizedString("artículos", comment: ""))"
        
        
        //right
        let lblTitleSubtotal = labelTitle(CGRect(x: marginViews, y: lblNumberItems.frame.maxY + 16, width: self.viewContent.frame.width - (32 + 75) , height: 14))
        lblTitleSubtotal.text = NSLocalizedString("gr.generate.subtotal", comment: "")
        lblTitleSubtotal.textColor = WMColor.reg_gray
        lblTitleSubtotal.font = WMFont.fontMyriadProRegularOfSize(14)
        
        
        let lblTitledeliveryAmount = labelTitle(CGRect(x: marginViews, y: lblTitleSubtotal.frame.maxY + 8,width: lblTitleSubtotal.frame.width,height: 15))
        lblTitledeliveryAmount.text = NSLocalizedString("gr.generate.deliveryAmount", comment: "")
        lblTitledeliveryAmount.textColor = WMColor.reg_gray
        lblTitledeliveryAmount.font = WMFont.fontMyriadProRegularOfSize(14)
        lblTitledeliveryAmount.tag =  100
        
        let lbldiscounts = labelTitle(CGRect(x: marginViews, y: lblTitledeliveryAmount.frame.maxY + 8, width: lblTitleSubtotal.frame.width, height: 14))
        lbldiscounts.text = NSLocalizedString("gr.generate.discount", comment: "")
        lbldiscounts.textColor = WMColor.reg_gray
        lbldiscounts.font = WMFont.fontMyriadProRegularOfSize(14)
        
        
        let lblTitleTotal = labelTitle(CGRect(x: marginViews, y: lbldiscounts.frame.maxY + 8, width: lblTitleSubtotal.frame.width , height: 14))
        lblTitleTotal.text = NSLocalizedString("gr.confirma.total", comment: "")
        lblTitleTotal.textColor = WMColor.blue
        lblTitleTotal.font = WMFont.fontMyriadProSemiboldOfSize(14)
        
        //left
        let lbldeliveryAddress = labelTitleBlue(CGRect(x: marginViews, y: lblTitleTotal.frame.maxY + 40, width: self.viewContent.frame.width - 32, height: 10))
        lbldeliveryAddress.text = NSLocalizedString("gr.generate.shipping", comment: "")
        lbldeliveryAddress.textColor = WMColor.light_blue
        lbldeliveryAddress.font = WMFont.fontMyriadProRegularOfSize(10)
        
        lblValueAddress = labelValue(CGRect(x: marginViews, y: lbldeliveryAddress.frame.maxY, width: self.viewContent.frame.width - 32, height: 28))
        lblValueAddress.numberOfLines = 2
        lblValueAddress.textColor = WMColor.reg_gray


        let lblTitleDeliveryDate = labelTitleBlue(CGRect(x: marginViews, y: lblValueAddress.frame.maxY + 6, width: self.viewContent.frame.width - 32, height: 10))
        lblTitleDeliveryDate.text = NSLocalizedString("gr.generate.deliverydate", comment: "")
        lbldeliveryAddress.textColor = WMColor.light_blue
        lbldeliveryAddress.font = WMFont.fontMyriadProRegularOfSize(10)
        
        lblValueDeliveryDate = labelValue(CGRect(x: marginViews, y: lblTitleDeliveryDate.frame.maxY, width: self.viewContent.frame.width - 32, height: 14))
        lblValueDeliveryDate.textColor = WMColor.reg_gray
        lblValueDeliveryDate.numberOfLines = 2
        
        
        let lblTitleDeliveryHour = labelTitleBlue(CGRect(x: marginViews, y: lblValueDeliveryDate.frame.maxY + 6,width: self.viewContent.frame.width - 32,height: 10))
        lblTitleDeliveryHour.text = NSLocalizedString("gr.generate.deliveryhour", comment: "")
        lblTitleDeliveryHour.textColor = WMColor.light_blue
        lblTitleDeliveryHour.font = WMFont.fontMyriadProRegularOfSize(10)
        
        lblValueDeliveryHour = labelValue(CGRect(x: marginViews, y: lblTitleDeliveryHour.frame.maxY, width: self.viewContent.frame.width - 32, height: lblValueDeliveryDate.frame.height))
        lblValueDeliveryHour.textColor = WMColor.reg_gray
        lblValueDeliveryHour.numberOfLines = 2

        
        
        let lblTitlePaymentType = labelTitleBlue(CGRect(x: marginViews, y: lblValueDeliveryHour.frame.maxY + 6,width: self.viewContent.frame.width - 32, height: 10))
        lblTitlePaymentType.text = NSLocalizedString("gr.generate.paymenttype", comment: "")
        
        lblValuePaymentType = labelValue(CGRect(x: marginViews, y: lblTitlePaymentType.frame.maxY, width: self.viewContent.frame.width - 32, height: lblValueDeliveryDate.frame.height))
        lblValuePaymentType.textColor = WMColor.reg_gray

        

        let lblTitleCommens = labelTitleBlue(CGRect(x: marginViews, y: lblValuePaymentType.frame.maxY + 6,width: self.viewContent.frame.width - 32, height: 10))
        lblTitleCommens.text = NSLocalizedString("checkout.title.confirm", comment: "")
        
        lblValueCommenst = labelValue(CGRect(x: marginViews, y: lblTitleCommens.frame.maxY, width: self.viewContent.frame.width - 32, height: 28))
        lblValueCommenst.textColor = WMColor.reg_gray
        lblValueCommenst.numberOfLines = 2
        
        //
        lblValueSubtotal = labelValueCurrency(CGRect(x: lblTitleSubtotal.frame.maxX + 10, y: lblTitleSubtotal.frame.minY , width: lblNumberItems.frame.maxX - (lblTitleSubtotal.frame.width + 26 ) , height: lblTitleSubtotal.frame.height))//subtotal
        lblValueDeliveryAmount = labelValueCurrency(CGRect(x: lblValueSubtotal.frame.origin.x, y: lblTitledeliveryAmount.frame.minY, width: lblValueSubtotal.frame.width, height: lblTitleSubtotal.frame.height))//envio
        lblValueDiscounts = UILabel(frame:CGRect(x: lblValueSubtotal.frame.origin.x, y: lbldiscounts.frame.minY,width: lblValueSubtotal.frame.width, height: lblTitleSubtotal.frame.height))//descuentos
        lblValueTotal = labelValueCurrency(CGRect(x: lblValueSubtotal.frame.origin.x, y: lblTitleTotal.frame.minY,  width: lblValueSubtotal.frame.width, height: lblTitleSubtotal.frame.height))//total


      
        

        
        buttonEditOrder = UIButton(frame: CGRect(x: marginViews, y: 418, width: 120, height: 34))
        buttonEditOrder.backgroundColor = WMColor.light_blue
        buttonEditOrder.layer.cornerRadius = 17
        buttonEditOrder.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonEditOrder.setTitle("Editar", for: UIControlState())
        buttonEditOrder.addTarget(self, action: #selector(GenerateOrderView.editAction), for: UIControlEvents.touchUpInside)
        
        buttonCreateOrder = UIButton(frame: CGRect(x: (self.viewContent.frame.width / 2) + 4, y: 418, width: 120, height: 34))
        buttonCreateOrder.backgroundColor = WMColor.green
        buttonCreateOrder.layer.cornerRadius = 17
        buttonCreateOrder.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonCreateOrder.setTitle("Generar Pedido", for: UIControlState())
        buttonCreateOrder.addTarget(self, action: #selector(GenerateOrderView.createOrderAction), for: UIControlEvents.touchUpInside)
        
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
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            return initDetail(vc!)
        }
        return nil
    }
    
    class func initDetail(_ controller:UIViewController) -> GenerateOrderView? {
        let newConfirm = GenerateOrderView(frame:controller.view.bounds)
        return newConfirm
    }
    
    func showDetail() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        self.frame = vc!.view.bounds
        vc!.view.addSubview(self)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
    }
    
    
    func showGenerateOrder(_ paramsToOrder:NSDictionary) {
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
        lblValueDiscounts.textAlignment = .right
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

    
    func labelTitle(_ frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(14)
        labelTitleItem.textColor = WMColor.dark_gray
        labelTitleItem.textAlignment = .right
        return labelTitleItem
    }
    
    func labelTitleBlue(_ frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(10)
        labelTitleItem.textColor = WMColor.light_blue
        labelTitleItem.textAlignment = .left
        return labelTitleItem
    }
    
    func labelValue(_ frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(14)
        labelTitleItem.textColor = WMColor.dark_gray
        return labelTitleItem
    }
    
    func labelValueCurrency(_ frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.textAlignment = .right
        return labelTitleItem
    }
    
}
