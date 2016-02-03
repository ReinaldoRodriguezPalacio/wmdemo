//
//  IPAProductDetailPriceView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductDetailPriceView : UIView {
    
    var originalPriceLabel : CurrencyCustomLabel!
    var currentPriceLabel : CurrencyCustomLabel!
    var savingPriceLabel : CurrencyCustomLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        self.backgroundColor = UIColor.whiteColor()
        
        originalPriceLabel = CurrencyCustomLabel(frame: CGRectMake(0, 0, self.frame.width, 15))
        currentPriceLabel = CurrencyCustomLabel(frame: CGRectMake(0, originalPriceLabel.frame.maxY, self.frame.width, 15))
        savingPriceLabel = CurrencyCustomLabel(frame: CGRectMake(0, currentPriceLabel.frame.maxY, self.frame.width, 15))
        
        originalPriceLabel.textAlignment = NSTextAlignment.Center
        currentPriceLabel.textAlignment = NSTextAlignment.Center
        savingPriceLabel.textAlignment = NSTextAlignment.Center
        
        self.addSubview(originalPriceLabel)
        self.addSubview(currentPriceLabel)
        self.addSubview(savingPriceLabel)
        
    }
    
    func changePrices(originalPrice:String,currentPrice:String,savingPrice:String){
        
      
        
        let originalPriceFormatedValue = "\(CurrencyCustomLabel.formatString(originalPrice))"
        let currentPriceFormatedValue = "\(CurrencyCustomLabel.formatString(currentPrice))"
        
        let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
        let savingPriceFormatedValue = "\(ahorrasLabel) \(CurrencyCustomLabel.formatString(savingPrice))"
        
        originalPriceLabel.updateMount(originalPriceFormatedValue, font: WMFont.fontMyriadProLightOfSize(14), color: WMColor.dark_gray, interLine: true)
        currentPriceLabel.updateMount(currentPriceFormatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.gray, interLine: false)
        savingPriceLabel.updateMount(savingPriceFormatedValue, font: WMFont.fontMyriadProSemiboldOfSize(14), color:WMColor.gray, interLine: false)
        
      
        
        
    }
    
    
    
    
}