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
    var currencyFmt: NumberFormatter?
    var slider: NMRangeSlider?
    var delegate: SliderTableViewCellDelegate?

    var minValue: Double = 0.0
    var maxValue: Double = 0.0
    var values: NSArray?
    
    let labelColor =  WMColor.light_blue
    let numFont = WMFont.fontMyriadProRegularOfSize(12)
    let centFont = WMFont.fontMyriadProRegularOfSize(6)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none

        self.minLabel = CurrencyCustomLabel(frame: CGRect.zero)
        self.minLabel!.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.minLabel!)

        self.maxLabel = CurrencyCustomLabel(frame: CGRect.zero)
        self.maxLabel!.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.maxLabel!)
        
        self.slider = NMRangeSlider(frame: CGRect(x: 15.0, y: 0.0, width: 290.0, height: 35.0))
        self.slider!.stepValue = 0.2
        self.slider!.stepValueContinuously = true
        self.slider!.continuous = false
        self.slider!.addTarget(self, action: #selector(SliderTableViewCell.report(_:)), for: .valueChanged)
        self.contentView.addSubview(self.slider!)
        
        self.currencyFmt = NumberFormatter()
        self.currencyFmt!.numberStyle = .currency
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2

    }
    
    func setValuesSlider(_ priceValues:NSArray) {
        if  self.minValue == 0 && self.maxValue == 0 {
            self.minValue = priceValues.firstObject as! Double
            self.maxValue = priceValues.lastObject as! Double
            self.values = priceValues
        
            self.setAmountLabels(forMinAmount: self.minValue, andMaxAmount: self.maxValue)
        }
        
        let step = Float(1.0/Float(self.values!.count - 1))
        self.slider!.minimumRange = step
        self.slider!.stepValue = step
        self.slider!.stepValueContinuously = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        self.slider!.frame = CGRect(x: 15.0, y: bounds.height - 45.0, width: bounds.width - 30.0, height: 35.0)
        if self.slider!.lowerValue == 0 && self.slider!.upperValue == 1.0 {
            var size = self.minLabel!.sizeOfLabel()
            self.minLabel!.frame = CGRect(x: 15.0, y: 20.0, width: size.width, height: size.height)
            self.minLabel!.center = CGPoint(x: 11.0 + (self.slider!.frame.height/2), y: self.minLabel!.center.y)
            size = self.maxLabel!.sizeOfLabel()
            self.maxLabel!.frame = CGRect(x: bounds.width - (15.0 + size.width), y: 20.0, width: size.width, height: size.height)
            self.maxLabel!.center = CGPoint(x: self.slider!.frame.maxX - (self.slider!.frame.height/2) - 4, y: self.maxLabel!.center.y)
        }
        else {
            self.layoutMounts()
        }
    }
    
    func layoutMounts() {
        let oldMin = self.minLabel!.center
        let sizeMin = self.minLabel!.sizeOfLabel()
        self.minLabel!.frame = CGRect(x: 15.0, y: 10.0, width: sizeMin.width, height: sizeMin.height)
        self.minLabel!.center = CGPoint(x: (self.slider!.lowerCenter.x + self.slider!.frame.origin.x) , y: oldMin.y)
        
        let oldMax = self.minLabel!.center
        let sizeMax = self.maxLabel!.sizeOfLabel()
        self.maxLabel!.frame = CGRect(x: 0.0, y: 0.0, width: sizeMax.width, height: sizeMax.height)
        self.maxLabel!.center = CGPoint(x: (self.slider!.upperCenter.x + self.slider!.frame.origin.x) - 6, y: oldMax.y)
        
        let differenceLabels = self.minLabel!.frame.maxX - self.maxLabel!.frame.minX
        if differenceLabels < 0 && differenceLabels > -3.0{
           self.minLabel!.center = CGPoint(x: self.minLabel!.center.x - 11.0, y: self.minLabel!.center.y)
        }
        
        if self.minLabel!.frame.intersects(self.maxLabel!.frame) {
            var diff = self.minLabel!.frame.maxX - self.maxLabel!.frame.minX
            let minf: CGFloat = self.slider!.frame.minX
            let maxf: CGFloat = self.slider!.frame.maxX
            if minf >= self.minLabel!.frame.minX {
                self.maxLabel!.center = CGPoint(x: self.maxLabel!.center.x + (diff + 6.0), y: self.maxLabel!.center.y)
            }
            else if maxf <= self.maxLabel!.frame.maxX {
                self.minLabel!.center = CGPoint(x: self.minLabel!.center.x - (diff + 6.0), y: self.minLabel!.center.y)
            }
            else {
                diff = round(diff/2)
                self.maxLabel!.center = CGPoint(x: self.maxLabel!.center.x + (diff + 3.0), y: self.maxLabel!.center.y)
                self.minLabel!.center = CGPoint(x: self.minLabel!.center.x - (diff - 3.0), y: self.minLabel!.center.y)
            }
        }
    }
    
    func setAmountLabels(forMinAmount min:Double, andMaxAmount max:Double) {
        self.minLabel!.updateMount(self.currencyFmt!.string(from: NSNumber(value: min as Double))!,
            fontInt:self.numFont!, colorInt:self.labelColor, fontDecimal:self.centFont!, colorDecimal:self.labelColor)
        
        self.maxLabel!.updateMount(self.currencyFmt!.string(from: NSNumber(value: max as Double))!,
            fontInt:self.numFont!, colorInt:self.labelColor, fontDecimal:self.centFont!, colorDecimal:self.labelColor)
    }
    
    func report(_ slide: NMRangeSlider){
        let lower = Int(roundf(self.slider!.lowerValue/self.slider!.stepValue))
        let upper = Int(roundf(self.slider!.upperValue/self.slider!.stepValue))
        
        self.setAmountLabels(forMinAmount: self.values![lower] as! Double, andMaxAmount: self.values![upper] as! Double)
        self.layoutMounts()

        self.delegate?.rangerSliderDidChangeValues(forLowPrice: lower, andHighPrice: upper)
    }
    
    func resetSlider() {
        self.slider!.setLowerValue(0, upperValue: 1, animated: true)
        self.setAmountLabels(forMinAmount: self.minValue, andMaxAmount: self.maxValue)
        self.layoutMounts()
    }
}
