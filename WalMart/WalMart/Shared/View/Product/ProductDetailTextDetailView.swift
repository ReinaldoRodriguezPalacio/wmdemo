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
        
        viewBg = UIView(frame:CGRect(x: 0, y: 0,width: self.frame.width,height: 0))
        viewBg.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
        self.addSubview(viewBg)
        
        textView = UITextView(frame: CGRect(x: 15, y: 40, width: self.frame.width - 30, height: viewBg.frame.height - 50))
        textView.font = WMFont.fontMyriadProRegularOfSize(14)
        textView.textColor = UIColor.white
        
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        self.addSubview(textView)
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(ProductDetailTextDetailView.closeProductDetail), for: UIControlEvents.touchUpInside)
        self.addSubview(closeButton)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height > 0 {
            viewBg.frame = self.bounds
        }
        textView.frame = CGRect(x: 15, y: 40,  width: self.frame.width - 30, height: viewBg.frame.height - 50)
    }
    
    func setTextDetail(_ detail:String) {
        
        var detailString = detail.replacingOccurrences(of: "^^^^", with: "\n")
         detailString = detail.replacingOccurrences(of: "^^^", with: "\n")
         detailString = detail.replacingOccurrences(of: "^^", with: "\n")
         detailString = detail.replacingOccurrences(of: "^", with: " ")
        self.textView.text = detailString
    }
    func closeProductDetail() {
        if closeDetail != nil  {
            closeDetail!()
        }
    }
    
    
    func generateBlurImage(_ viewBg:UIView,frame:CGRect) {
        var cloneImage : UIImage? = nil
        //var blurredImage : UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.render(in: UIGraphicsGetCurrentContext()!)
        cloneImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        viewBg.layer.contents = nil
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = cloneImage!.applyLightEffect()
        cloneImage = nil
        
        self.addSubview(imageBlurView)
        self.sendSubview(toBack: imageBlurView)
    }
    
    deinit{
        print("close image")
    }
    
    
    
}
