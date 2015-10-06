//
//  IPOWMAlertViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOWMAlertViewController : UIViewController {
    
    var titleLabel : UILabel!
    var viewBgImage : UIView!
    var spinImageView : UIImageView!
    var imageWaiting : UIImage? = nil
    var imageDone : UIImage? = nil
    var imageError : UIImage? = nil
    var spinImage : UIImageView!
    var imageIcon : UIImageView!
    var bgView : UIView!
    var imageblur : UIImageView? = nil
    var doneButton : UIButton! = nil
    
    var leftButton :UIButton!
    var rightButton :UIButton!
    
    var successCallBack : (() -> Void)? = nil
    var okCancelCallBack : (() -> Void)? = nil
    var afterRemove : (() -> Void)? = nil
    
    var leftAction : (() -> Void)? = nil
    var rightAction : (() -> Void)? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bgView = UIView()
        self.bgView.backgroundColor = WMColor.productAddToCartBg
        
        viewBgImage = UIView()
        viewBgImage.layer.cornerRadius = 80 / 2
        viewBgImage.backgroundColor = WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.5)
        
        if imageWaiting != nil {
            imageIcon = UIImageView()
            imageIcon.image = imageWaiting
            //imageIcon.frame = CGRectMake(0,0,imageIcon.image!.size.width,imageIcon.image!.size.height)
            //imageIcon.center = CGPointMake(viewBgImage.frame.width / 2, viewBgImage.frame.width / 2)
            viewBgImage.addSubview(imageIcon)
        }
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.textColor = WMColor.productAddToCartTitle
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        
        spinImage = UIImageView()
        spinImage.image = UIImage(named:"waiting")
        runSpinAnimationOnView(spinImage, duration: 100, rotations: 1, `repeat`: 100)
        
        self.view.addSubview(bgView)
        self.view.addSubview(viewBgImage)
        self.view.addSubview(titleLabel)
        self.view.addSubview(spinImage)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        
        if self.imageblur == nil {
            self.generateBlurImage()
        }
        
        self.bgView.frame = bounds
        
        viewBgImage.frame = CGRectMake((bounds.width - 80)  / 2 , (bounds.height - 80 - 200) / 2, 80, 80)
        
        titleLabel!.sizeToFit()
        titleLabel.frame = CGRectMake((bounds.width - 232) / 2,  viewBgImage.frame.maxY + 16, 232, titleLabel!.frame.height)
       
        spinImage.frame = CGRectMake((bounds.width - 84)  / 2, (bounds.height - 84 - 200)  / 2, 84, 84)
       
        if imageIcon != nil && imageIcon.image != nil {
            imageIcon.frame = CGRectMake(0,0,imageIcon.image!.size.width,imageIcon.image!.size.height)
            imageIcon.center = CGPointMake(viewBgImage.frame.width / 2, viewBgImage.frame.width / 2)
        }
        
        if self.doneButton != nil {
            doneButton.frame = CGRectMake((bounds.width - 160 ) / 2, titleLabel.frame.maxY + 16, 160 , 40)
        }
        
        if leftButton != nil {
            leftButton.frame = CGRectMake((self.view.bounds.width / 2) - 134, self.titleLabel.frame.maxY + 16, 128, 32)
        }
       
        if rightButton != nil {
            rightButton.frame =  CGRectMake(leftButton.frame.maxX + 11, leftButton.frame.minY, leftButton.frame.width, leftButton.frame.height)
        }
        
    }
    
    func setMessage(message:NSString){
        let size =  message.boundingRectWithSize(CGSizeMake(titleLabel.frame.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
        titleLabel.frame = CGRectMake(titleLabel.frame.minX, titleLabel.frame.minY, 232, size.height)
        titleLabel.text = message as String
    }
    
    class func showAlert(imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPOWMAlertViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            return showAlert(vc!,imageWaiting:imageWaiting,imageDone:imageDone,imageError:imageError)
        }
        return nil
    }
    
    class func showAlert(controller:UIViewController,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPOWMAlertViewController? {
        let newAlert = IPOWMAlertViewController()
        newAlert.imageWaiting = imageWaiting
        newAlert.imageDone = imageDone
        newAlert.imageError = imageError
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        return newAlert
    }
    
    func showDoneIcon() {
        showicon(self.imageDone)
        NSTimer.scheduledTimerWithTimeInterval(1.4, target: self, selector: "close", userInfo: nil, repeats: false)
    }
    
    func showDoneIconWithoutClose() {
        showicon(self.imageDone)
    }
    
    func showErrorIcon(titleDone:String) {
       showicon(self.imageError)
        showOkButton(titleDone, colorButton:WMColor.emptyBgRetunGreenColor)
    }
    
    func showicon(image:UIImage?) {
        self.spinImage.layer.removeAllAnimations()
        self.spinImage.hidden = true
        imageIcon.image = image
        UIView.animateKeyframesWithDuration(0.9, delay:  0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.3) { () -> Void in
                self.viewBgImage.transform = CGAffineTransformMakeScale(1.4, 1.4)
            }
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.3) { () -> Void in
                self.viewBgImage.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }
            UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.3) { () -> Void in
                self.viewBgImage.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
            }, completion: { (complete:Bool) -> Void in
                print("cerrar dialogo Guardando...")
                
        })
    }
    
    
    func showOkButton(titleDone:String, colorButton: UIColor) {
        if  self.doneButton != nil{
            self.doneButton.removeFromSuperview()
        }
        
        self.doneButton = UIButton()
        self.doneButton.setTitle(titleDone, forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.doneButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.doneButton.backgroundColor = colorButton
       
        self.doneButton.addTarget(self, action: "closebtn", forControlEvents: .TouchUpInside)
        self.doneButton.layer.cornerRadius = 20
        
        var bounds = self.view.bounds
        if self.view.superview != nil {
            bounds = self.view.superview!.bounds
        }
        
        doneButton.frame = CGRectMake((bounds.width - 160 ) / 2, titleLabel.frame.maxY + 16, 160 , 32)
        
        self.view.addSubview(doneButton)
    }
    
    func addActionButtons() {
        let leftButton = UIButton(frame:CGRectMake(26, 288, 128, 32))
        leftButton.layer.cornerRadius =  16
        leftButton.setTitle(NSLocalizedString("shoppingcart.keepshopping",comment:""), forState: UIControlState.Normal)
        leftButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        leftButton.backgroundColor = UIColor.whiteColor()
        leftButton.setTitleColor(WMColor.productAddToCartKeepShoppingText, forState: UIControlState.Normal)
        leftButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)

        let rightButton = UIButton(frame:CGRectMake(leftButton.frame.maxX + 11, leftButton.frame.minY, leftButton.frame.width, leftButton.frame.height))
        rightButton.layer.cornerRadius = 16
        rightButton.setTitle(NSLocalizedString("shoppingcart.goshoppingcart",comment:""), forState: UIControlState.Normal)
        rightButton.backgroundColor = WMColor.productAddToCartGoToShoppingBg
        rightButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        rightButton.addTarget(self, action: "goShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(leftButton)
        self.view.addSubview(rightButton)
    }
    
    func addActionButtonsWithCustomText(leftText:String,leftAction:(() -> Void),rightText:String,rightAction:(() -> Void)) {
        leftButton = UIButton(frame:CGRectMake((self.view.bounds.width / 2) - 134, self.titleLabel.frame.maxY + 16, 128, 32))
        leftButton.layer.cornerRadius = 16
        leftButton.setTitle(leftText, forState: UIControlState.Normal)
        leftButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        leftButton.backgroundColor = WMColor.productAddToCartKeepShoppingBg
        leftButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        leftButton.addTarget(self, action: "leftTapInside", forControlEvents: UIControlEvents.TouchUpInside)
        
        rightButton = UIButton(frame:CGRectMake(leftButton.frame.maxX + 11, leftButton.frame.minY, leftButton.frame.width, leftButton.frame.height))
        rightButton.layer.cornerRadius = 16
        rightButton.setTitle(rightText, forState: UIControlState.Normal)
        rightButton.backgroundColor = WMColor.productAddToCartGoToShoppingBg
        rightButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        rightButton.addTarget(self, action: "righTapInside", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.leftAction = leftAction
        self.rightAction = rightAction
        
        self.view.addSubview(leftButton)
        self.view.addSubview(rightButton)
    }
    
    func leftTapInside() {
        if self.leftAction != nil {
            self.leftAction!()
        }
    }
    
    func righTapInside() {
        if self.rightAction != nil {
            self.rightAction!()
        }
    }

    
    func generateBlurImage() {
        var cloneImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size,false,1.0);
            //let context = UIGraphicsGetCurrentContext()!
            self.parentViewController?.view.drawViewHierarchyInRect(view.bounds,afterScreenUpdates:true)
            //self.parentViewController?.view.layer.renderInContext(context)
            cloneImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.parentViewController!.view.layer.contents = nil
        }

        let blurredImage = cloneImage!.applyLightEffect()
        self.imageblur = UIImageView()
        self.imageblur!.frame = self.view.bounds
        self.imageblur!.clipsToBounds = true
        self.imageblur!.image = blurredImage
        self.view.addSubview(self.imageblur!)
        self.view.sendSubviewToBack(self.imageblur!)
    }
    
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,`repeat`:CGFloat) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(`repeat`)
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func closebtn(){
        if okCancelCallBack != nil {
            self.okCancelCallBack!()
        }
        self.close()
    }
    
    func close() {
        if successCallBack != nil {
            self.successCallBack!()
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.alpha = 0.0
            }) { (complete:Bool) -> Void in
                self.imageblur?.image = nil
                self.removeFromParentViewController()
                self.successCallBack = nil
                self.okCancelCallBack  = nil
                self.view.removeFromSuperview()
                if self.afterRemove != nil {
                    self.afterRemove!()
                }
                
        }
       
    }

}