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
    var headerView: UIView!
    var bgView : UIView!
    var initView: UIView?
    var onClosePicker : (() -> Void)?
    var onReturnPicker : (() -> Void)?
    var viewButtonClose : UIButton!
    var closeButton : UIButton!
    var stopRemoveView: Bool? = false
    var viewReplace : UIView!
    var titleLabel: UILabel!
    var lastTitle: String! = ""
    var lastFrame: CGRect?
    
    
    var paddingTop: CGFloat = 30
    
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
        
        self.tag = 5000
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRectMake(0, 0, 200, 200))
        viewContent.layer.cornerRadius = 8.0
        viewContent.backgroundColor = UIColor.whiteColor()
        initView = UIView(frame: CGRectMake(0, 0, 200, 200))
        initView!.layer.cornerRadius = 8.0
        initView!.backgroundColor = UIColor.whiteColor()
        self.stopRemoveView! = false
        self.addSubview(viewContent)
    }
    
    func addCloseButton() {
        let margin : CGFloat = 8
        let viewButton = UIButton(frame: CGRectMake(margin, margin, 40, 40))
        viewButton.addTarget(self, action: #selector(AlertModalView.closePicker), forControlEvents: UIControlEvents.TouchUpInside)
        viewButton.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        self.addSubview(viewButton)
    }
    
    func addHeaderAndTitle(title:String){
        headerView = UIView(frame: CGRectMake(3, 3, viewContent.frame.width - 6, 46))
        headerView.backgroundColor = WMColor.light_light_gray
        viewContent.addSubview(headerView)
        
        self.titleLabel = UILabel(frame: headerView.bounds)
        self.titleLabel.textColor =  WMColor.light_blue
        self.titleLabel.textAlignment = .Center
        self.titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel.numberOfLines = 2
        self.titleLabel.text = title
        self.titleLabel.textAlignment = .Center
        
        self.viewButtonClose = UIButton(frame: CGRectMake(6, 3, 40, 40))
        self.viewButtonClose.addTarget(self, action: #selector(AlertModalView.closePicker), forControlEvents: UIControlEvents.TouchUpInside)
        self.viewButtonClose.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
        headerView.addSubview(viewButtonClose)
        headerView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        viewContent.center = CGPoint(x: self.center.x, y: self.center.y)
    }
    
    func closePicker() {
        onClosePicker?()
        self.removeFromSuperview()
    }
    
    func setContentView(view:UIView){
        let width = view.frame.size.width + 6
        let height = view.frame.size.height + 6
        self.initView = view
        self.viewContent.frame.size = CGSize(width: width, height: height)  //controllerShow.view.frame.size
        self.viewContent.addSubview(self.initView!)
        view.center =  self.viewContent.center
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
    
    class func showAlertWithImage(alertTitle: String,contentViewSize: CGSize, image:UIImage) -> AlertModalView {
        let modalView = AlertModalView.initModalWithDefault()
        let innerView = UIView(frame: CGRectMake(0,0,contentViewSize.width,contentViewSize.height))
        let imageView = UIImageView(image: image)
        modalView.setContentView(innerView)
        modalView.addHeaderAndTitle(alertTitle)
        modalView.viewContent!.addSubview(imageView)
        imageView.frame.origin = CGPoint(x: 35, y: 58)
        modalView.showPicker()
        return modalView
    }

    
    class func initModalWithDefault() -> AlertModalView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertModalView(frame:vc!.view.bounds)
        return newAlert
    }
    
    class func initModalWithView(alertTitle: String, innerView:UIView) -> AlertModalView {
        let modalView = AlertModalView.initModalWithDefault()
        modalView.setContentView(innerView)
        modalView.addHeaderAndTitle(alertTitle)
        return modalView
    }
    
    class func initModalWithView(innerView:UIView) -> AlertModalView {
        let modalView = AlertModalView.initModalWithDefault()
        modalView.setContentView(innerView)
        return modalView
    }
    
    
    class func initModalWithNavController(controllerShow:UINavigationController) -> AlertModalView {
        return initModalWithNavController(controllerShow,paddingTop:30.0)
    }
    
    class func initModalWithNavController(controllerShow:UINavigationController, paddingTop:CGFloat) -> AlertModalView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertModalView(frame:vc!.view.bounds)
        newAlert.paddingTop = paddingTop
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
        
        
//        let imgBgView = UIImageView(frame: self.bgView.bounds)
//        let imgBack = UIImage(fromView: self.superview!)
//        let imgBackBlur = imgBack.applyLightEffect()
//        imgBgView.image = imgBackBlur
//        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
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
    
    
    func resizeViewContent(title:String, view:UIView) {
        self.lastTitle = self.titleLabel!.text!
        self.lastFrame = self.viewContent.frame
        self.titleLabel!.text = title
        closeButton = UIButton(frame: CGRectMake(0, 0, self.headerView.frame.height,  self.headerView.frame.height))
        closeButton!.addTarget(self, action: #selector(AlertModalView.closeNew), forControlEvents: UIControlEvents.TouchUpInside)
        closeButton!.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
        closeButton!.alpha = 0
        self.headerView.addSubview(closeButton!)
        self.viewButtonClose?.hidden = true
        let finalContentFrame = CGRectMake(self.viewContent.frame.minX, self.viewContent.frame.minY, self.viewContent.frame.width, view.frame.height + 49)
        self.viewReplace = view
        self.viewReplace?.alpha = 0
        self.viewContent.addSubview(viewReplace!)
        self.initView?.alpha = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.viewContent.frame = finalContentFrame
                self.viewContent.center = self.center
                self.viewButtonClose?.alpha = 1
                self.closeButton!.alpha = 1
                }) { (completed:Bool) -> Void in
                    self.viewReplace?.alpha = 1
        }
    }
    
    func closeNew() {
        self.onReturnPicker?()
        self.viewReplace?.alpha = 0
        self.titleLabel!.text = self.lastTitle
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewContent.frame = self.lastFrame!
            self.viewContent.center = self.center
            self.viewButtonClose.hidden = false
            self.closeButton.hidden = true
            }) { (complete:Bool) -> Void in
                self.initView?.alpha = 1
                self.viewReplace?.removeFromSuperview()
                self.closeButton?.removeFromSuperview()
        }
    }
}