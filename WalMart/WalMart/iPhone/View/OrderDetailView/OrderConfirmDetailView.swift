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
    
    var timmerAnimation : Timer!
    let animating : Bool = true
    
    var imgBgView : UIImageView!
    

    let KEY_RATING = "ratingEnabled"
    
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
        
   
        viewContent = UIView(frame: CGRect(x: 0, y: 0, width: 288, height: 264))
        viewContent.layer.cornerRadius = 8.0
        viewContent.clipsToBounds = true
        viewContent.backgroundColor = UIColor.clear
        viewContent.clipsToBounds = true
        
        let imgIcon =  UIImage(named:"order_icon")
        iconLoadingDone = UIImageView(frame: CGRect(x: (self.viewContent.frame.width / 2) - (imgIcon!.size.width / 2), y: 77, width: imgIcon!.size.width, height: imgIcon!.size.height))
        iconLoadingDone.image = imgIcon
        
        let imgConfirm = UIImageView(frame: CGRect(x: 0, y: 0, width: 288, height: 464))
        imgConfirm.image = UIImage(named: "confirm_bg")
        viewContent.addSubview(imgConfirm)
        
        buttonOk = UIButton(frame: CGRect(x: (self.viewContent.frame.width / 2) - 49, y: 418, width: 98, height: 34))
        buttonOk.backgroundColor = WMColor.light_blue
        buttonOk.layer.cornerRadius = 17
        buttonOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonOk.setTitle("Ok", for: UIControlState())
        buttonOk.addTarget(self, action: #selector(OrderConfirmDetailView.okAction), for: UIControlEvents.touchUpInside)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 24, width: viewContent.frame.width, height: 18))
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.text = NSLocalizedString("gr.confirma.generatingorden",comment: "")
        titleLabel.textAlignment = .center
        titleLabel.textColor = WMColor.light_blue
        
        imageBarCode = UIImageView(frame: CGRect(x: (self.viewContent.frame.width / 2) - 102, y: iconLoadingDone.frame.maxY + 16, width: 206, height: 56))
        
        
        lblTitleTrackingNumber = UILabel(frame: CGRect(x: 0, y: 244, width: viewContent.frame.width, height: 14))
        lblTitleTrackingNumber.font = WMFont.fontMyriadProRegularOfSize(14)
        lblTitleTrackingNumber.text = NSLocalizedString("gr.confirma.trakingnum",comment: "")
        lblTitleTrackingNumber.textAlignment = .center
        lblTitleTrackingNumber.textColor = WMColor.dark_gray
        lblTitleTrackingNumber.isHidden = true
        
        
        let lblTitleDeliveryDate = labelTitle(CGRect(x: 48, y: 274, width: 80, height: 12))
        lblTitleDeliveryDate.text = NSLocalizedString("gr.confirma.deliverydate", comment: "")
        
        let lblTitleDeliveryHour = labelTitle(CGRect(x: 160, y: lblTitleDeliveryDate.frame.minY, width: lblTitleDeliveryDate.frame.width, height: lblTitleDeliveryDate.frame.height))
        lblTitleDeliveryHour.text = NSLocalizedString("gr.confirma.deliveryhour", comment: "")
        
        let lblTitlePaymentType = labelTitle(CGRect(x: 48, y: 306, width: lblTitleDeliveryHour.frame.width, height: lblTitleDeliveryHour.frame.height))
        lblTitlePaymentType.text = NSLocalizedString("gr.confirma.paymenttype", comment: "")
        
        let lblTitleSubtotal = labelTitle(CGRect(x: 48, y: 370, width: lblTitleDeliveryHour.frame.width, height: lblTitleDeliveryHour.frame.height))
        lblTitleSubtotal.text = NSLocalizedString("gr.confirma.subtotal", comment: "")
        
        lbldiscountsAssociated = labelTitle(CGRect(x: 160, y: 338, width: lblTitleDeliveryHour.frame.maxX, height: lblTitleDeliveryHour.frame.height))
        lbldiscountsAssociated.text = NSLocalizedString("gr.confirma.descuentodeasociado", comment: "")

        
        let lblTitleTotal = labelTitle(CGRect(x: 160, y: 370, width: lblTitleDeliveryHour.frame.width, height: lblTitleDeliveryHour.frame.height))
        lblTitleTotal.text = NSLocalizedString("gr.confirma.total", comment: "")
        
        let lblTitledeliveryAmount = labelTitle(CGRect(x: 48, y: 338, width: lblTitleDeliveryHour.frame.width, height: lblTitleDeliveryHour.frame.height))
        lblTitledeliveryAmount.text = NSLocalizedString("gr.confirma.costodeenvio", comment: "")

        
        lblValueDeliveryDate = labelValue(CGRect(x: 48, y: lblTitleDeliveryDate.frame.maxY, width: 80, height: 14))
        lblValueDeliveryHour = labelValue(CGRect(x: 160, y: lblTitleDeliveryDate.frame.maxY, width: 80, height: lblValueDeliveryDate.frame.height))
        lblValuePaymentType = labelValue(CGRect(x: 48, y: lblTitlePaymentType.frame.maxY, width: self.viewContent.frame.width - 48, height: lblValueDeliveryDate.frame.height))
        lblValueDeliveryAmount = labelValue(CGRect(x: 48, y: lblTitledeliveryAmount.frame.maxY, width: 80, height: lblValueDeliveryDate.frame.height))
        lblValueSubtotal = labelValue(CGRect(x: 48, y: lblTitleSubtotal.frame.maxY, width: 80, height: lblValueDeliveryDate.frame.height))
        lblValueDiscountsAssociated = labelValue(CGRect(x: 160, y: lbldiscountsAssociated.frame.maxY, width: 80, height: lblValueDeliveryDate.frame.height))
        lblValueTotal = labelValue(CGRect(x: 160, y: lblTitleSubtotal.frame.maxY, width: 80, height: lblValueDeliveryDate.frame.height))
        
      
        
        viewLoadingDoneAnimate = UIView()
        viewLoadingDoneAnimate.backgroundColor = WMColor.light_blue.withAlphaComponent(0.5)
        viewLoadingDoneAnimate.frame = CGRect(x: 0, y: 0,  width: imgIcon!.size.width - 2, height: imgIcon!.size.height - 2)
        viewLoadingDoneAnimate.center = iconLoadingDone.center
        viewLoadingDoneAnimate.layer.cornerRadius = (imgIcon!.size.height - 2) / 2
        
        viewLoadingDoneAnimateAux = UIView()
        viewLoadingDoneAnimateAux.backgroundColor = WMColor.light_blue.withAlphaComponent(0.5)
        viewLoadingDoneAnimateAux.frame = CGRect(x: 0, y: 0,  width: imgIcon!.size.width - 2, height: imgIcon!.size.height - 2)
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
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            return initDetail(vc!)
        }
        return nil
    }
    
    class func initDetail(_ controller:UIViewController) -> OrderConfirmDetailView? {
        let newConfirm = OrderConfirmDetailView(frame:controller.view.bounds)
        return newConfirm
    }
    
    func showDetail() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        vc!.view.addSubview(self)
        let imgBack =  UIImage(from:vc!.view,size:self.bgView.bounds.size)
        let imgBackBlur = imgBack?.applyLightEffect()
        imgBgView.image = imgBackBlur
        
        self.startAnimating()
    }
    
    
    func startAnimating() {
        
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
        
        bgView.alpha = 0
        viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
        
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransform.identity
            })
      
            
            }) { (complete:Bool) -> Void in
                
        }
        
        self.animate()

        
    }
    
    func completeOrder(_ trakingNumber:String,deliveryDate:String,deliveryHour:String,paymentType:String,subtotal:String,total:String,deliveryAmount:String,discountsAssociated:String) {
        
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
        lblValueDiscountsAssociated.text = "$\(discountsAssociated)"
        lblTitleTrackingNumber.isHidden = false

            if discountsAssociated == "0.0"{
                lblValueDiscountsAssociated.isHidden = true
                lbldiscountsAssociated.isHidden = true
                
            }
            
            

        
        lblTitleTrackingNumber.text = endTracking
        
        viewLoadingDoneAnimate.layer.removeAllAnimations()
        viewLoadingDoneAnimateAux.layer.removeAllAnimations()

        viewLoadingDoneAnimateAux.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewContent.frame = CGRect(x: 0, y: 0, width: 288, height: 494)
            self.viewContent.center = self.center
        }, completion: { (complete) -> Void in
            
            self.viewLoadingDoneAnimate.transform = CGAffineTransform(scaleX: 1.2,y: 1.2)
            
            self.titleLabel.text = NSLocalizedString("gr.confirma.title",comment: "")
            
            self.viewLoadingDoneAnimate.backgroundColor = WMColor.green.withAlphaComponent(0.5)

            self.iconLoadingDone.image = UIImage(named:"done_order")
            let animation = CAKeyframeAnimation()
            animation.keyPath = "transform.scale"
            animation.duration = 0.6
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            animation.repeatCount = 1
            animation.values = [0, 1.3,1]
            self.iconLoadingDone.layer.add(animation, forKey: "grow")

            
        }) 
        
    }
    
    func errorOrder(_ descError:String) {
        
        viewLoadingDoneAnimate.layer.removeAllAnimations()
        viewLoadingDoneAnimateAux.layer.removeAllAnimations()
        
        self.titleLabel.text = descError
        
        let buttonNOk = UIButton(frame: CGRect(x: (self.viewContent.frame.width / 2) - 49, y: viewLoadingDoneAnimate.frame.maxY + 32, width: 98, height: 34))
        buttonNOk.backgroundColor = WMColor.light_blue
        buttonNOk.layer.cornerRadius = 17
        buttonNOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonNOk.setTitle("Ok", for: UIControlState())
        buttonNOk.addTarget(self, action: #selector(OrderConfirmDetailView.noOkAction), for: UIControlEvents.touchUpInside)
        
        self.viewContent.addSubview(buttonNOk)
        
        self.titleLabel.frame = CGRect(x: 0, y: 24, width: viewContent.frame.width, height: 36)
        self.titleLabel.numberOfLines = 2
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame =  self.bounds
        viewContent.center = self.center
        
    }
    
    func finishSopping(){
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_FINIHS_ORDER.rawValue , label: "ok order")
        self.delegate.didFinishConfirm()
        self.removeFromSuperview()
    }
    
    
    func okAction(){
        //Validar presentar mensaje
       let showRating = CustomBarViewController.retrieveRateParam(self.KEY_RATING)
        let velue = showRating == nil ? "" :showRating?.value
        
        if UserCurrentSession.sharedInstance.isReviewActive && (velue == "" ||  velue == "true") {
            let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
            alert!.isCustomAlert = true
            alert!.spinImage.isHidden =  true
            alert!.setMessage(NSLocalizedString("review.title.like.app", comment: ""))
            alert!.addActionButtonsWithCustomText("No", leftAction: {
                 CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                self.finishSopping()
                print("Save in data base")
               
                
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_DONT_LIKE_APP.rawValue , label: "No me gusta la app")
                }, rightText: "Sí", rightAction: {
                    alert?.close()
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_LIKE_APP.rawValue , label: "Me gusta la app")
                    self.rankingApp()
                }, isNewFrame: false)
            alert!.leftButton.layer.cornerRadius = 20
            alert!.rightButton.layer.cornerRadius = 20
        }else{
            self.finishSopping()
        }
        
    }
    
    func rankingApp(){
        
        let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
        alert!.spinImage.isHidden =  true
        alert!.setMessage(NSLocalizedString("review.description.ok.rate", comment: ""))
        alert!.addActionButtonsWithCustomTextRating(NSLocalizedString("review.no.thanks", comment: ""), leftAction: {
           
            //--
            CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
            alert?.close()
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_NO_THANKS.rawValue , label: "No gracias")
            self.finishSopping()
            
            }, rightText: NSLocalizedString("review.maybe.later", comment: ""), rightAction: {

                CustomBarViewController.addRateParam(self.KEY_RATING, value: "true")
                alert?.close()
                
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_MAYBE_LATER.rawValue , label: "Más tarde")
                self.finishSopping()
                
            }, centerText: NSLocalizedString("review.yes.rate", comment: ""),centerAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_OPEN_APP_STORE.rawValue , label: "Si Claro")
                self.finishSopping()
                let url  = URL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
                if UIApplication.shared.canOpenURL(url!) == true  {
                    UIApplication.shared.openURL(url!)
                }
                
            
        })
        alert!.leftButton.backgroundColor = WMColor.regular_blue
        alert!.leftButton.layer.cornerRadius = 20
        
        alert!.rightButton.backgroundColor = WMColor.dark_blue
        alert!.rightButton.layer.cornerRadius = 20

        
    }
    
    func noOkAction() {
        self.delegate.didErrorConfirm()
        self.removeFromSuperview()
    }
    
    func labelTitle(_ frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(12)
        labelTitleItem.textColor = WMColor.light_blue
        return labelTitleItem
    }
    
    func labelValue(_ frame:CGRect) -> UILabel {
        let labelTitleItem = UILabel(frame: frame)
        labelTitleItem.font = WMFont.fontMyriadProRegularOfSize(14)
        labelTitleItem.textColor = WMColor.light_blue
        return labelTitleItem
    }
    


    func animate() {
        
        var animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = Float.infinity
        animation.values = [1, 1.5]
        viewLoadingDoneAnimate.layer.add(animation, forKey: "grow")
        
        var animationOp = CAKeyframeAnimation()
        animationOp.keyPath = "opacity"
        animationOp.duration = 1
        animationOp.isRemovedOnCompletion = false
        animationOp.fillMode = kCAFillModeForwards
        animationOp.repeatCount = Float.infinity
        animationOp.values = [1, 0]
        viewLoadingDoneAnimate.layer.add(animationOp, forKey: "alpha0")
        
        animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.beginTime = CACurrentMediaTime() + 0.5
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = Float.infinity
        animation.values = [1, 1.5]
        viewLoadingDoneAnimateAux.layer.add(animation, forKey: "grow")
        
        animationOp = CAKeyframeAnimation()
        animationOp.keyPath = "opacity"
        animationOp.beginTime = CACurrentMediaTime() + 0.5
        animationOp.duration = 1
        animationOp.isRemovedOnCompletion = false
        animationOp.fillMode = kCAFillModeForwards
        animationOp.repeatCount = Float.infinity
        animationOp.values = [1, 0]
        viewLoadingDoneAnimateAux.layer.add(animationOp, forKey: "alpha0")
        
        
    }
    
}
