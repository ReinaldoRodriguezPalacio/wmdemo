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
        
        let margin: CGFloat = 16
        let titlesWidth: CGFloat = 100
        let valueMaxWidth: CGFloat = valueTotal!.label1!.frame.width + valueTotal!.label2!.frame.width
        let startX: CGFloat = bounds.width - valueMaxWidth - titlesWidth - (margin * 2)
        
        subtotalTitle!.frame = CGRect(x: startX, y: margin, width: titlesWidth, height: labelSize)
        iva!.frame = CGRect(x: startX, y: subtotalTitle!.frame.maxY + 6, width: titlesWidth, height: labelSize)
        totalSavingTitle!.frame = CGRect(x: startX, y: iva!.frame.maxY + 6, width: titlesWidth, height: labelSize)
        total!.frame = CGRect(x: startX, y: totalSavingTitle!.frame.maxY + 6, width: titlesWidth, height: labelSize)
        
        // values
        valueSubtotal!.frame = CGRect(x: subtotalTitle!.frame.maxX + 8, y: subtotalTitle!.frame.minY, width: valueMaxWidth, height: labelSize)
        valueIva!.frame = CGRect(x: iva!.frame.maxX + 8, y: iva!.frame.minY, width: valueMaxWidth, height: labelSize)
        valueTotalSaving!.frame = CGRect(x: totalSavingTitle!.frame.maxX + 8, y: totalSavingTitle!.frame.minY, width: valueMaxWidth, height: labelSize)
        valueTotal!.frame = CGRect(x: total!.frame.maxX + 8, y: total!.frame.minY, width: valueMaxWidth, height: labelSize)
        
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
