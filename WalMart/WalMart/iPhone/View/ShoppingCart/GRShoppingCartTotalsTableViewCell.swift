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
        self.addSubview(numProducts)
        
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        total.textAlignment = .Right
        valueTotal.textAlignment = .Right
        totalSavingTitle.textAlignment = .Right
        valueTotalSaving.textAlignment = .Right
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        total.frame = CGRectMake(total.frame.origin.x , 25, total.frame.size.width, total.frame.size.height)
        valueTotal.frame = CGRectMake(valueTotal.frame.origin.x, 25 , valueTotal.frame.size.width, valueTotal.frame.size.height)
        totalSavingTitle.frame = CGRectMake(totalSavingTitle.frame.origin.x, total.frame.maxY + 4.0 , 101, 12)
        valueTotalSaving.frame = CGRectMake(totalSavingTitle.frame.maxX + 8,  totalSavingTitle.frame.minY , 50, 12)

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
    
}