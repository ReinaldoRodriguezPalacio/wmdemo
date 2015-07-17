//
//  SliderTableViewCell.swift
//  SAMS
//
//  Created by Jorge Mendizabal on 7/15/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol SliderTableViewCellDelegate {
    func rangerSliderDidChangeValues(forLowPrice low:Int, andHighPrice high:Int)
}

class SliderTableViewCell: UITableViewCell {

    var maxLabel: CurrencyCustomLabel?
    var minLabel: CurrencyCustomLabel?
    var currencyFmt: NSNumberFormatter?
    var slider: NMRangeSlider?
    var delegate: SliderTableViewCellDelegate?

    var minValue: Double = 0.0
    var maxValue: Double = 0.0
    var values: NSArray?
    
    let labelColor =  WMColor.navigationTilteTextColor
    let numFont = WMFont.fontMyriadProRegularOfSize(12)
    let centFont = WMFont.fontMyriadProRegularOfSize(6)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None

        self.minLabel = CurrencyCustomLabel(frame: CGRectZero)
        self.minLabel!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.minLabel!)

        self.maxLabel = CurrencyCustomLabel(frame: CGRectZero)
        self.maxLabel!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.maxLabel!)
        
        self.slider = NMRangeSlider(frame: CGRectMake(15.0, 0.0, 290.0, 35.0))
        self.slider!.stepValue = 0.2
        self.slider!.stepValueContinuously = true
        self.slider!.continuous = false
        self.slider!.addTarget(self, action: "report:", forControlEvents: .ValueChanged)
        self.contentView.addSubview(self.slider!)
        
        self.currencyFmt = NSNumberFormatter()
        self.currencyFmt!.numberStyle = .CurrencyStyle
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2

    }
    
    func setValues(priceValues:NSArray) {
        self.minValue = priceValues.firstObject as Double
        self.maxValue = priceValues.lastObject as Double
        self.values = priceValues
        self.setAmountLabels(forMinAmount: self.minValue, andMaxAmount: self.maxValue)

        var step = Float(1.0/Float(self.values!.count - 1))
        self.slider!.minimumRange = step
        self.slider!.stepValue = step
        self.slider!.stepValueContinuously = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        var bounds = self.frame.size
        self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.slider!.frame = CGRectMake(15.0, bounds.height - 45.0, bounds.width - 30.0, 35.0)
        if self.slider!.lowerValue == 0 && self.slider!.upperValue == 1.0 {
            var size = self.minLabel!.sizeOfLabel()
            self.minLabel!.frame = CGRectMake(15.0, 20.0, size.width, size.height)
            self.minLabel!.center = CGPointMake(15.0 + (self.slider!.frame.height/2), self.minLabel!.center.y)
            size = self.maxLabel!.sizeOfLabel()
            self.maxLabel!.frame = CGRectMake(bounds.width - (15.0 + size.width), 20.0, size.width, size.height)
            self.maxLabel!.center = CGPointMake(CGRectGetMaxX(self.slider!.frame) - (self.slider!.frame.height/2), self.maxLabel!.center.y)
        }
        else {
            self.layoutMounts()
        }
    }
    
    func layoutMounts() {
        var oldMin = self.minLabel!.center
        var sizeMin = self.minLabel!.sizeOfLabel()
        self.minLabel!.frame = CGRectMake(15.0, 10.0, sizeMin.width, sizeMin.height)
        self.minLabel!.center = CGPointMake((self.slider!.lowerCenter.x + self.slider!.frame.origin.x), oldMin.y)
        
        var oldMax = self.minLabel!.center
        var sizeMax = self.maxLabel!.sizeOfLabel()
        self.maxLabel!.frame = CGRectMake(0.0, 0.0, sizeMax.width, sizeMax.height)
        self.maxLabel!.center = CGPointMake((self.slider!.upperCenter.x + self.slider!.frame.origin.x), oldMax.y)
        
        if CGRectIntersectsRect(self.minLabel!.frame, self.maxLabel!.frame) {
            var diff = CGRectGetMaxX(self.minLabel!.frame) - CGRectGetMinX(self.maxLabel!.frame)
            var minf: CGFloat = CGRectGetMinX(self.slider!.frame)
            var maxf: CGFloat = CGRectGetMaxX(self.slider!.frame)
            if minf >= CGRectGetMinX(self.minLabel!.frame) {
                self.maxLabel!.center = CGPointMake(self.maxLabel!.center.x + (diff + 6.0), self.maxLabel!.center.y)
            }
            else if maxf <= CGRectGetMaxX(self.maxLabel!.frame) {
                self.minLabel!.center = CGPointMake(self.minLabel!.center.x - (diff + 6.0), self.minLabel!.center.y)
            }
            else {
                diff = round(diff/2)
                self.maxLabel!.center = CGPointMake(self.maxLabel!.center.x + (diff + 3.0), self.maxLabel!.center.y)
                self.minLabel!.center = CGPointMake(self.minLabel!.center.x - (diff - 3.0), self.minLabel!.center.y)
            }
        }
    }
    
    func setAmountLabels(forMinAmount min:Double, andMaxAmount max:Double) {
        self.minLabel!.updateMount(self.currencyFmt!.stringFromNumber(NSNumber(double: min))!,
            fontInt:self.numFont, colorInt:self.labelColor, fontDecimal:self.centFont, colorDecimal:self.labelColor)
        
        self.maxLabel!.updateMount(self.currencyFmt!.stringFromNumber(NSNumber(double: max))!,
            fontInt:self.numFont, colorInt:self.labelColor, fontDecimal:self.centFont, colorDecimal:self.labelColor)
    }
    
    func report(slide: NMRangeSlider){
//        println("self.slider!.stepValue: \(self.slider!.stepValue)")
        var lower = Int(roundf(self.slider!.lowerValue/self.slider!.stepValue))
        var upper = Int(roundf(self.slider!.upperValue/self.slider!.stepValue))
//        println("values: self.slider!.lowerValue:\(self.slider!.lowerValue) -> \(lower)")
//        println("values: self.slider!.upperValue:\(self.slider!.upperValue) -> \(upper)")
        
        self.setAmountLabels(forMinAmount: self.values![lower] as Double, andMaxAmount: self.values![upper] as Double)
        self.layoutMounts()

        self.delegate?.rangerSliderDidChangeValues(forLowPrice: lower, andHighPrice: upper)
    }
    
    func resetSlider() {
        self.slider!.setLowerValue(0, upperValue: 1, animated: true)
        self.setAmountLabels(forMinAmount: self.minValue, andMaxAmount: self.maxValue)
        self.layoutMounts()
    }
}
