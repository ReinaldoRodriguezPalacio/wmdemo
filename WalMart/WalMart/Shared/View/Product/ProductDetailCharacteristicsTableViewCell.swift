//
//  ProductDetailDescriptionCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailCharacteristicsTableViewCell :UITableViewCell {
    
    var descLabel = UIView()
    var downBorder = UIView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        let labelDesc = UILabel()
        labelDesc.numberOfLines = 0
        self.addSubview(labelDesc)
        
         descLabel = UIView()
         
         downBorder = UIView(frame: CGRectZero)
         downBorder.backgroundColor = WMColor.light_light_gray
         self.addSubview(downBorder)
         self.addSubview(descLabel)
    }
    
    func setValues(values:NSArray){
        var currentY = 0.0 as CGFloat
        var index = 0
        self.clearView(descLabel)
        for dicValue in values {
            //var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? NSDictionary {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                
                let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.reg_gray, colorValue:WMColor.dark_gray, size: 14)
                let rectSize = attrString.boundingRectWithSize(CGSizeMake(self.frame.width - 32, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                let bgView = UIView(frame: CGRectMake(0, currentY, self.frame.width, rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()))
                let labelCharacteristic = WMTCopyLable(frame: CGRectMake(16, 5, self.frame.width-32, rectSize.height))
                labelCharacteristic.attributedText = attrString
                labelCharacteristic.stringCopy = strValue
                
                
                labelCharacteristic.numberOfLines = 0
                index += 1
                if index % 2 == 0 {
                    bgView.backgroundColor = UIColor.whiteColor()
                }else{
                    bgView.backgroundColor = WMColor.light_light_gray
                }
                bgView.userInteractionEnabled = true
                descLabel.userInteractionEnabled = true
                self.superview?.userInteractionEnabled = true
                bgView.addSubview(labelCharacteristic)
                descLabel.addSubview(bgView)
                currentY += rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()
            }
        }
        
        descLabel.frame = CGRectMake(0, 0,  self.frame.width, currentY)
        downBorder.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth())
    }
    
    func clearView(view: UIView){
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
    }
    
    class func sizeForCell(width:CGFloat,values:NSArray) -> CGFloat {
        var heigth = 0.0 as CGFloat
        //var valuesDict = NSMutableArray()
        
        for dicValue in values {
            //var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? NSDictionary {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                let attrString =  buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.reg_gray, colorValue:WMColor.dark_gray, size:14)
                let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                heigth += rectSize.height + heightCharacteristic()
                
            }
        }
        return heigth
    }
    
    class func buildAttributtedString(key:String, value:String,  colorKey:UIColor,  colorValue:UIColor , size:CGFloat ) -> NSAttributedString {
        //var valueItem = NSMutableAttributedString()
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
