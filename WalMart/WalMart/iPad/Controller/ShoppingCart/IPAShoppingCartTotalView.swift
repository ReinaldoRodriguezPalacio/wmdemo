//
//  IPAShoppingCartTotalView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAShoppingCartTotalView : UIView {
    
    var subtotalTitle : UILabel!
    var iva : UILabel!
    var total : UILabel!
    var totalSavingTitle : UILabel!
    
    var valueSubtotal : CurrencyCustomLabel!
    var valueIva : CurrencyCustomLabel!
    var valueTotal : CurrencyCustomLabel!
    var valueTotalSaving : CurrencyCustomLabel!

    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = WMColor.light_light_gray
        
        let xPoint : CGFloat = 100
        
        subtotalTitle = UILabel()
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle.textColor = WMColor.gray
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(18)
        subtotalTitle.textAlignment = .Right
        subtotalTitle.frame = CGRectMake(xPoint, 24, 120, 18)
        iva = UILabel()
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        iva.textColor = WMColor.gray
        iva.font = WMFont.fontMyriadProSemiboldOfSize(18)
        iva.textAlignment = .Right
        iva.frame = CGRectMake(xPoint, subtotalTitle.frame.maxY + 16, 120, 18)
        total = UILabel()
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        total.textColor = WMColor.gray
        total.font = WMFont.fontMyriadProSemiboldOfSize(18)
        total.textAlignment = .Right
        total.frame = CGRectMake(xPoint, iva.frame.maxY + 40, 120, 18)
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        totalSavingTitle.textColor =  WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(18)
        totalSavingTitle.textAlignment = .Right
        totalSavingTitle.frame = CGRectMake(xPoint, iva.frame.maxY + 13, 120, 18)
        
        valueSubtotal = CurrencyCustomLabel(frame: CGRectMake(subtotalTitle.frame.maxX + 16, subtotalTitle.frame.minY, 90, 18))
        valueSubtotal.textAlignment = .Right
        valueIva = CurrencyCustomLabel(frame: CGRectMake(iva.frame.maxX + 16, iva.frame.minY, 90, 18))
        valueIva.textAlignment = .Right
        valueTotal = CurrencyCustomLabel(frame: CGRectMake(total.frame.maxX + 16, total.frame.minY, 90, 18))
        valueTotal.textAlignment = .Right
        valueTotalSaving = CurrencyCustomLabel(frame: CGRectMake(totalSavingTitle.frame.maxX + 16, totalSavingTitle.frame.minY, 90, 18))
        valueTotalSaving.textAlignment = .Right
        //valueTotalSaving.backgroundColor = UIColor.blueColor()

        
        
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
            valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.gray, interLine: false)
            valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.gray, interLine: false)
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
        let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.gray, interLine: false)
        
        var convertSaving = totalSaving
        if convertSaving == "" {
            convertSaving = "0.0"
        }
        let dNumberSaving = NSString(string: totalSaving).doubleValue
        
            if dNumberSaving > 0.1 {
                totalSavingTitle.hidden = false
                valueTotalSaving.hidden = false
                valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(18), color:  WMColor.green, interLine: false)
                
            }else {
                totalSavingTitle.hidden = true
                valueTotalSaving.hidden = true
            }
        
    }

    
    
}