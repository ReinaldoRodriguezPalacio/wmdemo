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
    
    func setup(ingredients:String,nutrimentals:[String:String]) {
    
        
        
        self.clipsToBounds = true
        
        viewBg = UIView(frame:CGRectMake(0, 0,self.frame.width,0))
        viewBg.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.9)
        self.addSubview(viewBg)
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(GRNutrimentalInfoView.closeProductDetail), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(closeButton)
        
        scrollView = UIScrollView(frame: CGRectMake(0, closeButton.frame.maxY, self.frame.width, self.frame.height -  closeButton.frame.maxY))
        
        var startPointY : CGFloat = 0
        
        if ingredients.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
            let titleLabel = UILabel(frame: CGRectMake(0,startPointY,self.frame.width,14))
            titleLabel.font = WMFont.fontMyriadProSemiboldOfSize(14)
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.text = NSLocalizedString("productdetail.ingregients.title", comment: "")
            titleLabel.textAlignment = .Center
            self.scrollView.addSubview(titleLabel)
            
            startPointY = titleLabel.frame.maxY + 8
            let ingredientsLabel = UILabel(frame: CGRectMake(16,startPointY,self.frame.width - 32,14))
            ingredientsLabel.font = WMFont.fontMyriadProRegularOfSize(16)
            ingredientsLabel.textColor = UIColor.whiteColor()
            ingredientsLabel.text = ingredients
            ingredientsLabel.textAlignment = .Justified
            ingredientsLabel.numberOfLines = 0
            ingredientsLabel.sizeToFit()
            self.scrollView.addSubview(ingredientsLabel)
            
            startPointY = ingredientsLabel.frame.maxY + 8
            
        }
        
        if nutrimentals.count > 0 {
            let titleLabel = UILabel(frame: CGRectMake(0,startPointY + 8,self.frame.width,14))
            titleLabel.font = WMFont.fontMyriadProSemiboldOfSize(14)
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.text = NSLocalizedString("productdetail.infonut.title", comment: "")
            titleLabel.textAlignment = .Center
            self.scrollView.addSubview(titleLabel)
            
            startPointY = startPointY + 30
            
            var white = true
            
            for nutItem in nutrimentals.keys {
                let viewItem = UIView(frame: CGRectMake(0, startPointY, self.frame.width, 20))
                if white {
                    viewItem.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
                }
                white = !white

                let leftLabel = UILabel(frame: CGRectMake(16, 0, self.frame.width - 32, 20))
                leftLabel.textAlignment = .Left
                leftLabel.textColor = UIColor.whiteColor()
                leftLabel.font = WMFont.fontMyriadProSemiboldOfSize(14)
                leftLabel.text = "\(nutItem):"
                
                
                let rigthLabel = UILabel(frame: CGRectMake(16, 0, self.frame.width - 32, 20))
                rigthLabel.textAlignment = .Right
                rigthLabel.textColor = UIColor.whiteColor()
                rigthLabel.font = WMFont.fontMyriadProRegularOfSize(14)
                rigthLabel.text = nutrimentals[nutItem]
                viewItem.addSubview(rigthLabel)
                
                viewItem.addSubview(leftLabel)
                startPointY = startPointY + 20
                
                self.scrollView.addSubview(viewItem)
            }
            
            
        }
        
        scrollView.contentSize = CGSizeMake(self.frame.width, startPointY + 16)
        self.addSubview(scrollView)

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height > 0 {
            viewBg.frame = self.bounds
            scrollView.frame =  CGRectMake(0,44, self.bounds.width, self.bounds.height -  44)
        }

    }
    
    /**
     Set text to deailview
     
     - parameter detail: Message text
     */
    func setTextDetail(detail:String) {
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
        
        self.addSubview(imageBlurView)
        self.sendSubviewToBack(imageBlurView)
    }

    
}