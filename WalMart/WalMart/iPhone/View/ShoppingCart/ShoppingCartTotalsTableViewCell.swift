//
//  ShoppingCartTotalsTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShoppingCartTotalsTableViewCell : UITableViewCell {
    
    var subtotalTitle : UILabel?
    var shippingCostTitle : UILabel?
    var ivaTitle : UILabel?
    var savingTitle : UILabel?
    var totalTitle : UILabel?
    var articlesTitle : UILabel!?
    
    var valueSubtotal : CurrencyCustomLabel?
    var valueShippingCost : CurrencyCustomLabel?
    var valueIva : CurrencyCustomLabel?
    var valueTotalSaving : CurrencyCustomLabel?
    var valueTotal : CurrencyCustomLabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.selectionStyle = .None
        self.backgroundColor =  WMColor.light_light_gray
        
        articlesTitle = UILabel()
        articlesTitle!.text = NSLocalizedString("articulos",comment:"")
        articlesTitle!.textColor = WMColor.reg_gray
        articlesTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        articlesTitle!.textAlignment = .Left
        articlesTitle!.frame = CGRectMake(16, 16, 101, 14)
        
        subtotalTitle = UILabel()
        subtotalTitle!.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle!.textColor = WMColor.reg_gray
        subtotalTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        subtotalTitle!.textAlignment = .Right
        subtotalTitle!.frame = CGRectMake(146, 16, 101, 14)
        
        shippingCostTitle = UILabel()
        shippingCostTitle!.text = NSLocalizedString("Costo envío",comment:"")
        shippingCostTitle!.textColor = WMColor.reg_gray
        shippingCostTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        shippingCostTitle!.textAlignment = .Right
        shippingCostTitle!.frame = CGRectMake(146, subtotalTitle!.frame.maxY + 6, 101, 14)
        
        ivaTitle = UILabel()
        ivaTitle!.text = NSLocalizedString("Impuestos",comment:"")
        ivaTitle!.textColor = WMColor.reg_gray
        ivaTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        ivaTitle!.textAlignment = .Right
        ivaTitle!.frame = CGRectMake(146, shippingCostTitle!.frame.maxY + 6, 101, 14)
        
        savingTitle = UILabel()
        savingTitle!.text = NSLocalizedString("Descuento",comment:"")
        savingTitle!.textColor =  WMColor.green
        savingTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        savingTitle!.textAlignment = .Right
        savingTitle!.frame = CGRectMake(146, ivaTitle!.frame.maxY + 3, 101, 14)
        
        totalTitle = UILabel()
        totalTitle!.text = NSLocalizedString("Total",comment:"")
        totalTitle!.textColor = WMColor.orange
        totalTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        totalTitle!.textAlignment = .Right
        totalTitle!.frame = CGRectMake(146, ivaTitle!.frame.maxY + 20, 101, 14)
        
        //values
        valueSubtotal = CurrencyCustomLabel(frame: CGRectMake(subtotalTitle!.frame.maxX + 8, subtotalTitle!.frame.minY, 50, 14))
        valueSubtotal!.textAlignment = .Right
        
        valueShippingCost = CurrencyCustomLabel(frame: CGRectMake(shippingCostTitle!.frame.maxX + 8, shippingCostTitle!.frame.minY, 50, 14))
        valueShippingCost!.textAlignment = .Right
        
        valueIva = CurrencyCustomLabel(frame: CGRectMake(ivaTitle!.frame.maxX + 8, ivaTitle!.frame.minY, 50, 14))
        valueIva!.textAlignment = .Right
        
        valueTotal = CurrencyCustomLabel(frame: CGRectMake(totalTitle!.frame.maxX + 8, totalTitle!.frame.minY, 50, 14))
        valueTotal!.textAlignment = .Right
        
        valueTotalSaving = CurrencyCustomLabel(frame: CGRectMake(ivaTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 14))
        valueTotalSaving!.textAlignment = .Right
        
        self.addSubview(articlesTitle!)
        self.addSubview(subtotalTitle!)
        self.addSubview(shippingCostTitle!)
        self.addSubview(ivaTitle!)
        self.addSubview(savingTitle!)
        self.addSubview(totalTitle!)
        //values
        self.addSubview(valueSubtotal!)
        self.addSubview(valueShippingCost!)
        self.addSubview(valueIva!)
        self.addSubview(valueTotal!)
        self.addSubview(valueTotalSaving!)
    }
    
    override func layoutSubviews() {
        let startX: CGFloat = IS_IPAD ? self.bounds.width - 175 : 146
        

        articlesTitle!.frame = CGRectMake(16, 16, 101, 14)
        subtotalTitle!.frame = CGRectMake(startX, 16, 101, 14)
        shippingCostTitle!.frame = CGRectMake(startX, subtotalTitle!.frame.maxY + 6, 101, 14)
        ivaTitle!.frame = CGRectMake(startX, shippingCostTitle!.frame.maxY + 6, 101, 14)
        savingTitle!.frame = CGRectMake(startX, ivaTitle!.frame.maxY + 3, 101, 14)
        totalTitle!.frame = CGRectMake(startX, ivaTitle!.frame.maxY + 20, 101, 14)
            
        //values
        valueSubtotal!.frame = CGRectMake(subtotalTitle!.frame.maxX + 8, subtotalTitle!.frame.minY, 50, 14)
        valueShippingCost!.frame = CGRectMake(shippingCostTitle!.frame.maxX + 8, shippingCostTitle!.frame.minY, 50, 14)
        valueIva!.frame = CGRectMake(ivaTitle!.frame.maxX + 8, ivaTitle!.frame.minY, 50, 14)
        valueTotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, totalTitle!.frame.minY, 50, 14)
        valueTotalSaving!.frame = CGRectMake(ivaTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 14)
    }
    
    func setValuesAll(articles articles:String,subtotal:String,shippingCost:String,iva:String,saving:String,total:String){
        
        articlesTitle!.text  = "\(articles) \(NSLocalizedString("artículos",comment:""))"

        let formatedShippingCost = CurrencyCustomLabel.formatString(shippingCost)
        valueShippingCost!.updateMount(formatedShippingCost, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        let formatedIVA = CurrencyCustomLabel.formatString(iva)
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving)
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        
        valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueIva!.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueTotalSaving!.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        valueTotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 12)
    }
    
    func setValuesTotalSaving(Total total:String, saving:String){
        
        subtotalTitle!.hidden = true
        shippingCostTitle!.hidden = true
        ivaTitle!.hidden = true
        articlesTitle!.hidden = true
        
        valueSubtotal!.hidden = true
        valueShippingCost!.hidden = true
        valueIva!.hidden = true
        
        savingTitle!.text = NSLocalizedString("previousorder.saving",comment:"")
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving)
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        
        valueTotalSaving!.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
        let yLabel = (self.bounds.height - 27) / 2
        
        if IS_IPAD {
            totalTitle!.frame = CGRectMake(self.bounds.width - 175, yLabel, 101, 12)
            savingTitle!.frame = CGRectMake(self.bounds.width - 175, totalTitle!.frame.maxY + 3, 101, 12)
            
            valueTotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, totalTitle!.frame.minY, 50, 12)
            valueTotalSaving!.frame = CGRectMake(totalTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 12)
        } else {
            totalTitle!.frame = CGRectMake(146, yLabel, 101, 12)
            savingTitle!.frame = CGRectMake(146, totalTitle!.frame.maxY + 3, 101, 12)
            
            valueTotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, totalTitle!.frame.minY, 50, 12)
            valueTotalSaving!.frame = CGRectMake(totalTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 12)
        }
        
    }
    
    func setValuesArtSubtTotal(articles articles:String, subtotal:String, total:String){
        
        subtotalTitle!.hidden = true
        shippingCostTitle!.hidden = true
        ivaTitle!.hidden = true
        savingTitle!.hidden = true
        
        valueSubtotal!.hidden = true
        valueShippingCost!.hidden = true
        valueIva!.hidden = true
        valueTotalSaving!.hidden = true
        
        articlesTitle!.text  = "\(articles) \(NSLocalizedString("artículos",comment:""))"
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        
        valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
        let yLabel = (self.bounds.height - 27) / 2
        
        articlesTitle!.frame = CGRectMake(16, yLabel, 101, 14)
        
        if IS_IPAD {
            subtotalTitle!.frame = CGRectMake(self.bounds.width - 175, yLabel, 101, 12)
            totalTitle!.frame = CGRectMake(self.bounds.width - 175, totalTitle!.frame.maxY + 3, 101, 12)
            
            valueSubtotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, totalTitle!.frame.minY, 50, 12)
            valueTotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 12)
        } else {
            subtotalTitle!.frame = CGRectMake(146, yLabel, 101, 12)
            totalTitle!.frame = CGRectMake(146, totalTitle!.frame.maxY + 3, 101, 12)
            
            valueSubtotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, totalTitle!.frame.minY, 50, 12)
            valueTotal!.frame = CGRectMake(totalTitle!.frame.maxX + 8, savingTitle!.frame.minY, 50, 12)
        }
    }
    
    func setValuesNotArtNotShipping(subtotal subtotal:String,iva:String,saving:String,total:String) {
        
        articlesTitle!.hidden = true
        shippingCostTitle!.hidden = true
        valueShippingCost!.hidden = true
        
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        let formatedIVA = CurrencyCustomLabel.formatString(iva)
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving)
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        
        valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueIva!.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueTotalSaving!.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
    }
    
}