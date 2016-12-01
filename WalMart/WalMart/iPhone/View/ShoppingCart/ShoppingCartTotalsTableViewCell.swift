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
        self.selectionStyle = .none
        backgroundColor = WMColor.light_light_gray
        

        
        subtotalTitle = UILabel()
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle.textColor = WMColor.gray
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(12)
        subtotalTitle.textAlignment = .right
        subtotalTitle.frame = CGRect(x: 146, y: 18, width: 101, height: 12)
        
        iva = UILabel()
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        iva.textColor = WMColor.gray
        iva.font = WMFont.fontMyriadProSemiboldOfSize(12)
        iva.textAlignment = .right
        iva.frame = CGRect(x: 146, y: subtotalTitle.frame.maxY + 6, width: 101, height: 12)
        
        total = UILabel()
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        total.textColor = WMColor.gray
        total.font = WMFont.fontMyriadProSemiboldOfSize(12)
        total.textAlignment = .right
        total.frame = CGRect(x: 146, y: iva.frame.maxY + 20, width: 101, height: 12)
        
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        totalSavingTitle.textColor =  WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(12)
        totalSavingTitle.textAlignment = .right
        totalSavingTitle.frame = CGRect(x: 146, y: iva.frame.maxY + 3, width: 101, height: 12)
        
        valueSubtotal = CurrencyCustomLabel(frame: CGRect(x: subtotalTitle.frame.maxX + 8, y: subtotalTitle.frame.minY, width: 50, height: 12))
        valueSubtotal.textAlignment = .right
        valueIva = CurrencyCustomLabel(frame: CGRect(x: iva.frame.maxX + 8, y: iva.frame.minY, width: 50, height: 12))
        valueIva.textAlignment = .right
        valueTotal = CurrencyCustomLabel(frame: CGRect(x: total.frame.maxX + 8, y: total.frame.minY, width: 50, height: 12))
        valueTotal.textAlignment = .right
        valueTotalSaving = CurrencyCustomLabel(frame: CGRect(x: iva.frame.maxX + 8, y: totalSavingTitle.frame.minY, width: 50, height: 12))
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
    
    func setValues(_ subtotal: String,iva: String,total: String,totalSaving:String){
        
        if iva != "" {
            let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
            let formatedIVA = CurrencyCustomLabel.formatString(iva as NSString)
            valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
            valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
            self.valueSubtotal.isHidden = false
            self.valueIva.isHidden = false
            self.subtotalTitle.isHidden = false
            self.iva.isHidden = false
            
        }else{
            self.valueSubtotal.isHidden = true
            self.valueIva.isHidden = true
            self.subtotalTitle.isHidden = true
            self.iva.isHidden = true
        }
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(12), color: WMColor.gray, interLine: false)
        
        let totSaving = totalSaving as NSString
        if totSaving.doubleValue > 0 {
            let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving as NSString)
            valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(12), color:  WMColor.green, interLine: false)
            
            totalSavingTitle.isHidden = false
            valueTotalSaving.isHidden = false
        }else{
            totalSavingTitle.isHidden = true
            valueTotalSaving.isHidden = true
        }
        
        
        
    }
    
}
