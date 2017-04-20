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
        
        numProducts = UILabel(frame: CGRect(x: 16, y: 16, width: 75, height: labelSize))
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
        
        let margin: CGFloat = 16
        let titlesWidth: CGFloat = 100
        let valueMaxWidth: CGFloat = valueTotal!.label1!.frame.width + valueTotal!.label2!.frame.width
        let startX: CGFloat = bounds.width - valueMaxWidth - titlesWidth - (margin * 2)
        
        subtotalTitle!.frame = CGRect(x: startX, y: margin, width: titlesWidth, height: labelSize)
        totalSavingTitle!.frame = CGRect(x: startX, y: subtotalTitle!.frame.maxY + 6, width: titlesWidth, height: labelSize)
        total!.frame = CGRect(x: startX, y: totalSavingTitle!.frame.maxY + 6, width: titlesWidth, height: labelSize)
        
        valueSubtotal!.frame = CGRect(x: subtotalTitle!.frame.maxX + 8, y: subtotalTitle!.frame.minY, width: valueMaxWidth, height: labelSize)
        valueTotalSaving!.frame = CGRect(x: totalSavingTitle!.frame.maxX + 8, y: totalSavingTitle!.frame.minY, width: valueMaxWidth, height: labelSize)
        valueTotal!.frame = CGRect(x: total!.frame.maxX + 8, y: total!.frame.minY, width: valueMaxWidth, height: labelSize)
        
        if totalSavingTitle.isHidden {
            total!.frame = CGRect(x: startX, y: margin, width: titlesWidth, height: labelSize)
            valueTotal!.frame = CGRect(x: subtotalTitle!.frame.maxX + 8, y: subtotalTitle!.frame.minY, width: valueMaxWidth, height: labelSize)
        }
        
    }
    
    
    func setValues(_ subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesWithSubtotal(_ subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
        self.valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.gray, interLine: false)
        self.firstTotal = false
        self.subtotalY = totalSavingTitle.isHidden ? 0.0 : 18.0
        self.subtotalTitle.isHidden = totalSavingTitle.isHidden
        self.valueSubtotal.isHidden = totalSavingTitle.isHidden
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesBTS(_ subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        self.valueTotal.frame = CGRect(x: self.frame.width - (self.valueTotal.frame.size.width + 16), y: 16 , width: self.valueTotal.frame.size.width, height: self.valueTotal.frame.size.height)
        self.total.frame = CGRect(x: valueTotal.frame.minX - (self.total.frame.size.width + 8) , y: 16, width: self.total.frame.size.width, height: self.total.frame.size.height)
        super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        self.valueTotal.label1?.textColor = WMColor.orange
        self.valueTotal.label2?.textColor = WMColor.orange
        self.total.textColor = WMColor.orange
        if numProds != "" {
            numProducts.frame =  CGRect(x: 16, y: 25, width: 100, height: 28)
            numProducts.textAlignment = .left
            numProducts.text = "\(numProds) \(articles) \nseleccionados"
        }
    }
    
    
}
