//
//  PreviewModalView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 20/02/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class PreviewModalView : AlertModalView {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override func setup() {
        
        self.backgroundColor = UIColor.clear
        
        self.tag = 5000
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRect(x: 0, y: 0, width:300,height: 420))
        viewContent.layer.cornerRadius = 8.0
        viewContent.backgroundColor = UIColor.white
        initView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 420))
        initView!.layer.cornerRadius = 8.0
        initView!.backgroundColor = UIColor.white
        self.stopRemoveView! = false
        self.addSubview(viewContent)
    }
    
    
    class func initPreviewModal(_ controllerShow:UIViewController) -> PreviewModalView? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = PreviewModalView(frame:vc!.view.bounds)
        newAlert.paddingTop = 0.0
        //vc?.addChildViewController(controllerShow)
        newAlert.viewContent.frame.size = CGSize(width: controllerShow.view.frame.size.width + 4, height: controllerShow.view.frame.size.height + 4)  //controllerShow.view.frame.size
        newAlert.viewContent.addSubview(controllerShow.view)
        controllerShow.view.center = newAlert.viewContent.center
            
        return newAlert
    }
    
    func showPreview() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        vc!.view.addSubview(self)
        //vc!.view.bringSubviewToFront(self)
        self.startAnimating()
        
    }
    
    
    //MARK: Animated
    
    override func startAnimating() {
        
        
        //        let imgBgView = UIImageView(frame: self.bgView.bounds)
        //        let imgBack = UIImage(fromView: self.superview!)
        //        let imgBackBlur = imgBack.applyLightEffect()
        //        imgBgView.image = imgBackBlur
        //        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.7)
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
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModePaced, animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 0.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
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
}
