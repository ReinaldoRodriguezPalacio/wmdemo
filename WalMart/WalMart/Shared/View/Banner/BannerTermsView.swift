//
//  BannerTermsView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 04/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class BannerTermsView : UIView {
    
    var imageBlurView : UIImageView!
    var viewBg : UIView!
    var viewBlurContainer : UIView!
    var viewText : UITextView!
    var onClose : (() -> Void)!
    
    func setup(text:String) {
        
        self.clipsToBounds = true
        
        
        viewBlurContainer = UIView()
        viewBlurContainer.backgroundColor = UIColor.clearColor()
        viewBlurContainer.clipsToBounds = true
        self.addSubview(viewBlurContainer)
        
        viewBg = UIView()
        viewBg.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.7)
        viewBg.frame = self.bounds
        self.addSubview(viewBg)
        
        
        viewText = UITextView()
        viewText.text = text
        viewText.frame = CGRectMake( 16, 40, self.bounds.width - 32,  self.bounds.height - 50)
        viewText.font = WMFont.fontMyriadProRegularOfSize(14)
        viewText.textColor = UIColor.whiteColor()
        viewText.backgroundColor = UIColor.clearColor()
        viewText.editable = false
        viewText.selectable = false
        viewBg.addSubview(viewText)
        
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "removeFromSuperview", forControlEvents: UIControlEvents.TouchUpInside)
        viewBg.addSubview(closeButton)

        
        
    }
    
    
    func startAnimating() {
        viewBg.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
        if imageBlurView != nil {
            viewBlurContainer.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
            imageBlurView.frame = CGRectMake(self.bounds.minX, -self.bounds.height, self.bounds.width, self.bounds.height)
        }
        //viewText.frame = CGRectMake(self.bounds.minX + 16, self.bounds.height + 16 , self.bounds.width - 32, 0)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewBg.frame = self.bounds
            if self.imageBlurView != nil {
                self.viewBlurContainer.frame = self.bounds
                self.imageBlurView.frame = self.bounds
            }
            //self.viewText.frame = CGRectMake(self.bounds.minX + 16, self.bounds.minY + 16, self.bounds.width - 32,  self.bounds.minY - 32)
            }) { (ends:Bool) -> Void in
            
        }
    }
    
    func generateBlurImage(viewBg:UIView,frame:CGRect) {
        var cloneImage : UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        cloneImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        viewBg.layer.contents = nil
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = cloneImage!.applyLightEffect()
        cloneImage = nil
        
        viewBlurContainer.addSubview(imageBlurView)
        viewBlurContainer.sendSubviewToBack(imageBlurView)
    }
    
    override func removeFromSuperview() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewBg.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
            if self.imageBlurView != nil {
                self.viewBlurContainer.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
                self.imageBlurView.frame = CGRectMake(self.bounds.minX, -self.bounds.height, self.bounds.width, self.bounds.height)
            }
            }) { (ends:Bool) -> Void in
                self.endRemovView()
        }
    }
    
    func endRemovView() {
        if onClose != nil {
            onClose()
        }
        super.removeFromSuperview()
    }
    
}