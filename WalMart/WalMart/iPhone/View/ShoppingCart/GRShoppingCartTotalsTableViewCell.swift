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
        numProducts.textColor = WMColor.gray
        numProducts.numberOfLines = 2
        self.addSubview(numProducts)
        
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subtotalTitle.frame = CGRectMake(146, self.subtotalY,subtotalTitle.frame.size.width , 12)
        valueSubtotal.frame = CGRectMake(subtotalTitle.frame.maxX + 8, subtotalTitle.frame.minY, 50, 12)
        if self.firstTotal {
            total.frame = CGRectMake(valueTotal.frame.minX - (total.frame.size.width + 8) ,subtotalTitle.frame.maxY + 4.0, total.frame.size.width, total.frame.size.height)
            valueTotal.frame = CGRectMake(self.frame.width - (valueTotal.frame.size.width + 16), total.frame.minY , valueTotal.frame.size.width, valueTotal.frame.size.height)
            valueTotalSaving.frame = CGRectMake(self.frame.width - 66,  totalSavingTitle.frame.minY , 50, 12)
            totalSavingTitle.frame = CGRectMake(valueTotalSaving.frame.minX - 109 , total.frame.maxY + 4.0 , 101, 12)
        }else{
            self.totalSavingTitle.frame = CGRectMake(self.valueTotalSaving.frame.minX - 109 , self.subtotalTitle.frame.maxY + 4.0 , 101, 12)
            self.valueTotalSaving.frame = CGRectMake(self.frame.width - 66,  self.totalSavingTitle.frame.minY , 50, 12)
            self.total.frame = CGRectMake(valueTotal.frame.minX - (self.total.frame.size.width + 8) ,self.totalSavingTitle.frame.maxY + 4.0, self.total.frame.size.width, self.total.frame.size.height)
            self.valueTotal.frame = CGRectMake(self.frame.width - (self.valueTotal.frame.size.width + 16), self.total.frame.minY , self.valueTotal.frame.size.width, self.valueTotal.frame.size.height)
        }
        
    }
    
    
    func setValues(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesWithSubtotal(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        self.valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
        self.firstTotal = false
        self.subtotalY = totalSavingTitle.hidden ? 0.0 : 18.0
        self.subtotalTitle.hidden = totalSavingTitle.hidden
        self.valueSubtotal.hidden = totalSavingTitle.hidden
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesBTS(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        self.valueTotal.frame = CGRectMake(self.frame.width - (self.valueTotal.frame.size.width + 16), 16 , self.valueTotal.frame.size.width, self.valueTotal.frame.size.height)
        self.total.frame = CGRectMake(valueTotal.frame.minX - (self.total.frame.size.width + 8) , 16, self.total.frame.size.width, self.total.frame.size.height)
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.frame =  CGRectMake(16, 25, 100, 28)
            numProducts.textAlignment = .Left
            numProducts.text = "\(numProds) \(articles) \nseleccionados"
        }
    }
    
    
}