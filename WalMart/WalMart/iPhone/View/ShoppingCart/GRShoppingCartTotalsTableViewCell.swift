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
        
        numProducts = UILabel(frame: CGRect(x: 16, y: 25, width: 75, height: 14))
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
        
        subtotalTitle.frame = CGRect(x: valueTotalSaving.frame.minX - subtotalTitle.frame.size.width - 8, y: self.subtotalY, width: subtotalTitle.frame.size.width , height: 12)
        valueSubtotal.frame = CGRect(x: subtotalTitle.frame.maxX + 8, y: subtotalTitle.frame.minY, width: 50, height: 12)
        
        if self.firstTotal {
            valueTotal.frame = CGRect(x: self.frame.width - (valueTotal.frame.size.width + 16), y: subtotalTitle.frame.maxY + 4.0 , width: valueTotal.frame.size.width, height: valueTotal.frame.size.height)
            total.frame = CGRect(x: valueTotal.frame.minX - (total.frame.size.width + 8) ,y: subtotalTitle.frame.maxY + 4.0, width: total.frame.size.width, height: total.frame.size.height)
            valueTotalSaving.frame = CGRect(x: self.frame.width - 66,  y: total.frame.maxY + 4.0 , width: 50, height: 12)
            totalSavingTitle.frame = CGRect(x: valueTotalSaving.frame.minX - 109 , y: total.frame.maxY + 4.0 , width: 101, height: 12)
        }else{
            self.valueTotalSaving.frame = CGRect(x: self.frame.width - 66,  y: self.subtotalTitle.frame.maxY + 4.0 , width: 50, height: 12)
            self.totalSavingTitle.frame = CGRect(x: self.valueTotalSaving.frame.minX - 109 , y: self.subtotalTitle.frame.maxY + 4.0 , width: 101, height: 12)
            self.valueTotal.frame = CGRect(x: self.frame.width - (self.valueTotal.frame.size.width + 16), y: self.totalSavingTitle.frame.maxY + 4.0 , width: self.valueTotal.frame.size.width, height: self.valueTotal.frame.size.height)
            self.total.frame = CGRect(x: valueTotal.frame.minX - (self.total.frame.size.width + 8) ,y: self.totalSavingTitle.frame.maxY + 4.0, width: self.total.frame.size.width, height: self.total.frame.size.height)
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
