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
        numProducts.textColor = WMColor.shoppingCartShopTotalsTextColor
        self.addSubview(numProducts)
        
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        total.frame = CGRectMake(156, 25, 91, 12)
        valueTotal.frame = CGRectMake(total.frame.maxX + 3, 25 , 50, 12)
        
        totalSavingTitle.frame = CGRectMake(156, total.frame.maxY + 4.0 , 91, 12)
        valueTotalSaving.frame = CGRectMake(totalSavingTitle.frame.maxX + 3,  totalSavingTitle.frame.minY , 50, 12)
        
    }
    
    
    func setValues(subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
}