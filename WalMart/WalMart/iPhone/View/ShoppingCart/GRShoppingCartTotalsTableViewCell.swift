//
//  GRShoppingCartTotalsTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/3/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRShoppingCartTotalsTableViewCell : ShoppingCartTotalsTableViewCell {
    
    var numProducts : UILabel!
    var firstTotal: Bool = true
    var subtotalY: CGFloat = 0.0
    
    override func setup() {
        super.setup()
        
        numProducts = UILabel(frame: CGRectMake(16, 25, 75, 14))
        numProducts.font = WMFont.fontMyriadProSemiboldOfSize(14)
        numProducts.textColor = WMColor.gray_reg
        numProducts.numberOfLines = 2
        self.addSubview(numProducts)
        
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        
        ivaTitle.text = NSLocalizedString("shoppingcart.iva",comment:"")
        totalTitle.text = NSLocalizedString("shoppingcart.total",comment:"")
        savingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subtotalTitle.frame = CGRectMake(146, self.subtotalY,subtotalTitle.frame.size.width , 12)
        valueSubtotal.frame = CGRectMake(subtotalTitle.frame.maxX + 8, subtotalTitle.frame.minY, 50, 12)
        if self.firstTotal {
            valueTotal.frame = CGRectMake(self.frame.width - (valueTotal.frame.size.width + 16), subtotalTitle.frame.maxY + 4.0 , valueTotal.frame.size.width, valueTotal.frame.size.height)
            totalTitle.frame = CGRectMake(valueTotal.frame.minX - (totalTitle.frame.size.width + 8) ,subtotalTitle.frame.maxY + 4.0, totalTitle.frame.size.width, totalTitle.frame.size.height)
            valueTotalSaving.frame = CGRectMake(self.frame.width - 66,  totalTitle.frame.maxY + 4.0 , 50, 12)
            savingTitle.frame = CGRectMake(valueTotalSaving.frame.minX - 109 , totalTitle.frame.maxY + 4.0 , 101, 12)
        }else{
            self.valueTotalSaving.frame = CGRectMake(self.frame.width - 66,  self.subtotalTitle.frame.maxY + 4.0 , 50, 12)
            self.savingTitle.frame = CGRectMake(self.valueTotalSaving.frame.minX - 109 , self.subtotalTitle.frame.maxY + 4.0 , 101, 12)
            self.valueTotal.frame = CGRectMake(self.frame.width - (self.valueTotal.frame.size.width + 16), self.savingTitle.frame.maxY + 4.0 , self.valueTotal.frame.size.width, self.valueTotal.frame.size.height)
            self.totalTitle.frame = CGRectMake(valueTotal.frame.minX - (self.totalTitle.frame.size.width + 8) ,self.savingTitle.frame.maxY + 4.0, self.totalTitle.frame.size.width, self.totalTitle.frame.size.height)
        }
        
    }
    
    
    func setValues(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        //super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        super.setValuesAll(articles: numProds, subtotal: subtotal, shippingCost: "", iva: iva, saving: totalSaving, total: total)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.totalTitle.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesWithSubtotal(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        //super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        super.setValuesAll(articles: numProds, subtotal: subtotal, shippingCost: "", iva: iva, saving: totalSaving, total: total)
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        self.valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray_reg, interLine: false)
        self.firstTotal = false
        self.subtotalY = savingTitle.hidden ? 0.0 : 18.0
        self.subtotalTitle.hidden = savingTitle.hidden
        self.valueSubtotal.hidden = savingTitle.hidden
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.totalTitle.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesBTS(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        self.valueTotal.frame = CGRectMake(self.frame.width - (self.valueTotal.frame.size.width + 16), 16 , self.valueTotal.frame.size.width, self.valueTotal.frame.size.height)
        self.totalTitle.frame = CGRectMake(valueTotal.frame.minX - (self.totalTitle.frame.size.width + 8) , 16, self.totalTitle.frame.size.width, self.totalTitle.frame.size.height)
        //super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        super.setValuesAll(articles: numProds, subtotal: subtotal, shippingCost: "", iva: iva, saving: totalSaving, total: total)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.totalTitle.textColor = WMColor.orange
        if numProds != "" {
            numProducts.frame =  CGRectMake(16, 25, 100, 28)
            numProducts.textAlignment = .Left
            numProducts.text = "\(numProds) \(articles) \nseleccionados"
        }
    }
    
    
}