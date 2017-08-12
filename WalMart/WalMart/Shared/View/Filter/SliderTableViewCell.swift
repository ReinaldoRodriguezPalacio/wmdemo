//
//  SliderTableViewCell.swift
//  SAMS
//
//  Created by Jorge Mendizabal on 7/15/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import TTRangeSlider

protocol SliderTableViewCellDelegate: class {
    func rangerSliderDidChangeValues(forLowPrice low:Float, andHighPrice high:Float)
}

class SliderTableViewCell: UITableViewCell {

    var maxLabel: CurrencyCustomLabel?
    var minLabel: CurrencyCustomLabel?
    var currencyFmt: NumberFormatter?
    var slider: TTRangeSlider?
    weak var delegate: SliderTableViewCellDelegate?

    var minValue: Double = 0.0
    var maxValue: Double = 0.0
    var minSelected: Int = 0
    var maxSelected: Int = 0
    var values: [Any]?
    
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
        self.minLabel?.isHidden = true
        self.contentView.addSubview(self.minLabel!)

        self.maxLabel = CurrencyCustomLabel(frame: CGRect.zero)
        self.maxLabel!.backgroundColor = UIColor.clear
        self.maxLabel!.isHidden = true
        self.contentView.addSubview(self.maxLabel!)
        
        self.slider = TTRangeSlider()
        self.slider!.selectedHandleDiameterMultiplier = 1.0
        self.slider!.minDistance = 200
        self.slider!.tintColor = WMColor.empty_gray
        self.slider!.handleColor = self.labelColor
        self.slider!.tintColorBetweenHandles = self.labelColor
        self.slider!.handleDiameter = 20
        self.slider!.maxLabelColour = self.labelColor
        self.slider!.minLabelColour = self.labelColor
        self.slider!.maxLabelFont = self.numFont
        self.slider!.minLabelFont = self.numFont
        let formatter = NumberFormatter()
        if #available(iOS 9.0, *) {
            formatter.numberStyle = .currencyAccounting
        } else {
            formatter.numberStyle = .currency
        }
        self.slider!.numberFormatterOverride = formatter
        self.slider!.delegate = self
        self.contentView.addSubview(self.slider!)
        
        self.currencyFmt = NumberFormatter()
        self.currencyFmt!.numberStyle = .currency
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2

    }
    
    func setValuesSlider(_ priceValues:[Any]) {
        
        if  self.minValue == 0 && self.maxValue == 0 {
            self.minValue = priceValues.first as! Double
            self.maxValue = priceValues.last as! Double
            self.values = priceValues
            self.minSelected = 0
            self.maxSelected = self.values!.count - 1
            //self.setAmountLabels(forMinAmount: self.minValue, andMaxAmount: self.maxValue)
        }
        
        self.slider!.minValue = Float(values!.first! as! Double)
        self.slider!.maxValue = Float(values!.last! as! Double)
        self.slider!.selectedMinimum = Float(priceValues.first! as! Double)
        self.slider!.selectedMaximum = Float(priceValues.last! as! Double)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        self.slider!.frame = CGRect(x: 15.0, y: bounds.height - 45.0, width: bounds.width - 30.0, height: 35.0)
        self.layoutMounts()
    }
    
    func layoutMounts() {
        
//        let step = CGFloat(1.0/CGFloat(self.values!.count - 1))
//        let stepSize = step * self.slider!.frame.width
//    
//        let sizeMin = self.minLabel!.sizeOfLabel()
//        let minX = (stepSize * CGFloat(self.minSelected)) == 0 ? 15 :  (stepSize * CGFloat(self.minSelected)) + 8
//        
//        self.minLabel!.frame = CGRect(x: minX, y: 18.0, width: sizeMin.width, height: sizeMin.height)
//        //self.minLabel!.frame.origin.x = (stepSize * CGFloat(self.minValue)) + 15
//
//        let sizeMax = self.maxLabel!.sizeOfLabel()
//        self.maxLabel!.frame = CGRect(x: (stepSize * CGFloat(self.maxSelected)) - 20, y:  18.0, width: sizeMax.width, height: sizeMax.height)
    }
    
    func setAmountLabels(forMinAmount min:Double, andMaxAmount max:Double) {
        self.minLabel!.updateMount(self.currencyFmt!.string(from: NSNumber(value: min as Double))!,
            fontInt:self.numFont!, colorInt:self.labelColor, fontDecimal:self.centFont!, colorDecimal:self.labelColor)
        
        self.maxLabel!.updateMount(self.currencyFmt!.string(from: NSNumber(value: max as Double))!,
            fontInt:self.numFont!, colorInt:self.labelColor, fontDecimal:self.centFont!, colorDecimal:self.labelColor)
    }
    
    
    
    func resetSlider() {
        //self.slider!.setLowerValue(0, upperValue: 1, animated: true)
        self.setAmountLabels(forMinAmount: self.minValue, andMaxAmount: self.maxValue)
        self.layoutMounts()
    }
}

extension SliderTableViewCell: TTRangeSliderDelegate {
    
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        
//        self.setAmountLabels(forMinAmount: self.values![Int(selectedMinimum)] as! Double, andMaxAmount: self.values![Int(selectedMaximum)] as! Double)
//        self.layoutMounts()
//        self.minSelected = Int(selectedMinimum)
//        self.maxSelected = Int(selectedMaximum)
        self.delegate?.rangerSliderDidChangeValues(forLowPrice: selectedMinimum, andHighPrice: selectedMaximum)
    }
    
//    func report(){
//        let lower = Int(roundf(self.slider!.lowerValue/self.slider!.stepValue))
//        let upper = Int(roundf(self.slider!.upperValue/self.slider!.stepValue))
//        
//        self.setAmountLabels(forMinAmount: self.values![lower] as! Double, andMaxAmount: self.values![upper] as! Double)
//        self.layoutMounts()
//        
//        
//    }
}
