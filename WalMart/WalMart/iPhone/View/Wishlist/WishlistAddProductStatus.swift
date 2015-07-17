//
//  WishlistAddProductStatus.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/6/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class WishlistAddProductStatus : UIView {
    
    var imageBlurView : UIImageView!
    var textView : UILabel!
    var closeDetail : (() -> Void)? = nil
    var viewBg : UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        viewBg = UIView(frame:CGRectMake(0, 0,320,48))
        viewBg.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        self.addSubview(viewBg)
        
        textView = UILabel(frame:CGRectMake(0, 0, 320, 48))
        textView.font = WMFont.fontMyriadProLightOfSize(18)
        textView.textColor = UIColor.whiteColor()
        textView.numberOfLines = 0
        textView.textAlignment = NSTextAlignment.Center
        self.addSubview(textView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBg.frame = CGRectMake(0, 0,self.bounds.width,48)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeStatus() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.frame = CGRectMake(self.frame.minX, 360, self.frame.width, 0)
            }) { (complete:Bool) -> Void in
            self.removeFromSuperview()
        }
    }
    
    func generateBlurImage(viewBg:UIView,frame:CGRect) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = blurredImage
        
        self.addSubview(imageBlurView)
        self.sendSubviewToBack(imageBlurView)
    }

    func prepareToClose() {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "closeStatus", userInfo: nil, repeats: false)
    }
    
}