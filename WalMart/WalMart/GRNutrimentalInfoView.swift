//
//  GRNutrimentalInfoView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/05/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRNutrimentalInfoView : UIView {
    
    var imageBlurView : UIImageView!
    var textView : UITextView!
    var closeDetail : (() -> Void)? = nil
    var viewBg : UIView!
    var scrollView : UIScrollView!
    
    func setup(_ ingredients:String,nutrimentals:[String:String]) {
    
        
        
        self.clipsToBounds = true
        
        viewBg = UIView(frame:CGRect(x: 0, y: 0,width: self.frame.width,height: 0))
        viewBg.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
        self.addSubview(viewBg)
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(GRNutrimentalInfoView.closeProductDetail), for: UIControlEvents.touchUpInside)
        self.addSubview(closeButton)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: closeButton.frame.maxY, width: self.frame.width, height: self.frame.height -  closeButton.frame.maxY))
        
        var startPointY : CGFloat = 0
        
        if ingredients.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            let titleLabel = UILabel(frame: CGRect(x: 0,y: startPointY,width: self.frame.width,height: 14))
            titleLabel.font = WMFont.fontMyriadProSemiboldOfSize(14)
            titleLabel.textColor = UIColor.white
            titleLabel.text = NSLocalizedString("productdetail.ingregients.title", comment: "")
            titleLabel.textAlignment = .center
            self.scrollView.addSubview(titleLabel)
            
            startPointY = titleLabel.frame.maxY + 8
            let ingredientsLabel = UILabel(frame: CGRect(x: 16,y: startPointY,width: self.frame.width - 32,height: 14))
            ingredientsLabel.font = WMFont.fontMyriadProRegularOfSize(16)
            ingredientsLabel.textColor = UIColor.white
            ingredientsLabel.text = ingredients
            ingredientsLabel.textAlignment = .justified
            ingredientsLabel.numberOfLines = 0
            ingredientsLabel.sizeToFit()
            self.scrollView.addSubview(ingredientsLabel)
            
            startPointY = ingredientsLabel.frame.maxY + 8
            
        }
        
        if nutrimentals.count > 0 {
            let titleLabel = UILabel(frame: CGRect(x: 0,y: startPointY + 8,width: self.frame.width,height: 14))
            titleLabel.font = WMFont.fontMyriadProSemiboldOfSize(14)
            titleLabel.textColor = UIColor.white
            titleLabel.text = NSLocalizedString("productdetail.infonut.title", comment: "")
            titleLabel.textAlignment = .center
            self.scrollView.addSubview(titleLabel)
            
            startPointY = startPointY + 30
            
            var white = true
            
            for nutItem in nutrimentals.keys {
                let viewItem = UIView(frame: CGRect(x: 0, y: startPointY, width: self.frame.width, height: 20))
                if white {
                    viewItem.backgroundColor = UIColor.white.withAlphaComponent(0.1)
                }
                white = !white

                let leftLabel = UILabel(frame: CGRect(x: 16, y: 0, width: self.frame.width - 32, height: 20))
                leftLabel.textAlignment = .left
                leftLabel.textColor = UIColor.white
                leftLabel.font = WMFont.fontMyriadProSemiboldOfSize(14)
                leftLabel.text = "\(nutItem):"
                
                
                let rigthLabel = UILabel(frame: CGRect(x: 16, y: 0, width: self.frame.width - 32, height: 20))
                rigthLabel.textAlignment = .right
                rigthLabel.textColor = UIColor.white
                rigthLabel.font = WMFont.fontMyriadProRegularOfSize(14)
                rigthLabel.text = nutrimentals[nutItem]
                viewItem.addSubview(rigthLabel)
                
                viewItem.addSubview(leftLabel)
                startPointY = startPointY + 20
                
                self.scrollView.addSubview(viewItem)
            }
            
            
        }
        
        scrollView.contentSize = CGSize(width: self.frame.width, height: startPointY + 16)
        self.addSubview(scrollView)

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height > 0 {
            viewBg.frame = self.bounds
            scrollView.frame =  CGRect(x: 0,y: 44, width: self.bounds.width, height: self.bounds.height -  44)
        }

    }
    
    /**
     Set text to deailview
     
     - parameter detail: Message text
     */
    func setTextDetail(_ detail:String) {
        self.textView.text = detail
    }
    
    /**
     Cloase view detail
     */
    func closeProductDetail() {
        if closeDetail != nil  {
            closeDetail!()
        }
    }
    
    /**
     Create image blur it presented width alert view
     
     - parameter viewBg: view present
     - parameter frame:  frame view
     */
    func generateBlurImage(_ viewBg:UIView,frame:CGRect) {
        var cloneImage : UIImage? = nil
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

    
}
