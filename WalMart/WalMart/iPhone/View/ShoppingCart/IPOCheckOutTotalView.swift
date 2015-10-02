//
//  IPOCheckOutTotalView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPOCheckOutTotalView : UIView {
    
    
    var numProducts : UILabel!
    var savingTitleLable : UILabel!
    var subtotalTitleLabel : UILabel!
    var savingValueLabel : CurrencyCustomLabel!
    var totalTitleLable : UILabel!
    var totalValueLabel : CurrencyCustomLabel!
    var subtotalValueLabel : CurrencyCustomLabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        numProducts = UILabel(frame: CGRectMake(16, 16, 75, 14))
        numProducts.font = WMFont.fontMyriadProSemiboldOfSize(14)
        numProducts.textColor = WMColor.shoppingCartShopTotalsTextColor
        self.addSubview(numProducts)
        
        
        
        subtotalTitleLabel = UILabel()
        subtotalTitleLabel.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitleLabel.textColor = WMColor.regular_gray
        subtotalTitleLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        subtotalTitleLabel.textAlignment = .Right
        subtotalTitleLabel.frame = CGRectMake(156, 18, 91, 12)
        
        
        savingTitleLable = UILabel()
        savingTitleLable.text = NSLocalizedString("shoppingcart.saving",comment:"")
        savingTitleLable.textColor =  WMColor.savingTextColor
        savingTitleLable.font = WMFont.fontMyriadProSemiboldOfSize(12)
        savingTitleLable.textAlignment = .Right
        savingTitleLable.frame = CGRectMake(156, subtotalTitleLabel.frame.maxY + 6, 91, 12)
        
        
        totalTitleLable = UILabel()
        totalTitleLable.text = NSLocalizedString("shoppingcart.total",comment:"")
        totalTitleLable.textColor =  WMColor.orange
        totalTitleLable.font = WMFont.fontMyriadProSemiboldOfSize(12)
        totalTitleLable.textAlignment = .Right
        totalTitleLable.frame = CGRectMake(156, savingTitleLable.frame.maxY + 6, 91, 12)
        
        
        
        
        subtotalValueLabel = CurrencyCustomLabel(frame: CGRectMake(subtotalTitleLabel.frame.maxX + 3, subtotalTitleLabel.frame.minY, 50, 12))
        subtotalValueLabel.textAlignment = .Right
       
        savingValueLabel = CurrencyCustomLabel(frame: CGRectMake(savingTitleLable.frame.maxX + 3, savingTitleLable.frame.minY, 50, 12))
        savingValueLabel.textAlignment = .Right
        
        totalValueLabel = CurrencyCustomLabel(frame: CGRectMake(totalTitleLable.frame.maxX + 3, totalTitleLable.frame.minY, 50, 12))
        totalValueLabel.textAlignment = .Right
        
        self.addSubview(savingValueLabel)
        self.addSubview(totalValueLabel)
        self.addSubview(numProducts)
        self.addSubview(subtotalTitleLabel)
        self.addSubview(savingTitleLable)
        self.addSubview(totalTitleLable)
        self.addSubview(subtotalValueLabel)
        
    }
    
    
    func setValues(numProds: String,subtotal: String,saving:String){
        
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        numProducts.text = "\(numProds) \(articles)"

       
        
        if saving == "" {
            savingValueLabel.hidden = true
            savingTitleLable.hidden = true
            
            subtotalValueLabel.hidden = true
            subtotalTitleLabel.hidden = true
            
            
            totalValueLabel.frame = CGRectMake(totalValueLabel.frame.minX, (95 / 2) - (totalValueLabel.frame.height / 2), totalValueLabel.frame.width, totalValueLabel.frame.height)
            totalTitleLable.frame = CGRectMake(totalTitleLable.frame.minX, (95 / 2) - (totalTitleLable.frame.height / 2), totalTitleLable.frame.width, totalTitleLable.frame.height)
            numProducts.frame = CGRectMake(numProducts.frame.minX, (95 / 2) - (numProducts.frame.height / 2), numProducts.frame.width, numProducts.frame.height)
            
            let formatedTotal = CurrencyCustomLabel.formatString(subtotal)
            totalValueLabel.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.orange, interLine: false)
            
            
        }else {
            
            savingValueLabel.hidden = false
            savingTitleLable.hidden = false
            
            subtotalValueLabel.hidden = false
            subtotalTitleLabel.hidden = false
            
            
            
            totalTitleLable.frame = CGRectMake(156, savingTitleLable.frame.maxY + 6, 91, 12)
            totalValueLabel.frame = CGRectMake(totalTitleLable.frame.maxX + 3, totalTitleLable.frame.minY, 50, 12)
            numProducts.frame = CGRectMake(16, 16, 75, 14)
            
            let dSaving = NSNumberFormatter().numberFromString(saving)
            let dSubtotal = NSNumberFormatter().numberFromString(subtotal)
            let total = dSubtotal!.doubleValue - dSaving!.doubleValue
            
            let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
            subtotalValueLabel.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.shoppingCartShopTotalsTextColor, interLine: false)
            
            let formatedSaving = CurrencyCustomLabel.formatString(saving)
            savingValueLabel.updateMount(formatedSaving, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.savingTextColor, interLine: false)
            
            let formatedTotal = CurrencyCustomLabel.formatString("\(total)")
            totalValueLabel.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.orange, interLine: false)
            
        }
    }
    
    
    
}