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
        
        self.backgroundColor = UIColor.white
        
        originalPriceLabel = CurrencyCustomLabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 15))
        currentPriceLabel = CurrencyCustomLabel(frame: CGRect(x: 0, y: originalPriceLabel.frame.maxY, width: self.frame.width, height: 15))
        savingPriceLabel = CurrencyCustomLabel(frame: CGRect(x: 0, y: currentPriceLabel.frame.maxY, width: self.frame.width, height: 15))
        
        originalPriceLabel.textAlignment = NSTextAlignment.center
        currentPriceLabel.textAlignment = NSTextAlignment.center
        savingPriceLabel.textAlignment = NSTextAlignment.center
        
        self.addSubview(originalPriceLabel)
        self.addSubview(currentPriceLabel)
        self.addSubview(savingPriceLabel)
        
    }
    
    func changePrices(_ originalPrice:String,currentPrice:String,savingPrice:String){
        
      
        
        let originalPriceFormatedValue = "\(CurrencyCustomLabel.formatString(originalPrice as NSString))"
        let currentPriceFormatedValue = "\(CurrencyCustomLabel.formatString(currentPrice as NSString))"
        
        let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
        let savingPriceFormatedValue = "\(ahorrasLabel) \(CurrencyCustomLabel.formatString(savingPrice as NSString))"
        
        originalPriceLabel.updateMount(originalPriceFormatedValue, font: WMFont.fontMyriadProLightOfSize(14), color: WMColor.dark_gray, interLine: true)
        currentPriceLabel.updateMount(currentPriceFormatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.reg_gray, interLine: false)
        savingPriceLabel.updateMount(savingPriceFormatedValue, font: WMFont.fontMyriadProSemiboldOfSize(14), color:WMColor.reg_gray, interLine: false)
        
      
        
        
    }
    
    
    
    
}
