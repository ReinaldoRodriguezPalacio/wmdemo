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
        numProducts = UILabel(frame: CGRect(x: 16, y: 16, width: 75, height: 14))
        numProducts.font = WMFont.fontMyriadProSemiboldOfSize(14)
        numProducts.textColor = WMColor.gray
        self.addSubview(numProducts)
        
        
        
        subtotalTitleLabel = UILabel()
        subtotalTitleLabel.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitleLabel.textColor = WMColor.gray
        subtotalTitleLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        subtotalTitleLabel.textAlignment = .right
        subtotalTitleLabel.frame = CGRect(x: 156, y: 18, width: 91, height: 12)
        
        
        savingTitleLable = UILabel()
        savingTitleLable.text = NSLocalizedString("shoppingcart.saving",comment:"")
        savingTitleLable.textColor =  WMColor.green
        savingTitleLable.font = WMFont.fontMyriadProSemiboldOfSize(12)
        savingTitleLable.textAlignment = .right
        savingTitleLable.frame = CGRect(x: 156, y: subtotalTitleLabel.frame.maxY + 6, width: 91, height: 12)
        
        
        totalTitleLable = UILabel()
        totalTitleLable.text = NSLocalizedString("shoppingcart.total",comment:"")
        totalTitleLable.textColor =  WMColor.orange
        totalTitleLable.font = WMFont.fontMyriadProSemiboldOfSize(12)
        totalTitleLable.textAlignment = .right
        totalTitleLable.frame = CGRect(x: 156, y: savingTitleLable.frame.maxY + 6, width: 91, height: 12)
        
        
        
        
        subtotalValueLabel = CurrencyCustomLabel(frame: CGRect(x: subtotalTitleLabel.frame.maxX + 3, y: subtotalTitleLabel.frame.minY, width: 50, height: 12))
        subtotalValueLabel.textAlignment = .right
       
        savingValueLabel = CurrencyCustomLabel(frame: CGRect(x: savingTitleLable.frame.maxX + 3, y: savingTitleLable.frame.minY, width: 50, height: 12))
        savingValueLabel.textAlignment = .right
        
        totalValueLabel = CurrencyCustomLabel(frame: CGRect(x: totalTitleLable.frame.maxX + 3, y: totalTitleLable.frame.minY, width: 50, height: 12))
        totalValueLabel.textAlignment = .right
        
        self.addSubview(savingValueLabel)
        self.addSubview(totalValueLabel)
        self.addSubview(numProducts)
        self.addSubview(subtotalTitleLabel)
        self.addSubview(savingTitleLable)
        self.addSubview(totalTitleLable)
        self.addSubview(subtotalValueLabel)
        
    }
    
    func setTotalValues(_ numProds: String,subtotal: String,saving:String){
    
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        numProducts.text = "\(numProds) \(articles)"
        savingValueLabel.isHidden = false
        savingTitleLable.isHidden = false
        
        subtotalValueLabel.isHidden = false
        subtotalTitleLabel.isHidden = false
        
        
        
        totalTitleLable.frame = CGRect(x: 156, y: savingTitleLable.frame.maxY + 6, width: 91, height: 12)
        totalValueLabel.frame = CGRect(x: totalTitleLable.frame.maxX + 3, y: totalTitleLable.frame.minY, width: 50, height: 12)
        numProducts.frame = CGRect(x: 16, y: 16, width: 75, height: 14)
        
        let dSaving = NumberFormatter().number(from: saving)
        let dSubtotal = NumberFormatter().number(from: subtotal)
        let subNewTotal = dSubtotal!.doubleValue + dSaving!.doubleValue
        
       // let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        subtotalValueLabel.updateMount( CurrencyCustomLabel.formatString(String(subNewTotal)), font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
        
       //s let formatedSaving = CurrencyCustomLabel.formatString(saving)
        savingValueLabel.updateMount(CurrencyCustomLabel.formatString(saving), font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.green, interLine: false)
        
        //let formatedTotal = CurrencyCustomLabel.formatString("\(total)")
        totalValueLabel.updateMount(CurrencyCustomLabel.formatString(subtotal), font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.orange, interLine: false)
        
        
    }
    
    func setValues(_ numProds: String,subtotal: String,saving:String){
        
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        numProducts.text = "\(numProds) \(articles)"

       
        
        if saving == "" {
            savingValueLabel.isHidden = true
            savingTitleLable.isHidden = true
            
            subtotalValueLabel.isHidden = true
            subtotalTitleLabel.isHidden = true
            
            
            totalValueLabel.frame = CGRect(x: totalValueLabel.frame.minX, y: (95 / 2) - (totalValueLabel.frame.height / 2), width: totalValueLabel.frame.width, height: totalValueLabel.frame.height)
            totalTitleLable.frame = CGRect(x: totalTitleLable.frame.minX, y: (95 / 2) - (totalTitleLable.frame.height / 2), width: totalTitleLable.frame.width, height: totalTitleLable.frame.height)
            numProducts.frame = CGRect(x: numProducts.frame.minX, y: (95 / 2) - (numProducts.frame.height / 2), width: numProducts.frame.width, height: numProducts.frame.height)
            
            let formatedTotal = CurrencyCustomLabel.formatString(subtotal)
            totalValueLabel.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.orange, interLine: false)
            
            
        }else {
            
            savingValueLabel.isHidden = false
            savingTitleLable.isHidden = false
            
            subtotalValueLabel.isHidden = false
            subtotalTitleLabel.isHidden = false
            
            
            
            totalTitleLable.frame = CGRect(x: 156, y: savingTitleLable.frame.maxY + 6, width: 91, height: 12)
            totalValueLabel.frame = CGRect(x: totalTitleLable.frame.maxX + 3, y: totalTitleLable.frame.minY, width: 50, height: 12)
            numProducts.frame = CGRect(x: 16, y: 16, width: 75, height: 14)
            
            let dSaving = NumberFormatter().number(from: saving)
            let dSubtotal = NumberFormatter().number(from: subtotal)
            let total = dSubtotal!.doubleValue - dSaving!.doubleValue
            
            let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
            subtotalValueLabel.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
            
            let formatedSaving = CurrencyCustomLabel.formatString(saving)
            savingValueLabel.updateMount(formatedSaving, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.green, interLine: false)
            
            let formatedTotal = CurrencyCustomLabel.formatString("\(total)")
            totalValueLabel.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.orange, interLine: false)
            
        }
    }
    
    
    
}
