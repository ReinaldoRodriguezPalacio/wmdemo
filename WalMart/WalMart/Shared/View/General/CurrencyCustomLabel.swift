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
    var textAlignment : NSTextAlignment = NSTextAlignment.center
    var spaceBetNums : UInt8 = 0
    var interLine = false
    var hasLine = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    
    func updateMount (_ value: String,fontInt:UIFont,colorInt:UIColor,fontDecimal:UIFont,colorDecimal:UIColor) {
        updateMount (value,fontInt: fontInt,colorInt: colorInt,fontDecimal: fontDecimal,colorDecimal: colorDecimal,interLine:false)
    }
    
    func updateMount (_ value: String,font:UIFont,color:UIColor,interLine:Bool) {
        let decimalFont =  UIFont(name: font.fontName, size: font.pointSize / 2)
        updateMount (value,fontInt: font,colorInt: color,fontDecimal: decimalFont! ,colorDecimal: color,interLine:interLine)
        
    }
    
    
    func updateMount (_ value: String,fontInt:UIFont,colorInt:UIColor,fontDecimal:UIFont,colorDecimal:UIColor,interLine:Bool) {
        
        self.label1!.textColor = colorInt
        intFont = fontInt
        
        self.label2!.textColor = colorDecimal
        decimalFont = fontDecimal
        
        updateMount(value,interLine:interLine)
    }
    
    
    func updateMount (_ value: String,interLine:Bool) {

        self.interLine = interLine
        let values = value.components(separatedBy: ".")
        
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
        
        if value.range(of: "X") != nil{
            self.label1!.text = value
            self.label2!.text = ""
        }
        
        if value.range(of: "costo") != nil{
            self.label1!.text = value
            self.label2!.text = ""
        }
        
        let sizeOfFirstText = label1!.text!.size(attributes: [NSFontAttributeName: label1!.font])
        let sizeOfSecondText = label2!.text!.size(attributes: [NSFontAttributeName: label2!.font])
        
        let totalWidth = sizeOfFirstText.width + sizeOfSecondText.width
        var xLabel : CGFloat = 0.0
        
        if textAlignment == NSTextAlignment.center {
            xLabel = (self.frame.width / 2) - (totalWidth / 2)
        }
        else
        if textAlignment == NSTextAlignment.right {
            xLabel = self.frame.width - sizeOfSecondText.width - sizeOfFirstText.width
        }
        
        label1!.frame = CGRect(x: xLabel,y: (self.frame.height / 2) - (sizeOfFirstText.height / 2), width: sizeOfFirstText.width, height: sizeOfFirstText.height)
        
        label2!.frame = CGRect(x: label1!.frame.maxX, y: (self.frame.height / 2) - (sizeOfFirstText.height / 2), width: sizeOfSecondText.width, height: sizeOfSecondText.height)
        //print("label1:\(label1!.text), hidden:\(label1!.hidden) label2:\(label2!.text), hidden:\(label2!.hidden)")
    }
    
    func setCurrencyUserInteractionEnabled(_ enabled:Bool) {
        isUserInteractionEnabled = false
        isExclusiveTouch = false
        label1!.isUserInteractionEnabled = false
        label1!.isExclusiveTouch = false
        label2!.isUserInteractionEnabled = false
        label2!.isExclusiveTouch = false
    }
    
    func sizeOfLabel() -> CGSize {
        return CGSize(width: label2!.frame.maxX,height: label1!.frame.maxY)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizeOfFirstText = label1!.text!.size(attributes: [NSFontAttributeName: label1!.font])
        let sizeOfSecondText = label2!.text!.size(attributes: [NSFontAttributeName: label2!.font])
        
        let totalWidth = sizeOfFirstText.width + sizeOfSecondText.width
        var xLabel : CGFloat = 0.0
        
        if textAlignment == NSTextAlignment.center {
            xLabel = (self.frame.width / 2) - (totalWidth / 2)
        }
        else
            if textAlignment == NSTextAlignment.right {
                xLabel = self.frame.width - sizeOfSecondText.width - sizeOfFirstText.width
        }
        
        label1!.frame = CGRect(x: xLabel,y: (self.frame.height / 2) - (sizeOfFirstText.height / 2), width: sizeOfFirstText.width, height: sizeOfFirstText.height)
        
        label2!.frame = CGRect(x: label1!.frame.maxX, y: (self.frame.height / 2) - (sizeOfFirstText.height / 2), width: sizeOfSecondText.width, height: sizeOfSecondText.height)
        
        if self.interLine && !self.hasLine {
            self.hasLine = true
            let sizeTotal : CGSize = sizeOfLabel()
            
            let line: CALayer = CALayer()
            line.frame = CGRect(x: self.label1!.frame.minX,y: sizeTotal.height / 2,width: totalWidth, height: 1)
            line.backgroundColor = WMColor.light_gray.cgColor
            self.layer.insertSublayer(line, at: 0)
        }
    }
    
    class func formatString (_ value:NSString) -> String {
        
        let setNumeric = CharacterSet(charactersIn: "0123456789.")
        if value.rangeOfCharacter(from: setNumeric.inverted).location == NSNotFound {
            let formatter = NumberFormatter();
            formatter.numberStyle = NumberFormatter.Style.currency
            formatter.maximumFractionDigits = 2
            formatter.locale = Locale(identifier: "es_MX")
            return formatter.string(from: NSNumber(value: value.doubleValue as Double))!
        }
        return value as String
       
    }
    
    class func formatNegativeString (_ value:NSString) -> String {
        let result = formatString(value)
        if value.doubleValue > 0 {
            return "- \(result)"
        }
        return result
    }
    
    class func formatStringLabel(_ value:NSString) -> String {
        
        let setNumeric = CharacterSet(charactersIn: "0123456789.")
        if value.rangeOfCharacter(from: setNumeric.inverted).location == NSNotFound {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value.doubleValue as Double))!
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
