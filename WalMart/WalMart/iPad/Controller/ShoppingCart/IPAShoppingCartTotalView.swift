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
        subtotalTitle.textColor = WMColor.reg_gray
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(18)
        subtotalTitle.textAlignment = .right
        subtotalTitle.frame = CGRect(x: xPoint, y: 24, width: 120, height: 18)
        iva = UILabel()
        iva.text = NSLocalizedString("shoppingcart.iva",comment:"")
        iva.textColor = WMColor.reg_gray
        iva.font = WMFont.fontMyriadProSemiboldOfSize(18)
        iva.textAlignment = .right
        iva.frame = CGRect(x: xPoint, y: subtotalTitle.frame.maxY + 16, width: 120, height: 18)
        total = UILabel()
        total.text = NSLocalizedString("shoppingcart.total",comment:"")
        total.textColor = WMColor.reg_gray
        total.font = WMFont.fontMyriadProSemiboldOfSize(18)
        total.textAlignment = .right
        total.frame = CGRect(x: xPoint, y: iva.frame.maxY + 40, width: 120, height: 18)
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("shoppingcart.saving",comment:"")
        totalSavingTitle.textColor =  WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(18)
        totalSavingTitle.textAlignment = .right
        totalSavingTitle.frame = CGRect(x: xPoint, y: iva.frame.maxY + 13, width: 120, height: 18)
        
        valueSubtotal = CurrencyCustomLabel(frame: CGRect(x: subtotalTitle.frame.maxX + 16, y: subtotalTitle.frame.minY, width: 90, height: 18))
        valueSubtotal.textAlignment = .right
        valueIva = CurrencyCustomLabel(frame: CGRect(x: iva.frame.maxX + 16, y: iva.frame.minY, width: 90, height: 18))
        valueIva.textAlignment = .right
        valueTotal = CurrencyCustomLabel(frame: CGRect(x: total.frame.maxX + 16, y: total.frame.minY, width: 90, height: 18))
        valueTotal.textAlignment = .right
        valueTotalSaving = CurrencyCustomLabel(frame: CGRect(x: totalSavingTitle.frame.maxX + 16, y: totalSavingTitle.frame.minY, width: 90, height: 18))
        valueTotalSaving.textAlignment = .right
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
    
    override func layoutSubviews() {
        let xPoint : CGFloat = 100
        subtotalTitle.frame = CGRect(x: xPoint, y: 24, width: 120, height: 18)
        iva.frame = CGRect(x: xPoint, y: subtotalTitle.frame.maxY + 16, width: 120, height: 18)
        total.frame = CGRect(x: xPoint, y: iva.frame.maxY + 40, width: 120, height: 18)
        totalSavingTitle.frame = CGRect(x: xPoint, y: iva.frame.maxY + 13, width: 120, height: 18)
        
        valueSubtotal.frame = CGRect(x: subtotalTitle.frame.maxX + 16, y: subtotalTitle.frame.minY, width: 90, height: 18)
        valueIva.frame = CGRect(x: iva.frame.maxX + 16, y: iva.frame.minY, width: 90, height: 18)
        valueTotal.frame = CGRect(x: total.frame.maxX + 16, y: total.frame.minY, width: 90, height: 18)
        valueTotalSaving.frame = CGRect(x: totalSavingTitle.frame.maxX + 16, y: totalSavingTitle.frame.minY, width: 90, height: 18)
    }
    
    
    
    func setValues(_ subtotal: String,iva: String,total: String,totalSaving:String){
        if iva != "" {
            let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
            let formatedIVA = CurrencyCustomLabel.formatString(iva as NSString)
            valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.reg_gray, interLine: false)
            valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.reg_gray, interLine: false)
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
        let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving as NSString)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.reg_gray, interLine: false)
        
        var convertSaving = totalSaving
        if convertSaving == "" {
            convertSaving = "0.0"
        }
        let dNumberSaving = NSString(string: totalSaving).doubleValue
        
            if dNumberSaving > 0.1 {
                totalSavingTitle.isHidden = false
                valueTotalSaving.isHidden = false
                valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(18), color:  WMColor.green, interLine: false)
                
            }else {
                totalSavingTitle.isHidden = true
                valueTotalSaving.isHidden = true
            }
        
    }

    
    
}
