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
    var lbldiscountsAssociated : UILabel!
    
    
    var lblValueAddress : UILabel!
    var lblValueDeliveryDate : UILabel!
    var lblValueDeliveryHour : UILabel!
    var lblValuePaymentType : UILabel!
    var lblValueCommenst : UILabel!
    
    var imgBgView : UIImageView!
    let marginViews : CGFloat = 16.0

    
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
        
        
        titleLabel = UILabel(frame: CGRectMake(0, marginViews, viewContent.frame.width, 18))
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.text = NSLocalizedString("gr.generate.title",comment: "")
        titleLabel.textAlignment = .Center
        titleLabel.textColor = WMColor.light_blue
        
        
        
        let lblNumberItems = labelTitle(CGRectMake(marginViews, titleLabel.frame.maxY + 14, self.viewContent.frame.width - 32, 14))
        lblNumberItems.textColor = WMColor.light_blue
        lblNumberItems.text = "12 \(NSLocalizedString("artículos", comment: ""))"
        
        
        //right
        let lblTitleSubtotal = labelTitle(CGRectMake(marginViews, lblNumberItems.frame.maxY + 16, self.viewContent.frame.width - (32 + 75) , 14))
        lblTitleSubtotal.text = NSLocalizedString("gr.generate.subtotal", comment: "")
        
        let lblTitledeliveryAmount = labelTitle(CGRectMake(marginViews, lblTitleSubtotal.frame.maxY + 8,lblTitleSubtotal.frame.width,15))
        lblTitledeliveryAmount.text = NSLocalizedString("gr.generate.deliveryAmount", comment: "")
        
        let lbldiscountsAssociated = labelTitle(CGRectMake(marginViews, lblTitledeliveryAmount.frame.maxY + 8, lblTitleSubtotal.frame.width, 14))
        lbldiscountsAssociated.text = NSLocalizedString("gr.generate.discountAssociate", comment: "")
        
        let lblTitleTotal = labelTitle(CGRectMake(marginViews, lbldiscountsAssociated.frame.maxY + 8, lblTitleSubtotal.frame.width , 14))
        lblTitleTotal.text = NSLocalizedString("gr.confirma.total", comment: "")
        
        
        
        
        //left
        let lbldeliveryAddress = labelTitleBlue(CGRectMake(marginViews, lblTitleTotal.frame.maxY + 40, self.viewContent.frame.width - 32, 10))
        lbldeliveryAddress.text = NSLocalizedString("gr.generate.shipping", comment: "")
        
        lblValueAddress = labelValue(CGRectMake(marginViews, lbldeliveryAddress.frame.maxY + 6, (self.viewContent.frame.width / 3 ) * 2, 28))
        lblValueAddress.numberOfLines = 2

        let lblTitleDeliveryDate = labelTitleBlue(CGRectMake(marginViews, lblValueAddress.frame.maxY + 6, self.viewContent.frame.width - 32, 10))
        lblTitleDeliveryDate.text = NSLocalizedString("gr.generate.deliverydate", comment: "")
        
        lblValueDeliveryDate = labelValue(CGRectMake(marginViews, lblTitleDeliveryDate.frame.maxY + 6, 80, 14))
        
        
        let lblTitleDeliveryHour = labelTitleBlue(CGRectMake(marginViews, lblValueDeliveryDate.frame.maxY + 6,self.viewContent.frame.width - 32,10))
        lblTitleDeliveryHour.text = NSLocalizedString("gr.generate.deliveryhour", comment: "")
        
        lblValueDeliveryHour = labelValue(CGRectMake(marginViews, lblTitleDeliveryHour.frame.maxY + 6, 80, lblValueDeliveryDate.frame.height))
        
        
        let lblTitlePaymentType = labelTitleBlue(CGRectMake(marginViews, lblValueDeliveryHour.frame.maxY + 6,self.viewContent.frame.width - 32, 10))
        lblTitlePaymentType.text = NSLocalizedString("gr.generate.paymenttype", comment: "")
        
        lblValuePaymentType = labelValue(CGRectMake(marginViews, lblTitlePaymentType.frame.maxY + 6, self.viewContent.frame.width - 48, lblValueDeliveryDate.frame.height))
        

        let lblTitleCommens = labelTitleBlue(CGRectMake(marginViews, lblValuePaymentType.frame.maxY + 6,self.viewContent.frame.width - 32, 10))
        lblTitleCommens.text = NSLocalizedString("Si algun artículo no esta disponble", comment: "")
        
        lblValueCommenst = labelValue(CGRectMake(marginViews, lblTitleCommens.frame.maxY + 6, self.viewContent.frame.width - 48, lblValueDeliveryDate.frame.height))
        
        
        
        
        //
        lblValueSubtotal = labelValue(CGRectMake(lblTitleSubtotal.frame.maxX + 10, lblTitleSubtotal.frame.minY , lblNumberItems.frame.maxX - (lblTitleSubtotal.frame.width + 26 ) , lblTitleSubtotal.frame.height))//subtotal
        lblValueSubtotal.textAlignment = .Right
        
        lblValueDeliveryAmount = labelValue(CGRectMake(lblValueSubtotal.frame.origin.x, lblTitledeliveryAmount.frame.minY, lblValueSubtotal.frame.width, lblTitleSubtotal.frame.height))//envio
        lblValueDeliveryAmount.textAlignment = .Right
        
        lblValueDiscounts = labelValue(CGRectMake(lblValueSubtotal.frame.origin.x, lbldiscountsAssociated.frame.minY,lblValueSubtotal.frame.width, lblTitleSubtotal.frame.height))//descuentos
        lblValueDiscounts.textAlignment =  .Right
        lblValueTotal = labelValue(CGRectMake(lblValueSubtotal.frame.origin.x, lblTitleTotal.frame.minY,  lblValueSubtotal.frame.width, lblTitleSubtotal.frame.height))//total
        lblValueTotal.textAlignment =  .Right
      
        
        
        
       
       
        
        
   
        buttonEditOrder = UIButton(frame: CGRectMake(marginViews, 418, 120, 34))
        buttonEditOrder.backgroundColor = WMColor.light_blue
        buttonEditOrder.layer.cornerRadius = 17
        buttonEditOrder.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonEditOrder.setTitle("Editar", forState: UIControlState.Normal)
        buttonEditOrder.addTarget(self, action: "editAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonCreateOrder = UIButton(frame: CGRectMake((self.viewContent.frame.width / 2) + 4, 418, 120, 34))
        buttonCreateOrder.backgroundColor = WMColor.green
        buttonCreateOrder.layer.cornerRadius = 17
        buttonCreateOrder.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonCreateOrder.setTitle("Generar Pedido", forState: UIControlState.Normal)
        buttonCreateOrder.addTarget(self, action: "createOrderAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        viewContent.addSubview(titleLabel)
        viewContent.addSubview(lblNumberItems)
        viewContent.addSubview(lblTitleSubtotal)
        viewContent.addSubview(lblTitledeliveryAmount)
        viewContent.addSubview(lbldiscountsAssociated)
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
    
    
    func showConfirmOrder(paramsOrder:NSDictionary) {
        
        //right
        lblValueSubtotal.text = "$1,400.10"
        lblValueTotal.text = "$1,230.00"
        lblValueDeliveryAmount.text = "$56.10"
        lblValueDiscounts.text = "-$80.10"
        
        //left
        lblValueAddress.text = "Av. insurgentes sur 1277 San Jose Insurgentes"
        lblValueDeliveryDate.text = "fecha"
        lblValueDeliveryHour.text = "12:22"
        lblValuePaymentType.text = "Tarjeta de Credito bancos walmart"
        lblValueCommenst.text = "LLamar para revisar alternativas"

        self.viewContent.center = self.center
        
        
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
    
}