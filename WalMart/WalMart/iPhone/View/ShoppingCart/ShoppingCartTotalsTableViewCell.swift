//
//  ShoppingCartTotalsTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShoppingCartTotalsTableViewCell : UITableViewCell {
    
    let labelSize: CGFloat = 14
    
    var subtotalTitle: UILabel!
    var iva : UILabel!
    var total : UILabel!
    var totalSavingTitle: UILabel!
    var valueSubtotal: CurrencyCustomLabel!
    var valueIva: CurrencyCustomLabel!
    var valueTotal: CurrencyCustomLabel!
    var valueTotalSaving: CurrencyCustomLabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        
        let titleWidth: CGFloat = 101
        let valueWidth: CGFloat = 50
        let xPosition: CGFloat = frame.width - titleWidth - valueWidth - 28
        let labelHeight: CGFloat = 14
        
        subtotalTitle.frame = CGRect(x: xPosition, y: 18, width: titleWidth, height: labelHeight)
        iva.frame = CGRect(x: xPosition, y: subtotalTitle.frame.maxY + 6, width: titleWidth, height: labelHeight)
        total.frame = CGRect(x: xPosition, y: iva.frame.maxY + 20, width: titleWidth, height: labelHeight)
        totalSavingTitle.frame = CGRect(x: xPosition, y: iva.frame.maxY + 3, width: titleWidth, height: labelHeight)
        
        valueSubtotal.frame = CGRect(x: subtotalTitle.frame.maxX + 12, y: subtotalTitle.frame.minY, width: valueWidth, height: labelHeight)
        valueIva.frame = CGRect(x: iva.frame.maxX + 12, y: iva.frame.minY, width: valueWidth, height: labelHeight)
        valueTotal.frame = CGRect(x: total.frame.maxX + 12, y: total.frame.minY, width: valueWidth, height: labelHeight)
        valueTotalSaving.frame = CGRect(x: iva.frame.maxX + 12, y: totalSavingTitle.frame.minY, width: valueWidth, height: labelHeight)
        
    }
    
    func setup() {
        self.selectionStyle = .none
        backgroundColor = WMColor.light_light_gray
        
        subtotalTitle = UILabel()
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle.textColor = WMColor.gray
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(labelSize)
        subtotalTitle.textAlignment = .right
        
        iva = UILabel()
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        iva.textColor = WMColor.gray
        iva.font = WMFont.fontMyriadProSemiboldOfSize(labelSize)
        iva.textAlignment = .right
        
        total = UILabel()
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        total.textColor = WMColor.gray
        total.font = WMFont.fontMyriadProSemiboldOfSize(labelSize)
        total.textAlignment = .right
        
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        totalSavingTitle.textColor = WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(labelSize)
        totalSavingTitle.textAlignment = .right
        
        valueSubtotal = CurrencyCustomLabel()
        valueIva = CurrencyCustomLabel()
        valueTotal = CurrencyCustomLabel()
        valueTotalSaving = CurrencyCustomLabel()
        
        valueSubtotal.textAlignment = .right
        valueIva.textAlignment = .right
        valueTotal.textAlignment = .right
        valueTotalSaving.textAlignment = .right
        
        self.addSubview(subtotalTitle)
        self.addSubview(iva)
        self.addSubview(total)
        self.addSubview(totalSavingTitle)
        self.addSubview(valueSubtotal)
        self.addSubview(valueIva)
        self.addSubview(valueTotal)
        self.addSubview(valueTotalSaving)
        
    }
    
    func setValues(_ subtotal: String, iva: String, total: String, totalSaving: String) {
        
        if iva != "" {
            let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
            let formatedIVA = CurrencyCustomLabel.formatString(iva as NSString)
            valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(labelSize), color: WMColor.gray, interLine: false)
            valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(labelSize), color: WMColor.gray, interLine: false)
            self.valueSubtotal.isHidden = false
            self.valueIva.isHidden = false
            self.subtotalTitle.isHidden = false
            self.iva.isHidden = false
            
        } else {
            self.valueSubtotal.isHidden = true
            self.valueIva.isHidden = true
            self.subtotalTitle.isHidden = true
            self.iva.isHidden = true
        }
       
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(labelSize), color: WMColor.gray, interLine: false)
        
        let totSaving = totalSaving as NSString
        
        if totSaving.doubleValue > 0 {
            let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving as NSString)
            valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(labelSize), color:  WMColor.green, interLine: false)
            
            totalSavingTitle.isHidden = false
            valueTotalSaving.isHidden = false
        } else {
            totalSavingTitle.isHidden = true
            valueTotalSaving.isHidden = true
        }
        
    }
    
}
