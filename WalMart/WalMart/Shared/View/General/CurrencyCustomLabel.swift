//
//  CurrencyCustomLabel.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit


class CurrencyCustomLabel : UIView  {

    var label1 : UILabel? = nil
    var label2 : UILabel? = nil
    var intFont : UIFont? = nil
    var decimalFont : UIFont? = nil
    var intColor : UIColor? = nil
    var decimalColor : UIColor? = nil
    var textAlignment : NSTextAlignment = NSTextAlignment.Center
    var spaceBetNums : UInt8 = 0
    var interLine = false
    var hasLine = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setupView()
    }
    
    func setupView() {
        
        self.label1 = UILabel()
        self.label1!.text = ""
        self.label2 = UILabel()
        self.label2!.text = ""
  
        addSubview(self.label1!)
        addSubview(self.label2!)
    }
    
    
    func updateMount (value: String,fontInt:UIFont,colorInt:UIColor,fontDecimal:UIFont,colorDecimal:UIColor) {
        updateMount (value,fontInt: fontInt,colorInt: colorInt,fontDecimal: fontDecimal,colorDecimal: colorDecimal,interLine:false)
    }
    
    func updateMount (value: String,font:UIFont,color:UIColor,interLine:Bool) {
        let decimalFont =  UIFont(name: font.fontName, size: font.pointSize / 2)
        updateMount (value,fontInt: font,colorInt: color,fontDecimal: decimalFont! ,colorDecimal: color,interLine:interLine)
        
    }
    
    
    func updateMount (value: String,fontInt:UIFont,colorInt:UIColor,fontDecimal:UIFont,colorDecimal:UIColor,interLine:Bool) {
        
        self.label1!.textColor = colorInt
        intFont = fontInt
        
        self.label2!.textColor = colorDecimal
        decimalFont = fontDecimal
        
        updateMount(value,interLine:interLine)
    }
    
    
    func updateMount (value: String,interLine:Bool) {

         self.interLine = interLine
        let values = value.componentsSeparatedByString(".")
        
        if  intFont == nil {
            intFont = WMFont.fontMyriadProBlackOfSize(16)
        }
        
        if decimalFont == nil {
            decimalFont = WMFont.fontMyriadProBlackOfSize(8)
        }

        self.label1!.font = intFont!
        self.label2!.font = decimalFont!
        
        self.label1!.text = "\(values[0])."
        if values.count > 1 {
            self.label2!.text = values[1]
        }else{
            self.label2!.text = "00"
        }
        
        let sizeOfFirstText = label1!.text!.sizeWithAttributes([NSFontAttributeName: label1!.font])
        let sizeOfSecondText = label2!.text!.sizeWithAttributes([NSFontAttributeName: label2!.font])
        
        let totalWidth = sizeOfFirstText.width + sizeOfSecondText.width
        var xLabel : CGFloat = 0.0
        
        if textAlignment == NSTextAlignment.Center {
            xLabel = (self.frame.width / 2) - (totalWidth / 2)
        }
        else
        if textAlignment == NSTextAlignment.Right {
            xLabel = self.frame.width - sizeOfSecondText.width - sizeOfFirstText.width
        }
        
        label1!.frame = CGRectMake(xLabel,(self.frame.height / 2) - (sizeOfFirstText.height / 2), sizeOfFirstText.width, sizeOfFirstText.height)
        
        label2!.frame = CGRectMake(label1!.frame.maxX, (self.frame.height / 2) - (sizeOfFirstText.height / 2), sizeOfSecondText.width, sizeOfSecondText.height)
    }
    
    func setCurrencyUserInteractionEnabled(enabled:Bool) {
        userInteractionEnabled = false
        exclusiveTouch = false
        label1!.userInteractionEnabled = false
        label1!.exclusiveTouch = false
        label2!.userInteractionEnabled = false
        label2!.exclusiveTouch = false
    }
    
    func sizeOfLabel() -> CGSize {
        return CGSizeMake(label2!.frame.maxX,label1!.frame.maxY)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizeOfFirstText = label1!.text!.sizeWithAttributes([NSFontAttributeName: label1!.font])
        let sizeOfSecondText = label2!.text!.sizeWithAttributes([NSFontAttributeName: label2!.font])
        
        let totalWidth = sizeOfFirstText.width + sizeOfSecondText.width
        var xLabel : CGFloat = 0.0
        
        if textAlignment == NSTextAlignment.Center {
            xLabel = (self.frame.width / 2) - (totalWidth / 2)
        }
        else
            if textAlignment == NSTextAlignment.Right {
                xLabel = self.frame.width - sizeOfSecondText.width - sizeOfFirstText.width
        }
        
        label1!.frame = CGRectMake(xLabel,(self.frame.height / 2) - (sizeOfFirstText.height / 2), sizeOfFirstText.width, sizeOfFirstText.height)
        
        label2!.frame = CGRectMake(label1!.frame.maxX, (self.frame.height / 2) - (sizeOfFirstText.height / 2), sizeOfSecondText.width, sizeOfSecondText.height)
        
        if self.interLine && !self.hasLine {
            self.hasLine = true
            let sizeTotal : CGSize = sizeOfLabel()
            
            var line: CALayer = CALayer()
            line.frame = CGRectMake(self.label1!.frame.minX,sizeTotal.height / 2,totalWidth, 1)
            line.backgroundColor = WMColor.searchProductPriceThroughLineColor.CGColor
            self.layer.insertSublayer(line, atIndex: 0)
        }
    }
    
    class func formatString (value:NSString) -> String {
        
        let setNumeric = NSCharacterSet(charactersInString: "0123456789.")
        if value.rangeOfCharacterFromSet(setNumeric.invertedSet).location == NSNotFound {
            let formatter = NSNumberFormatter();
            formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            formatter.maximumFractionDigits = 2
            formatter.locale = NSLocale(localeIdentifier: "es_MX")
            return formatter.stringFromNumber(NSNumber(double:value.doubleValue))!
        }
        return value as String
       
    }
    
     deinit {
        label1 = nil
        label2 = nil
        intFont = nil
        decimalFont = nil
        intColor = nil
        decimalColor = nil
    }
    
}
