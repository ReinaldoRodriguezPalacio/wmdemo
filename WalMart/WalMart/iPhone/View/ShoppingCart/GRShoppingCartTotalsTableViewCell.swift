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
        numProducts.textColor = WMColor.reg_gray
        numProducts.numberOfLines = 2
        self.addSubview(numProducts)
        
        subtotalTitle!.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        
        ivaTitle!.text = NSLocalizedString("shoppingcart.iva",comment:"")
        totalTitle!.text = NSLocalizedString("shoppingcart.total",comment:"")
        savingTitle!.text = NSLocalizedString("shoppingcart.saving",comment:"")
    }
    
    override func layoutSubviews() {
        subtotalTitle!.frame = CGRect(x: 146, y: self.subtotalY,width: subtotalTitle!.frame.size.width , height: 12)
        valueSubtotal!.frame = CGRect(x: subtotalTitle!.frame.maxX + 8, y: subtotalTitle!.frame.minY, width: 50, height: 12)
        if self.firstTotal {
            valueTotal!.frame = CGRect(x: self.frame.width - (valueTotal!.frame.size.width + 16), y: subtotalTitle!.frame.maxY + 4.0 , width: valueTotal!.frame.size.width, height: valueTotal!.frame.size.height)
            totalTitle!.frame = CGRect(x: valueTotal!.frame.minX - (totalTitle!.frame.size.width + 8) ,y: subtotalTitle!.frame.maxY + 4.0, width: totalTitle!.frame.size.width, height: totalTitle!.frame.size.height)
            valueTotalSaving!.frame = CGRect(x: self.frame.width - 66,  y: totalTitle!.frame.maxY + 4.0 , width: 50, height: 12)
            savingTitle!.frame = CGRect(x: valueTotalSaving!.frame.minX - 109 , y: totalTitle!.frame.maxY + 4.0 , width: 101, height: 12)
        }else{
            self.valueTotalSaving!.frame = CGRect(x: self.frame.width - 66,  y: self.subtotalTitle!.frame.maxY + 4.0 , width: 50, height: 12)
            self.savingTitle!.frame = CGRect(x: self.valueTotalSaving!.frame.minX - 109 , y: self.subtotalTitle!.frame.maxY + 4.0 , width: 101, height: 12)
            self.valueTotal!.frame = CGRect(x: self.frame.width - (self.valueTotal!.frame.size.width + 16), y: self.savingTitle!.frame.maxY + 4.0 , width: self.valueTotal!.frame.size.width, height: self.valueTotal!.frame.size.height)
            self.totalTitle!.frame = CGRect(x: valueTotal!.frame.minX - (self.totalTitle!.frame.size.width + 8) ,y: self.savingTitle!.frame.maxY + 4.0, width: self.totalTitle!.frame.size.width, height: self.totalTitle!.frame.size.height)
        }
        
    }
    
    
    func setValues(_ subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        //super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        super.setValuesAll(articles: numProds, subtotal: subtotal, shippingCost: "", iva: iva, saving: totalSaving, total: total)
        self.valueTotal!.label1?.textColor = WMColor.orange
        self.valueTotal!.label2?.textColor = WMColor.orange
        self.totalTitle!.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesWithSubtotal(_ subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        //super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        super.setValuesAll(articles: numProds, subtotal: subtotal, shippingCost: "", iva: iva, saving: totalSaving, total: total)
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        self.valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.reg_gray, interLine: false)
        self.firstTotal = false
        self.subtotalY = savingTitle!.isHidden ? 0.0 : 18.0
        self.subtotalTitle!.isHidden = savingTitle!.isHidden
        self.valueSubtotal!.isHidden = savingTitle!.isHidden
        self.valueTotal!.label1?.textColor = WMColor.orange
        self.valueTotal!.label2?.textColor = WMColor.orange
        self.totalTitle!.textColor = WMColor.orange
        if numProds != "" {
            numProducts.text = "\(numProds) \(articles)"
        }
    }
    
    func setValuesBTS(_ subtotal: String, iva: String, total: String, totalSaving: String,numProds:String) {
        let articles = NSLocalizedString("shoppingcart.articles",comment: "")
        self.valueTotal!.frame = CGRect(x: self.frame.width - (self.valueTotal!.frame.size.width + 16), y: 16 , width: self.valueTotal!.frame.size.width, height: self.valueTotal!.frame.size.height)
        self.totalTitle!.frame = CGRect(x: valueTotal!.frame.minX - (self.totalTitle!.frame.size.width + 8) , y: 16, width: self.totalTitle!.frame.size.width, height: self.totalTitle!.frame.size.height)
        //super.setValues(subtotal, iva: iva, total: total, totalSaving: totalSaving)
        super.setValuesAll(articles: numProds, subtotal: subtotal, shippingCost: "", iva: iva, saving: totalSaving, total: total)
        self.valueTotal!.label1?.textColor = WMColor.orange
        self.valueTotal!.label2?.textColor = WMColor.orange
        self.totalTitle!.textColor = WMColor.orange
        if numProds != "" {
            numProducts.frame =  CGRect(x: 16, y: 25, width: 100, height: 28)
            numProducts.textAlignment = .left
            numProducts.text = "\(numProds) \(articles) \nseleccionados"
        }
    }
    
    
}
