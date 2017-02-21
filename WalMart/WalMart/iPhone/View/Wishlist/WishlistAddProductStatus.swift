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
        
        viewBg = UIView(frame:CGRect(x: 0, y: 0,width: self.frame.width,height: 48))
        viewBg.backgroundColor = WMColor.light_blue
        self.addSubview(viewBg)
        
        textView = UILabel(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: 48))
        textView.font = WMFont.fontMyriadProLightOfSize(18)
        textView.textColor = UIColor.white
        textView.numberOfLines = 2
        textView.textAlignment = NSTextAlignment.center
        self.addSubview(textView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBg.frame = CGRect(x: 0, y: 0,width: self.bounds.width,height: 48)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeStatus() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.frame = CGRect(x: self.frame.minX, y: self.frame.origin.y, width: self.frame.width, height: 0)
            }, completion: { (complete:Bool) -> Void in
            self.removeFromSuperview()
        }) 
    }
    
    func generateBlurImage(_ viewBg:UIView,frame:CGRect) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = blurredImage
        
        self.addSubview(imageBlurView)
        self.sendSubview(toBack: imageBlurView)
    }

    func prepareToClose() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WishlistAddProductStatus.closeStatus), userInfo: nil, repeats: false)
    }
    
}
