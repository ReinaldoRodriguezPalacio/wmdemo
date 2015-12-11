//
//  OrderConfirmDetailView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/24/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import AVFoundation

protocol OrderConfirmDetailViewDelegate {
    func didFinishConfirm()
    func didErrorConfirm()
}

class OrderConfirmDetailView : UIView {
    
    var delegate : OrderConfirmDetailViewDelegate!
    let maxAnimationSize : CGFloat = 30
    
    var viewContent : UIView!
    var viewHeader: UIView!
    var titleLabel : UILabel!
    var bgView : UIView!
    var buttonOk : UIButton!
    var imageBarCode : UIImageView!
    var lblTitleTrackingNumber : UILabel!
    var iconLoadingDone : UIImageView!
    var viewLoadingDoneAnimate : UIView!
    var viewLoadingDoneAnimateAux : UIView!
    
    var trackingNumber = ""
    var deliveryDate = ""
    var deliveryHour = ""
    var paymentType = ""
    var subtotal = ""
    var total = ""
    
    var lblValueDeliveryDate : UILabel!
    var lblValueDeliveryHour : UILabel!
    var lblValuePaymentType : UILabel!
    var lblValueSubtotal : UILabel!
    var lblValueTotal : UILabel!
    var lblValueDeliveryAmount : UILabel!
    var lblValueDiscountsAssociated : UILabel!
    var lbldiscountsAssociated : UILabel!
    
    
    var deliveryAmount : Double!
    var discountsAssociated : Double!
    
    var timmerAnimation : NSTimer!
    let animating : Bool = true
    
    var imgBgView : UIImageView!
    

    
    
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
        
   
        viewContent = UIView(frame: CGRectMake(0, 0, 288, 264))
        viewContent.layer.cornerRadius = 8.0
        viewContent.clipsToBounds = true
        viewContent.backgroundColor = UIColor.clearColor()
        viewContent.clipsToBounds = true
        
        let imgIcon =  UIImage(named:"order_icon")
        iconLoadingDone = UIImageView(frame: CGRectMake((self.viewContent.frame.width / 2) - (imgIcon!.size.width / 2), 77, imgIcon!.size.width, imgIcon!.size.height))
        iconLoadingDone.image = imgIcon
        
        let imgConfirm = UIImageView(frame: CGRectMake(0, 0, 288, 464))
        imgConfirm.image = UIImage(named: "confirm_bg")
        viewContent.addSubview(imgConfirm)
        
