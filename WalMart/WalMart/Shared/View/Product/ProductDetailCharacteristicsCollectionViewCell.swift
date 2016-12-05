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
        titleLabel.frame = CGRect(x: 12, y: 0, width: self.bounds.width - (12 * 2), height: 40.0)
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.textColor =  WMColor.light_blue
        
        descLabel = UIView()
        
        downBorder = UIView(frame: CGRect.zero)
        downBorder.backgroundColor = WMColor.light_light_gray
        self.addSubview(downBorder)
        self.addSubview(descLabel)
        self.addSubview(titleLabel)
        
        self.isUserInteractionEnabled = true
    }
    
    func setValues(_ values:[[String:Any]]){
        var currentY = 40.0 as CGFloat
        var index = 0
        
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        setup()
        for dicValue in values {
            //var valuesValues = [String:Any]()
            let dicVal = dicValue
            let strLabel = dicVal["label"] as! String
            let strValue = dicVal["value"] as! String
                
            let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.gray, colorValue:WMColor.dark_gray, size: 14)
            let rectSize = attrString.boundingRect(with: CGSize(width: self.frame.width - 32, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            let bgView = UIView(frame: CGRect(x: 0, y: currentY, width: self.frame.width, height: rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()))
            let labelCharacteristic = WMTCopyLable(frame: CGRect(x: 16, y: 5, width: self.frame.width-32, height: rectSize.height))
            labelCharacteristic.stringCopy = strValue
            labelCharacteristic.attributedText = attrString
            labelCharacteristic.numberOfLines = 0
            index += 1
            if index % 2 == 0 {
                bgView.backgroundColor = UIColor.white
            }else{
                bgView.backgroundColor = WMColor.light_light_gray
            }
            bgView.addSubview(labelCharacteristic)
            bgView.isUserInteractionEnabled = true
            descLabel.isUserInteractionEnabled = true
            self.superview?.isUserInteractionEnabled = true
            descLabel.addSubview(bgView)
            currentY += rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()
        }
        descLabel.frame = CGRect(x: 0, y: 0,  width: self.frame.width, height: currentY)
        downBorder.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth())
        
    }
    
    
    class func sizeForCell(_ width:CGFloat,values:[[String:Any]]) -> CGFloat {
        var heigth = 0.0 as CGFloat
        //var valuesDict = NSMutableArray()
        
        for dicValue in values {
            //var valuesValues = [String:Any]()
            let dicVal = dicValue
            let strLabel = dicVal["label"] as! String
            let strValue = dicVal["value"] as! String
            let attrString =  buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.gray, colorValue:WMColor.dark_gray, size:14)
            let rectSize = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            heigth += rectSize.height + heightCharacteristic()
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
