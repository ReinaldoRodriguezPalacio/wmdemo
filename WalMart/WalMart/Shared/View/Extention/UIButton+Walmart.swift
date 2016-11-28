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
    
    fileprivate func imageWithColor(_ color: UIColor,size:CGSize) -> UIImage {
        let layerBg = CALayer()
        layerBg.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        layerBg.backgroundColor = color.cgColor
        layerBg.masksToBounds = true
        layerBg.cornerRadius = size.height / 2
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        layerBg.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return roundedImage!;
    }
    
    func setBackgroundColor(_ color: UIColor,size:CGSize, forUIControlState state: UIControlState) {
        self.imageSize = size
        self.setImage(imageWithColor(color,size:size), for: state)
        if !isEdgeImageSet {
            self.titleEdgeInsets = UIEdgeInsetsMake(self.titleEdgeInsets.top , self.titleEdgeInsets.left - size.width, self.titleEdgeInsets.bottom, self.titleEdgeInsets.right)
            isEdgeImageSet = true
        }
    }
    
    func setFontTitle(_ font:UIFont) {
        //self.titleEdgeInsets = UIEdgeInsetsMake(self.titleEdgeInsets.top + 2.0 , self.titleEdgeInsets.left + 1.0, self.titleEdgeInsets.bottom, self.titleEdgeInsets.right)
        self.titleLabel?.font = font
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
}
