//
//  AlertPickerView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class AlertModalView : UIView, UITextFieldDelegate {
    
    var viewContent : UIView!
    var bgView : UIView!
    var onClosePicker : (() -> Void)?
    var viewButtonClose : UIButton!
    var stopRemoveView: Bool? = false
    
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
        
        viewContent = UIView(frame: CGRectMake(0, 0, 200, 200))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.whiteColor()
        self.stopRemoveView! = false
        self.addSubview(viewContent)
    }
    
    func addCloseButton() {
        let margin : CGFloat = 8
        let viewButton = UIButton(frame: CGRectMake(margin, margin, 40, 40))
        viewButton.addTarget(self, action: "closePicker", forControlEvents: UIControlEvents.TouchUpInside)
        viewButton.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        self.addSubview(viewButton)
    }
    
    override func layoutSubviews() {
        viewContent.center = self.center
    }
    
    func closePicker() {
        onClosePicker?()
        self.removeFromSuperview()
    }
    
    //MARK TextField delegate
    
    class func initModal()  -> AlertModalView? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            return initModal(vc!)
        }
        return nil
    }
    
    class func initModal(controller:UIViewController) -> AlertModalView? {
        let newAlert = AlertModalView(frame:controller.view.bounds)
        //newAlert.viewContent =
        controller.view.addSubview(newAlert)
        newAlert.startAnimating()
        return newAlert
    }
    
    class func initModalWithDefault() -> AlertModalView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertModalView(frame:vc!.view.bounds)
        return newAlert
    }
    
    class func initModalWithNavController(controllerShow:UINavigationController) -> AlertModalView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertModalView(frame:vc!.view.bounds)
        vc?.addChildViewController(controllerShow)
        newAlert.viewContent.frame.size = CGSize(width: controllerShow.view.frame.size.width + 4, height: controllerShow.view.frame.size.height + 4)  //controllerShow.view.frame.size
        newAlert.viewContent.addSubview(controllerShow.view)
        controllerShow.view.center = newAlert.viewContent.center
        return newAlert
    }
    
    func showPicker() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        vc!.view.addSubview(self)
        //vc!.view.bringSubviewToFront(self)
        self.startAnimating()
        
    }
    
    
    //MARK: Animated
    
    func startAnimating() {
        
        
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(fromView: self.superview!)
        let imgBackBlur = imgBack.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
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
            
            //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
            //                 self.viewContent.transform = CGAffineTransformMakeScale(1,0.01)
            //            })
            //
            //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
            //                self.viewContent.transform = CGAffineTransformMakeScale(1,1)
            //            })
            
            }) { (complete:Bool) -> Void in
                
        }
        
    }
    
    override func removeFromSuperview() {
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 0.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransformMakeTranslation(0,500)
            })
            
            //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
            //                 self.viewContent.transform = CGAffineTransformMakeScale(1,0.01)
            //            })
            //
            //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
            //                self.viewContent.transform = CGAffineTransformMakeScale(1,1)
            //            })
            
            }) { (complete:Bool) -> Void in
                self.removeComplete()
        }
        
    }
    
    func removeComplete(){
        super.removeFromSuperview()
    }
}