        buttonOk = UIButton(frame: CGRectMake((self.viewContent.frame.width / 2) - 49, 418, 98, 34))
        buttonOk.backgroundColor = WMColor.UIColorFromRGB(0x2970ca)
        buttonOk.layer.cornerRadius = 17
        buttonOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonOk.setTitle("Ok", forState: UIControlState.Normal)
        buttonOk.addTarget(self, action: "okAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        titleLabel = UILabel(frame: CGRectMake(0, 24, viewContent.frame.width, 18))
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.text = NSLocalizedString("gr.confirma.generatingorden",comment: "")
        titleLabel.textAlignment = .Center
        titleLabel.textColor = WMColor.headerViewBgCollor
        
        imageBarCode = UIImageView(frame: CGRectMake((self.viewContent.frame.width / 2) - 102, iconLoadingDone.frame.maxY + 16, 206, 56))
        
        
        lblTitleTrackingNumber = UILabel(frame: CGRectMake(0, 244, viewContent.frame.width, 14))
        lblTitleTrackingNumber.font = WMFont.fontMyriadProRegularOfSize(14)
        lblTitleTrackingNumber.text = NSLocalizedString("gr.confirma.trakingnum",comment: "")
        lblTitleTrackingNumber.textAlignment = .Center
        lblTitleTrackingNumber.textColor = WMColor.lineTextColor
        
        
        let lblTitleDeliveryDate = labelTitle(CGRectMake(48, 274, 80, 12))
        lblTitleDeliveryDate.text = NSLocalizedString("gr.confirma.deliverydate", comment: "")
        
        let lblTitleDeliveryHour = labelTitle(CGRectMake(160, lblTitleDeliveryDate.frame.minY, lblTitleDeliveryDate.frame.width, lblTitleDeliveryDate.frame.height))
        lblTitleDeliveryHour.text = NSLocalizedString("gr.confirma.deliveryhour", comment: "")
        
        let lblTitlePaymentType = labelTitle(CGRectMake(48, 306, lblTitleDeliveryHour.frame.width, lblTitleDeliveryHour.frame.height))
        lblTitlePaymentType.text = NSLocalizedString("gr.confirma.paymenttype", comment: "")
        
        let lblTitleSubtotal = labelTitle(CGRectMake(48, 370, lblTitleDeliveryHour.frame.width, lblTitleDeliveryHour.frame.height))
        lblTitleSubtotal.text = NSLocalizedString("gr.confirma.subtotal", comment: "")
        
        lbldiscountsAssociated = labelTitle(CGRectMake(160, 338, lblTitleDeliveryHour.frame.maxX, lblTitleDeliveryHour.frame.height))
        lbldiscountsAssociated.text = NSLocalizedString("gr.confirma.descuentodeasociado", comment: "")

        
        let lblTitleTotal = labelTitle(CGRectMake(160, 370, lblTitleDeliveryHour.frame.width, lblTitleDeliveryHour.frame.height))
        lblTitleTotal.text = NSLocalizedString("gr.confirma.total", comment: "")
        
        let lblTitledeliveryAmount = labelTitle(CGRectMake(48, 338, lblTitleDeliveryHour.frame.width, lblTitleDeliveryHour.frame.height))
        lblTitledeliveryAmount.text = NSLocalizedString("gr.confirma.costodeenvio", comment: "")

        
        lblValueDeliveryDate = labelValue(CGRectMake(48, lblTitleDeliveryDate.frame.maxY, 80, 14))
        lblValueDeliveryHour = labelValue(CGRectMake(160, lblTitleDeliveryDate.frame.maxY, 80, lblValueDeliveryDate.frame.height))
        lblValuePaymentType = labelValue(CGRectMake(48, lblTitlePaymentType.frame.maxY, self.viewContent.frame.width - 48, lblValueDeliveryDate.frame.height))
        lblValueDeliveryAmount = labelValue(CGRectMake(48, lblTitledeliveryAmount.frame.maxY, 80, lblValueDeliveryDate.frame.height))
        lblValueSubtotal = labelValue(CGRectMake(48, lblTitleSubtotal.frame.maxY, 80, lblValueDeliveryDate.frame.height))
        lblValueDiscountsAssociated = labelValue(CGRectMake(160, lbldiscountsAssociated.frame.maxY, 80, lblValueDeliveryDate.frame.height))
        lblValueTotal = labelValue(CGRectMake(160, lblTitleSubtotal.frame.maxY, 80, lblValueDeliveryDate.frame.height))
        
      
        
        viewLoadingDoneAnimate = UIView()
        viewLoadingDoneAnimate.backgroundColor = WMColor.UIColorFromRGB(0x2970ca , alpha: 0.5)
        viewLoadingDoneAnimate.frame = CGRectMake(0, 0,  imgIcon!.size.width - 2, imgIcon!.size.height - 2)
        viewLoadingDoneAnimate.center = iconLoadingDone.center
        viewLoadingDoneAnimate.layer.cornerRadius = (imgIcon!.size.height - 2) / 2
        
        viewLoadingDoneAnimateAux = UIView()
        viewLoadingDoneAnimateAux.backgroundColor = WMColor.UIColorFromRGB(0x2970ca , alpha: 0.5)
        viewLoadingDoneAnimateAux.frame = CGRectMake(0, 0,  imgIcon!.size.width - 2, imgIcon!.size.height - 2)
        viewLoadingDoneAnimateAux.center = iconLoadingDone.center
        viewLoadingDoneAnimateAux.layer.cornerRadius = (imgIcon!.size.height - 2) / 2

        

        viewContent.addSubview(titleLabel)
        viewContent.addSubview(imageBarCode)
        viewContent.addSubview(lblTitleTrackingNumber)
        viewContent.addSubview(lblTitleDeliveryDate)
        viewContent.addSubview(lblTitledeliveryAmount)
        viewContent.addSubview(lbldiscountsAssociated)

        viewContent.addSubview(lblTitleDeliveryHour)
        viewContent.addSubview(lblTitlePaymentType)
        viewContent.addSubview(lblTitleSubtotal)
        viewContent.addSubview(lblTitleTotal)
        viewContent.addSubview(lblValueDeliveryDate)
        viewContent.addSubview(lblValueDeliveryAmount)
        viewContent.addSubview(lblValueDiscountsAssociated)
        
        
        viewContent.addSubview(lblValueDeliveryHour)
        viewContent.addSubview(lblValuePaymentType)
        viewContent.addSubview(lblValueSubtotal)
        viewContent.addSubview(lblValueTotal)
        viewContent.addSubview(viewLoadingDoneAnimate)
        viewContent.addSubview(viewLoadingDoneAnimateAux)
        viewContent.addSubview(iconLoadingDone)
        
        viewContent.addSubview(buttonOk)
        self.addSubview(viewContent)
        
        imgBgView = UIImageView(frame: self.bgView.bounds)
        self.bgView.addSubview(imgBgView)
        
        
    }
    
    
   
    
    class func initDetail()  -> OrderConfirmDetailView? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            return initDetail(vc!)
        }
        return nil
    }
    
    class func initDetail(controller:UIViewController) -> OrderConfirmDetailView? {
        let newConfirm = OrderConfirmDetailView(frame:controller.view.bounds)
        return newConfirm
    }
    
    func showDetail() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        vc!.view.addSubview(self)
        let imgBack =  UIImage(fromView:vc!.view,size:self.bgView.bounds.size)
        let imgBackBlur = imgBack.applyLightEffect()
        imgBgView.image = imgBackBlur
        
        self.startAnimating()
    }
    
    
    func startAnimating() {
        
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.6)
        self.bgView.addSubview(bgViewAlpha)
        
        bgView.alpha = 0
        viewContent.transform = CGAffineTransformMakeTranslation(0,500)
        
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransformIdentity
            })
      
            
            }) { (complete:Bool) -> Void in
                
        }
        
        self.animate()

        
    }
    
    func completeOrder(trakingNumber:String,deliveryDate:String,deliveryHour:String,paymentType:String,subtotal:String,total:String,deliveryAmount:String,discountsAssociated:String) {
        
        var imageCode = RSUnifiedCodeGenerator.shared.generateCode(trakingNumber, machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)
        if imageCode == nil {
            imageCode = UIImage(named: "barcode")
        }
        
        imageBarCode.image = imageCode
        
        let stgrEnd = lblTitleTrackingNumber.text!
        let endTracking = "\(stgrEnd)\(trakingNumber)"
        lblValueDeliveryDate.text = deliveryDate
        lblValueDeliveryHour.text = deliveryHour
        lblValuePaymentType.text = paymentType
        lblValueSubtotal.text = subtotal
        lblValueTotal.text = total
        lblValueDeliveryAmount.text = deliveryAmount
        lblValueDiscountsAssociated.text = "\(discountsAssociated)"
            if discountsAssociated == "0.0"{
                lblValueDiscountsAssociated.hidden = true
                lbldiscountsAssociated.hidden = true
            }
            
            

        
        lblTitleTrackingNumber.text = endTracking
        
        viewLoadingDoneAnimate.layer.removeAllAnimations()
        viewLoadingDoneAnimateAux.layer.removeAllAnimations()
        
        viewLoadingDoneAnimateAux.alpha = 0.0
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewContent.frame = CGRectMake(0, 0, 288, 494)
            self.viewContent.center = self.center
        }) { (complete) -> Void in
            
            self.viewLoadingDoneAnimate.transform = CGAffineTransformMakeScale(1.2,1.2)
            
            self.titleLabel.text = NSLocalizedString("gr.confirma.title",comment: "")
            
            self.viewLoadingDoneAnimate.backgroundColor = WMColor.green.colorWithAlphaComponent(0.5)

            self.iconLoadingDone.image = UIImage(named:"done_order")
            let animation = CAKeyframeAnimation()
            animation.keyPath = "transform.scale"
            animation.duration = 0.6
            animation.removedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            animation.repeatCount = 1
            animation.values = [0, 1.3,1]
            self.iconLoadingDone.layer.addAnimation(animation, forKey: "grow")

            
        }
       
        
    }
    
    func errorOrder(descError:String) {
        
        viewLoadingDoneAnimate.layer.removeAllAnimations()
        viewLoadingDoneAnimateAux.layer.removeAllAnimations()
        
        self.titleLabel.text = descError
        
        let buttonNOk = UIButton(frame: CGRectMake((self.viewContent.frame.width / 2) - 49, viewLoadingDoneAnimate.frame.maxY + 32, 98, 34))
        buttonNOk.backgroundColor = WMColor.UIColorFromRGB(0x2970ca)
        buttonNOk.layer.cornerRadius = 17
        buttonNOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonNOk.setTitle("Ok", forState: UIControlState.Normal)
        buttonNOk.addTarget(self, action: "noOkAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.viewContent.addSubview(buttonNOk)
        
        self.titleLabel.frame = CGRectMake(0, 24, viewContent.frame.width, 36)
        self.titleLabel.numberOfLines = 2
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame =  self.bounds
        viewContent.center = self.center
        
    }
    
    func okAction() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_FINIHS_ORDER.rawValue , label: "ok order")
        self.delegate.didFinishConfirm()
        self.removeFromSuperview()
    }
    
    func noOkAction() {
        self.delegate.didErrorConfirm()
        self.removeFromSuperview()
    }
    
    func labelTitle(frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(12)
        labelTitleItem.textColor = WMColor.confirmTitleItem
        return labelTitleItem
    }
    
    func labelValue(frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(14)
        labelTitleItem.textColor = WMColor.headerViewBgCollor
        return labelTitleItem
    }
    


    func animate() {
        
        var animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.duration = 1
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = Float.infinity
        animation.values = [1, 1.5]
        viewLoadingDoneAnimate.layer.addAnimation(animation, forKey: "grow")
        
        var animationOp = CAKeyframeAnimation()
        animationOp.keyPath = "opacity"
        animationOp.duration = 1
        animationOp.removedOnCompletion = false
        animationOp.fillMode = kCAFillModeForwards
        animationOp.repeatCount = Float.infinity
        animationOp.values = [1, 0]
        viewLoadingDoneAnimate.layer.addAnimation(animationOp, forKey: "alpha0")
        
        animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.beginTime = CACurrentMediaTime() + 0.5
        animation.duration = 1
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = Float.infinity
        animation.values = [1, 1.5]
        viewLoadingDoneAnimateAux.layer.addAnimation(animation, forKey: "grow")
        
        animationOp = CAKeyframeAnimation()
        animationOp.keyPath = "opacity"
        animationOp.beginTime = CACurrentMediaTime() + 0.5
        animationOp.duration = 1
        animationOp.removedOnCompletion = false
        animationOp.fillMode = kCAFillModeForwards
        animationOp.repeatCount = Float.infinity
        animationOp.values = [1, 0]
        viewLoadingDoneAnimateAux.layer.addAnimation(animationOp, forKey: "alpha0")
        
        
    }
    
}