//
//  ShoppingCartTotalsTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShoppingCartTotalsTableViewCell : UITableViewCell {
    
    var subtotalTitle : UILabel!
    var iva : UILabel!
    var total : UILabel!
    var totalSavingTitle : UILabel!
    
    var valueSubtotal : CurrencyCustomLabel!
    var valueIva : CurrencyCustomLabel!
    var valueTotal : CurrencyCustomLabel!
    var valueTotalSaving : CurrencyCustomLabel!
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        backgroundColor = WMColor.light_light_gray
        

        
        subtotalTitle = UILabel()
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle.textColor = WMColor.gray
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(12)
        subtotalTitle.textAlignment = .Right
        subtotalTitle.frame = CGRectMake(146, 18, 101, 12)
        
        iva = UILabel()
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        iva.textColor = WMColor.gray
        iva.font = WMFont.fontMyriadProSemiboldOfSize(12)
        iva.textAlignment = .Right
        iva.frame = CGRectMake(146, subtotalTitle.frame.maxY + 6, 101, 12)
        
        total = UILabel()
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        total.textColor = WMColor.gray
        total.font = WMFont.fontMyriadProSemiboldOfSize(12)
        total.textAlignment = .Right
        total.frame = CGRectMake(146, iva.frame.maxY + 20, 101, 12)
        
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        totalSavingTitle.textColor =  WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(12)
        totalSavingTitle.textAlignment = .Right
        totalSavingTitle.frame = CGRectMake(146, iva.frame.maxY + 3, 101, 12)
        
        valueSubtotal = CurrencyCustomLabel(frame: CGRectMake(subtotalTitle.frame.maxX + 8, subtotalTitle.frame.minY, 50, 12))
        valueSubtotal.textAlignment = .Right
        valueIva = CurrencyCustomLabel(frame: CGRectMake(iva.frame.maxX + 8, iva.frame.minY, 50, 12))
        valueIva.textAlignment = .Right
        valueTotal = CurrencyCustomLabel(frame: CGRectMake(total.frame.maxX + 8, total.frame.minY, 50, 12))
        valueTotal.textAlignment = .Right
        valueTotalSaving = CurrencyCustomLabel(frame: CGRectMake(iva.frame.maxX + 8, totalSavingTitle.frame.minY, 50, 12))
        valueTotalSaving.textAlignment = .Right

        
        self.addSubview(subtotalTitle)
        self.addSubview(iva)
        self.addSubview(total)
        self.addSubview(totalSavingTitle)
        
        
        self.addSubview(valueSubtotal)
        self.addSubview(valueIva)
        self.addSubview(valueTotal)
        self.addSubview(valueTotalSaving)
        
        
    }
    
    func setValues(subtotal: String,iva: String,total: String,totalSaving:String){
        
        if iva != "" {
            let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
            let formatedIVA = CurrencyCustomLabel.formatString(iva)
            valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
            valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
            self.valueSubtotal.hidden = false
            self.valueIva.hidden = false
            self.subtotalTitle.hidden = false
            self.iva.hidden = false
            
        }else{
            self.valueSubtotal.hidden = true
            self.valueIva.hidden = true
            self.subtotalTitle.hidden = true
            self.iva.hidden = true
        }
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
        
        let totSaving = totalSaving as NSString
        if totSaving.doubleValue > 0 {
            let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving)
            valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(12), color:  WMColor.green, interLine: false)
            
            totalSavingTitle.hidden = false
            valueTotalSaving.hidden = false
        }else{
            totalSavingTitle.hidden = true
            valueTotalSaving.hidden = true
        }
        
        
        
    }
    
}