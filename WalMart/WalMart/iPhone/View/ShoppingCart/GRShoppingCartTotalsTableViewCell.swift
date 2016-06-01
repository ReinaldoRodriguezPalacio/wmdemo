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
        valueTotal.frame = CGRectMake(self.frame.width - (valueTotal.frame.size.width + 16), 25 , valueTotal.frame.size.width, valueTotal.frame.size.height)
        total.frame = CGRectMake(valueTotal.frame.minX - (total.frame.size.width + 8) , 25, total.frame.size.width, total.frame.size.height)
        valueTotalSaving.frame = CGRectMake(self.frame.width - 66,  totalSavingTitle.frame.minY , 50, 12)
        totalSavingTitle.frame = CGRectMake(valueTotalSaving.frame.minX - 109 , total.frame.maxY + 4.0 , 101, 12)
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
    
    func setValuesBTS(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles) \n seleccionados"
        }
    }
    
    
}