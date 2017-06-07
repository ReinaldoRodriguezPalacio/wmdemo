//
//  PreviousDetailTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class PreviousDetailTableViewCell : ProductDetailCharacteristicsTableViewCell {
    
    func setValuesProvider(_ values:[Any]){
        var currentY = 0.0 as CGFloat
        self.clearView(descLabel)
        for dicValue in values {
            //var valuesValues = [String:Any]()
            if let dicVal = dicValue as? [String:Any] {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                
                let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.dark_gray, colorValue:WMColor.gray, size: 14, separator: " -")
                let rectSize = attrString.boundingRect(with: CGSize(width: self.frame.width - 32, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                let bgView = UIView(frame: CGRect(x: 0, y: currentY, width: self.frame.width, height: rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()))
                let labelCharacteristic = WMTCopyLable(frame: CGRect(x: 16, y: 5, width: self.frame.width-32, height: rectSize.height))
                labelCharacteristic.attributedText = attrString
                labelCharacteristic.stringCopy = strValue
                
                
                labelCharacteristic.numberOfLines = 0
                bgView.backgroundColor = UIColor.white
                bgView.isUserInteractionEnabled = true
                descLabel.isUserInteractionEnabled = true
                self.superview?.isUserInteractionEnabled = true
                bgView.addSubview(labelCharacteristic)
                descLabel.addSubview(bgView)
                currentY += rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()
            }
        }
        
        descLabel.frame = CGRect(x: 0, y: 0,  width: self.frame.width, height: currentY)
        downBorder.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth())
        
    }
}
