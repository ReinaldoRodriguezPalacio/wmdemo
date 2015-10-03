//
//  ProductDetailTextDetailView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailTextDetailView : UIView {
    
    
    var imageBlurView : UIImageView!
    var textView : UITextView!
    var closeDetail : (() -> Void)? = nil
    var viewBg : UIView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.clipsToBounds = true
        
        viewBg = UIView(frame:CGRectMake(0, 0,self.frame.width,0))
        viewBg.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        self.addSubview(viewBg)
        
        textView = UITextView(frame: CGRectMake(15, 40, self.frame.width - 30, viewBg.frame.height - 50))
        textView.font = WMFont.fontMyriadProRegularOfSize(14)
        textView.textColor = UIColor.whiteColor()
        
        textView.backgroundColor = UIColor.clearColor()
        textView.editable = false
        self.addSubview(textView)
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeProductDetail", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(closeButton)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height > 0 {
            viewBg.frame = self.bounds
        }
        textView.frame = CGRectMake(15, 40,  self.frame.width - 30, viewBg.frame.height - 50)
    }
    
    func setTextDetail(detail:String) {
        self.textView.text = detail
    }
    func closeProductDetail() {
        if closeDetail != nil  {
            closeDetail!()
        }
    }
    
    
    func generateBlurImage(viewBg:UIView,frame:CGRect) {
        var cloneImage : UIImage? = nil
        //var blurredImage : UIImage? = nil
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
        
        self.addSubview(imageBlurView)
        self.sendSubviewToBack(imageBlurView)
    }
    
    deinit{
        print("close image")
    }
    
    
    
}