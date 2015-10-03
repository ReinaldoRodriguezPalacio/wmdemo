//
//  UIButton+Walmart.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class WMRoundButton : UIButton {
    
    var imageSize : CGSize?
    var isEdgeImageSet = false
    
    private func imageWithColor(color: UIColor,size:CGSize) -> UIImage {
        let layerBg = CALayer()
        layerBg.frame = CGRectMake(0, 0, size.width, size.height)
        layerBg.backgroundColor = color.CGColor
        layerBg.masksToBounds = true
        layerBg.cornerRadius = size.height / 2
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        layerBg.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return roundedImage;
    }
    
    func setBackgroundColor(color: UIColor,size:CGSize, forUIControlState state: UIControlState) {
        self.imageSize = size
        self.setImage(imageWithColor(color,size:size), forState: state)
        if !isEdgeImageSet {
            self.titleEdgeInsets = UIEdgeInsetsMake(self.titleEdgeInsets.top , self.titleEdgeInsets.left - size.width, self.titleEdgeInsets.bottom, self.titleEdgeInsets.right)
            isEdgeImageSet = true
        }
    }
    
    func setFontTitle(font:UIFont) {
        //self.titleEdgeInsets = UIEdgeInsetsMake(self.titleEdgeInsets.top + 2.0 , self.titleEdgeInsets.left + 1.0, self.titleEdgeInsets.bottom, self.titleEdgeInsets.right)
        self.titleLabel?.font = font
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
}