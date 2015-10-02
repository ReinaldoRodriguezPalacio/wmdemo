//
//  ProductDetailCharacteristicsCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/8/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailCharacteristicsCollectionViewCell :UICollectionViewCell {
    var descLabel = UIView()
    var downBorder = UIView()
    var titleLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let labelDesc = UILabel()
        labelDesc.numberOfLines = 0
        self.addSubview(labelDesc)
        
        titleLabel.text = NSLocalizedString("productdetail.characteristics",comment:"")
        titleLabel.frame = CGRectMake(12, 0, self.bounds.width - (12 * 2), 40.0)
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Left
        titleLabel.textColor =  WMColor.productDetailTitleTextColor
        
        descLabel = UIView()
        
        downBorder = UIView(frame: CGRectZero)
        downBorder.backgroundColor = WMColor.lineSaparatorColor
        self.addSubview(downBorder)
        self.addSubview(descLabel)
        self.addSubview(titleLabel)
    }
    
    func setValues(values:NSArray){
        var currentY = 40.0 as CGFloat
        var index = 0
        
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        setup()
        for dicValue in values {
            var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? NSDictionary {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                
                let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.productDetailMSIBoldTextColor, colorValue:WMColor.productDetailMSITextColor, size: 14)
                let rectSize = attrString.boundingRectWithSize(CGSizeMake(self.frame.width - 32, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                let bgView = UIView(frame: CGRectMake(0, currentY, self.frame.width, rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()))
                let labelCharacteristic = UILabel(frame: CGRectMake(16, 5, self.frame.width-32, rectSize.height))
                labelCharacteristic.attributedText = attrString
                labelCharacteristic.numberOfLines = 0
                if index++ % 2 == 0 {
                    bgView.backgroundColor = UIColor.whiteColor()
                }else{
                    bgView.backgroundColor = WMColor.productDetailRowUnevenColor
                }
                bgView.addSubview(labelCharacteristic)
                descLabel.addSubview(bgView)
                currentY += rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()
            }
        }
        
        descLabel.frame = CGRectMake(0, 0,  self.frame.width, currentY)
        downBorder.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth())
        
    }
    
    
    class func sizeForCell(width:CGFloat,values:NSArray) -> CGFloat {
        var heigth = 0.0 as CGFloat
        var valuesDict = NSMutableArray()
        
        for dicValue in values {
            var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? NSDictionary {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                let attrString =  buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.productDetailMSIBoldTextColor, colorValue:WMColor.productDetailMSITextColor, size:14)
                let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                heigth += rectSize.height + heightCharacteristic()
                
            }
        }
        return heigth
    }
    
    class func buildAttributtedString(key:String, value:String,  colorKey:UIColor,  colorValue:UIColor , size:CGFloat ) -> NSAttributedString {
        var valueItem = NSMutableAttributedString()
        let valuesDescItem = NSMutableAttributedString()
        if key != ""{
            let attrStringLab = NSAttributedString(string:"\(key): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(size),NSForegroundColorAttributeName:colorKey])
            valuesDescItem.appendAttributedString(attrStringLab)
        }
        let attrStringVal = NSAttributedString(string:"\(value)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(size),NSForegroundColorAttributeName:colorValue])
        valuesDescItem.appendAttributedString(attrStringVal)
        return valuesDescItem
    }
    
    class func heightCharacteristic() -> CGFloat {
        return 10.0
    }
    
}
