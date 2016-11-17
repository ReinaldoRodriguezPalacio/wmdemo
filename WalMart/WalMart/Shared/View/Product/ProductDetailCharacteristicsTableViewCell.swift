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
         
         downBorder = UIView(frame: CGRect.zero)
         downBorder.backgroundColor = WMColor.light_light_gray
         self.addSubview(downBorder)
         self.addSubview(descLabel)
    }
    
    func setValues(_ values:[[String:Any]]){
        var currentY = 0.0 as CGFloat
        var index = 0
        self.clearView(descLabel)
        for dicValue in values {
            //var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? [String:Any] {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                
                let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.reg_gray, colorValue:WMColor.dark_gray, size: 14)
                let rectSize = attrString.boundingRect(with: CGSize(width: self.frame.width - 32, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                let bgView = UIView(frame: CGRect(x: 0, y: currentY, width: self.frame.width, height: rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()))
                let labelCharacteristic = WMTCopyLable(frame: CGRect(x: 16, y: 5, width: self.frame.width-32, height: rectSize.height))
                labelCharacteristic.attributedText = attrString
                labelCharacteristic.stringCopy = strValue
                
                
                labelCharacteristic.numberOfLines = 0
                index += 1
                if index % 2 == 0 {
                    bgView.backgroundColor = UIColor.white
                }else{
                    bgView.backgroundColor = WMColor.light_light_gray
                }
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
    
    func clearView(_ view: UIView){
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
    }
    
    class func sizeForCell(_ width:CGFloat,values:[[String:Any]]) -> CGFloat {
        var heigth = 0.0 as CGFloat
        //var valuesDict = NSMutableArray()
        
        for dicValue in values {
            //var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? [String:Any] {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                let attrString =  buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.reg_gray, colorValue:WMColor.dark_gray, size:14)
                let rectSize = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                heigth += rectSize.height + heightCharacteristic()
                
            }
        }
        return heigth
    }
    
    class func buildAttributtedString(_ key:String, value:String,  colorKey:UIColor,  colorValue:UIColor , size:CGFloat ) -> NSAttributedString {
        //var valueItem = NSMutableAttributedString()
        let valuesDescItem = NSMutableAttributedString()
        if key != ""{
            let attrStringLab = NSAttributedString(string:"\(key): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(size),NSForegroundColorAttributeName:colorKey])
            valuesDescItem.append(attrStringLab)
        }
        let attrStringVal = NSAttributedString(string:"\(value)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(size),NSForegroundColorAttributeName:colorValue])
        valuesDescItem.append(attrStringVal)
        return valuesDescItem
    }
    
    class func heightCharacteristic() -> CGFloat {
        return 10.0
    }
    
}
