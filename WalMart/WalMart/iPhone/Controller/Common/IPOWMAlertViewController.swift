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
    var imageblur : UIVisualEffectView? = nil
    var doneButton : UIButton! = nil
    
    var leftButton :UIButton!
    var rightButton :UIButton!
    
    var successCallBack : (() -> Void)? = nil
    var okCancelCallBack : (() -> Void)? = nil
    var afterRemove : (() -> Void)? = nil
    
    var leftAction : (() -> Void)? = nil
    var rightAction : (() -> Void)? = nil
    var isOtherFame : Bool = false
    var btnFrame : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        self.bgView = UIView()
        self.bgView.backgroundColor = WMColor.light_blue.withAlphaComponent(0.93)
        
        viewBgImage = UIView()
        viewBgImage.layer.cornerRadius = 80 / 2
        viewBgImage.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        if imageWaiting != nil {
            imageIcon = UIImageView()
            imageIcon.image = imageWaiting
            imageIcon.contentMode = .scaleAspectFit
            imageIcon.layer.cornerRadius = 40
            imageIcon.layer.masksToBounds = true
            imageIcon.clipsToBounds = true
            //imageIcon.frame = CGRectMake(0,0,imageIcon.image!.size.width,imageIcon.image!.size.height)
            //imageIcon.center = CGPointMake(viewBgImage.frame.width / 2, viewBgImage.frame.width / 2)
            viewBgImage.addSubview(imageIcon)
        }
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.textColor = WMColor.light_gray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        spinImage = UIImageView()
        spinImage.image = UIImage(named:"waiting")
        runSpinAnimationOnView(spinImage, duration: 100, rotations: 1, repeats: 100)
        
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
        
        viewBgImage.frame = CGRect(x: (bounds.width - 80)  / 2 , y: (bounds.height - 80 - 200) / 2, width: 80, height: 80)
         //titleLabel.frame = CGRectMake((bounds.width - 232) / 2,  viewBgImage.frame.maxY + 16, 232, titleLabel!.frame.height)

        titleLabel!.sizeToFit()
        if  self.btnFrame {
             titleLabel.frame =  CGRect(x: 16,  y: viewBgImage.frame.maxY + 24, width: self.view.frame.width - 32, height: titleLabel!.frame.height)
        }else{
            titleLabel.frame = self.isOtherFame ? CGRect(x: (bounds.width - 321),  y: viewBgImage.frame.maxY + 24, width: 321, height: titleLabel!.frame.height) : CGRect(x: (bounds.width - 232) / 2,  y: viewBgImage.frame.maxY + 16, width: 232, height: titleLabel!.frame.height)
        }
      
        
        //titleLabel.backgroundColor = UIColor.redColor()
       //232
        spinImage.frame = CGRect(x: (bounds.width - 84)  / 2, y: (bounds.height - 84 - 200)  / 2, width: 84, height: 84)
       
        if imageIcon != nil && imageIcon.image != nil {
            imageIcon.frame = CGRect(x: 0,y: 0,width: 80,height: 80)
            imageIcon.center = CGPoint(x: viewBgImage.frame.width / 2, y: viewBgImage.frame.width / 2)
        }
        
        if self.doneButton != nil {
            doneButton.frame = CGRect(x: (bounds.width - 160 ) / 2, y: titleLabel.frame.maxY + 16, width: 160 , height: 40)
        }
        if leftButton != nil {
            leftButton.frame =  self.isOtherFame  ? CGRect(x: 16, y: self.titleLabel.frame.maxY + 60 + 24, width: self.view.frame.width - 32, height: 32) :
                CGRect(x: (self.view.bounds.width / 2) - 134, y: self.titleLabel.frame.maxY + 16, width: 128, height: 32)
            
        }
        //es 370 lo cambie a 350 pero no es ese checar despues de comer y 330 iphone 4s
        if rightButton != nil {
            rightButton.frame =  self.isOtherFame  ? CGRect(x: 16, y: self.titleLabel.frame.maxY + 24, width: self.view.frame.width - 32, height: 32) :
                CGRect(x: leftButton.frame.maxX + 11, y: self.titleLabel.frame.maxY + 16, width: leftButton.frame.width, height: leftButton.frame.height)
            
        }
        

        
    }
    
    /**
     Set message to alert view
     
     - parameter message: message to present
     */
    func setMessage(_ message:String){
        let size =  message.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
        titleLabel.frame = CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.minY, width: 232, height: size.height)
        titleLabel.text = message 
    }
    
    class func showAlert(_ imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPOWMAlertViewController? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        if vc != nil {
            vc?.view.endEditing(true)
            return showAlert(vc!,imageWaiting:imageWaiting,imageDone:imageDone,imageError:imageError)
        }
        return nil
    }
    
    class func showAlert(_ controller:UIViewController,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPOWMAlertViewController? {
        let newAlert = IPOWMAlertViewController()
        newAlert.imageWaiting = imageWaiting
        newAlert.imageDone = imageDone
        newAlert.imageError = imageError
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        return newAlert
    }
    
    /**
     Prsent icon in alertview and close the alert after time.
     */
    func showDoneIcon() {
        showicon(self.imageDone)
        Timer.scheduledTimer(timeInterval: 1.4, target: self, selector: #selector(IPOWMAlertViewController.close), userInfo: nil, repeats: false)
    }
    
    /**
     Present done icon
     */
    func showDoneIconWithoutClose() {
        showicon(self.imageDone)
    }
    
    /**
     Present error icon
     
     - parameter titleDone: title error
     */
    func showErrorIcon(_ titleDone:String) {
       showicon(self.imageError)
        showOkButton(titleDone, colorButton:WMColor.green)
    }
    
    /**
     Crete animation icon image
     
     - parameter image: image icon
     */
    func showicon(_ image:UIImage?) {
        self.spinImage.layer.removeAllAnimations()
        self.spinImage.isHidden = true
        imageIcon.image = image
        UIView.animateKeyframes(withDuration: 0.9, delay:  0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) { () -> Void in
                self.viewBgImage.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) { () -> Void in
                self.viewBgImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3) { () -> Void in
                self.viewBgImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            }, completion: { (complete:Bool) -> Void in
                print("cerrar dialogo Guardando...")
                
        })
    }
    
    /**
     Create button done if requiered
     
     - parameter titleDone:   title button
     - parameter colorButton: color button
     */
    func showOkButton(_ titleDone:String, colorButton: UIColor) {
        if  self.doneButton != nil{
            self.doneButton.removeFromSuperview()
        }
        
        self.doneButton = UIButton()
        self.doneButton.setTitle(titleDone, for: UIControlState())
        self.doneButton.setTitleColor(UIColor.white, for: UIControlState())
        self.doneButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.doneButton.backgroundColor = colorButton
       
        self.doneButton.addTarget(self, action: #selector(IPOWMAlertViewController.closebtn), for: .touchUpInside)
        self.doneButton.layer.cornerRadius = 20
        
        var bounds = self.view.bounds
        if self.view.superview != nil {
            bounds = self.view.superview!.bounds
        }
        
        doneButton.frame = CGRect(x: (bounds.width - 160 ) / 2, y: titleLabel.frame.maxY + 16, width: 160 , height: 32)
        
        self.view.addSubview(doneButton)
    }
    
    /**
     Create button default, create tagets actions and adds to view alert.
     */
    func addActionButtons() {
        let leftButton = UIButton(frame:CGRect(x: 26, y: 288, width: 128, height: 32))
        leftButton.layer.cornerRadius =  16
        leftButton.setTitle(NSLocalizedString("shoppingcart.keepshopping",comment:""), for: UIControlState())
        leftButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        leftButton.backgroundColor = UIColor.white
        leftButton.setTitleColor(WMColor.light_blue, for: UIControlState())
        leftButton.addTarget(self, action: #selector(IPOWMAlertViewController.close), for: UIControlEvents.touchUpInside)

        let rightButton = UIButton(frame:CGRect(x: leftButton.frame.maxX + 11, y: leftButton.frame.minY, width: leftButton.frame.width, height: leftButton.frame.height))
        rightButton.layer.cornerRadius = 16
        rightButton.setTitle(NSLocalizedString("shoppingcart.goshoppingcart",comment:""), for: UIControlState())
        rightButton.backgroundColor = WMColor.green
        rightButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        rightButton.addTarget(self, action: Selector("goShoppingCart"), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(leftButton)
        self.view.addSubview(rightButton)
    }
    
    /**
     Create butoms custom , change frame, titles and actions.
     
     - parameter leftText:    title left button.
     - parameter leftAction:  acction left button.
     - parameter rightText:   title right button
     - parameter rightAction: acction right button
     - parameter isNewFrame:  if change frames buttons is true
     */
    func addActionButtonsWithCustomText(_ leftText:String,leftAction:@escaping (() -> Void),rightText:String,rightAction:@escaping (() -> Void),isNewFrame:Bool) {
        self.isOtherFame = isNewFrame
        
        leftButton = UIButton(frame:CGRect(x: (self.view.bounds.width / 2) - 134, y: self.titleLabel.frame.maxY + 16, width: 128, height: 32))
        if isNewFrame {
            leftButton = UIButton(frame:CGRect(x: 11, y: self.titleLabel.frame.maxY + 100, width: self.view.frame.width - 22, height: 32))
        }
        leftButton.layer.cornerRadius = 16
        leftButton.setTitle(leftText, for: UIControlState())
        leftButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        leftButton.backgroundColor = WMColor.dark_blue
        leftButton.setTitleColor(UIColor.white, for: UIControlState())
        leftButton.addTarget(self, action: #selector(IPOWMAlertViewController.leftTapInside), for: UIControlEvents.touchUpInside)
        

        rightButton = UIButton(frame:CGRect(x: leftButton.frame.maxX + 11, y: leftButton.frame.minY, width: leftButton.frame.width, height: leftButton.frame.height))
        if isNewFrame {
             rightButton = UIButton(frame:CGRect(x: 16, y: 375, width: self.view.frame.width - 32, height: 32))
        }
        
        rightButton.layer.cornerRadius = 16
        rightButton.setTitle(rightText, for: UIControlState())
        rightButton.backgroundColor = WMColor.green
        rightButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        rightButton.addTarget(self, action: #selector(IPOWMAlertViewController.righTapInside), for: UIControlEvents.touchUpInside)
        
        self.leftAction = leftAction
        self.rightAction = rightAction
        
        self.view.addSubview(leftButton)
        self.view.addSubview(rightButton)
    }
    
    /**
     Action if tap left button.
     */
    func leftTapInside() {
        if self.leftAction != nil {
            self.leftAction!()
        }
    }
    
    /**
     Actionn if tap rigth button.
     */
    func righTapInside() {
        if self.rightAction != nil {
            self.rightAction!()
        }
    }

    /**
     Create image blur it presented width alert view
     */
    func generateBlurImage() {
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.3
        self.imageblur = blurEffectView
        self.view.addSubview(imageblur!)
        self.view.sendSubview(toBack: self.imageblur!)

    }
    
    func runSpinAnimationOnView(_ view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    /**
     Action close button, close alert.
     */
    func closebtn(){
        if okCancelCallBack != nil {
            self.okCancelCallBack!()
        }
        self.close()
    }
    
    /**
     Close alert view
     */
    func close() {
        if successCallBack != nil {
            self.successCallBack!()
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.alpha = 0.0
            }, completion: { (complete:Bool) -> Void in
                self.removeFromParentViewController()
                self.successCallBack = nil
                self.okCancelCallBack  = nil
                self.view.removeFromSuperview()
                if self.afterRemove != nil {
                    self.afterRemove!()
                }
                
        }) 
       
    }

}
