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
    var articlesTitle : UILabel??
    
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
        self.selectionStyle = .none
        self.backgroundColor =  WMColor.light_light_gray
        
        articlesTitle = UILabel()
        articlesTitle!?.text = NSLocalizedString("articulos",comment:"")
        articlesTitle!?.textColor = WMColor.reg_gray
        articlesTitle!?.font = WMFont.fontMyriadProSemiboldOfSize(14)
        articlesTitle!?.textAlignment = .left
        articlesTitle!?.frame = CGRect(x: 16, y: 16, width: 101, height: 14)
        
        subtotalTitle = UILabel()
        subtotalTitle!.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle!.textColor = WMColor.reg_gray
        subtotalTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        subtotalTitle!.textAlignment = .right
        subtotalTitle!.frame = CGRect(x: 146, y: 16, width: 101, height: 14)
        
        shippingCostTitle = UILabel()
        shippingCostTitle!.text = NSLocalizedString("Costo envío",comment:"")
        shippingCostTitle!.textColor = WMColor.reg_gray
        shippingCostTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        shippingCostTitle!.textAlignment = .right
        shippingCostTitle!.frame = CGRect(x: 146, y: subtotalTitle!.frame.maxY + 6, width: 101, height: 14)
        
        ivaTitle = UILabel()
        ivaTitle!.text = NSLocalizedString("Impuestos",comment:"")
        ivaTitle!.textColor = WMColor.reg_gray
        ivaTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        ivaTitle!.textAlignment = .right
        ivaTitle!.frame = CGRect(x: 146, y: shippingCostTitle!.frame.maxY + 6, width: 101, height: 14)
        
        savingTitle = UILabel()
        savingTitle!.text = NSLocalizedString("Descuento",comment:"")
        savingTitle!.textColor =  WMColor.green
        savingTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        savingTitle!.textAlignment = .right
        savingTitle!.frame = CGRect(x: 146, y: ivaTitle!.frame.maxY + 3, width: 101, height: 14)
        
        totalTitle = UILabel()
        totalTitle!.text = NSLocalizedString("Total",comment:"")
        totalTitle!.textColor = WMColor.orange
        totalTitle!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        totalTitle!.textAlignment = .right
        totalTitle!.frame = CGRect(x: 146, y: ivaTitle!.frame.maxY + 20, width: 101, height: 14)
        
        //values
        valueSubtotal = CurrencyCustomLabel(frame: CGRect(x: subtotalTitle!.frame.maxX + 8, y: subtotalTitle!.frame.minY, width: 50, height: 14))
        valueSubtotal!.textAlignment = .right
        
        valueShippingCost = CurrencyCustomLabel(frame: CGRect(x: shippingCostTitle!.frame.maxX + 8, y: shippingCostTitle!.frame.minY, width: 50, height: 14))
        valueShippingCost!.textAlignment = .right
        
        valueIva = CurrencyCustomLabel(frame: CGRect(x: ivaTitle!.frame.maxX + 8, y: ivaTitle!.frame.minY, width: 50, height: 14))
        valueIva!.textAlignment = .right
        
        valueTotal = CurrencyCustomLabel(frame: CGRect(x: totalTitle!.frame.maxX + 8, y: totalTitle!.frame.minY, width: 50, height: 14))
        valueTotal!.textAlignment = .right
        
        valueTotalSaving = CurrencyCustomLabel(frame: CGRect(x: ivaTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 14))
        valueTotalSaving!.textAlignment = .right
        
        self.addSubview(articlesTitle!!)
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
        

        articlesTitle!?.frame = CGRect(x: 16, y: 16, width: 101, height: 14)
        subtotalTitle!.frame = CGRect(x: startX, y: 16, width: 101, height: 14)
        shippingCostTitle!.frame = CGRect(x: startX, y: subtotalTitle!.frame.maxY + 6, width: 101, height: 14)
        ivaTitle!.frame = CGRect(x: startX, y: shippingCostTitle!.frame.maxY + 6, width: 101, height: 14)
        savingTitle!.frame = CGRect(x: startX, y: ivaTitle!.frame.maxY + 3, width: 101, height: 14)
        totalTitle!.frame = CGRect(x: startX, y: ivaTitle!.frame.maxY + 20, width: 101, height: 14)
            
        //values
        valueSubtotal!.frame = CGRect(x: subtotalTitle!.frame.maxX + 8, y: subtotalTitle!.frame.minY, width: 50, height: 14)
        valueShippingCost!.frame = CGRect(x: shippingCostTitle!.frame.maxX + 8, y: shippingCostTitle!.frame.minY, width: 50, height: 14)
        valueIva!.frame = CGRect(x: ivaTitle!.frame.maxX + 8, y: ivaTitle!.frame.minY, width: 50, height: 14)
        valueTotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: totalTitle!.frame.minY, width: 50, height: 14)
        valueTotalSaving!.frame = CGRect(x: ivaTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 14)
    }
    
    func setValuesAll(articles:String,subtotal:String,shippingCost:String,iva:String,saving:String,total:String){
        
        articlesTitle!?.text  = "\(articles) \(NSLocalizedString("artículos",comment:""))"

        let formatedShippingCost = CurrencyCustomLabel.formatString(shippingCost as NSString)
        valueShippingCost!.updateMount(formatedShippingCost, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
        let formatedIVA = CurrencyCustomLabel.formatString(iva as NSString)
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving as NSString)
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        
        valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueIva!.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueTotalSaving!.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        valueTotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 12)
    }
    
    func setValuesTotalSaving(Total total:String, saving:String){
        
        subtotalTitle!.isHidden = true
        shippingCostTitle!.isHidden = true
        ivaTitle!.isHidden = true
        articlesTitle!?.isHidden = true
        
        valueSubtotal!.isHidden = true
        valueShippingCost!.isHidden = true
        valueIva!.isHidden = true
        
        savingTitle!.text = NSLocalizedString("previousorder.saving",comment:"")
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving as NSString)
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        
        valueTotalSaving!.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
        let yLabel = (self.bounds.height - 27) / 2
        
        if IS_IPAD {
            totalTitle!.frame = CGRect(x: self.bounds.width - 175, y: yLabel, width: 101, height: 12)
            savingTitle!.frame = CGRect(x: self.bounds.width - 175, y: totalTitle!.frame.maxY + 3, width: 101, height: 12)
            
            valueTotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: totalTitle!.frame.minY, width: 50, height: 12)
            valueTotalSaving!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 12)
        } else {
            totalTitle!.frame = CGRect(x: 146, y: yLabel, width: 101, height: 12)
            savingTitle!.frame = CGRect(x: 146, y: totalTitle!.frame.maxY + 3, width: 101, height: 12)
            
            valueTotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: totalTitle!.frame.minY, width: 50, height: 12)
            valueTotalSaving!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 12)
        }
        
    }
    
    func setValuesArtSubtTotal(articles:String, subtotal:String, total:String){
        
        subtotalTitle!.isHidden = true
        shippingCostTitle!.isHidden = true
        ivaTitle!.isHidden = true
        savingTitle!.isHidden = true
        
        valueSubtotal!.isHidden = true
        valueShippingCost!.isHidden = true
        valueIva!.isHidden = true
        valueTotalSaving!.isHidden = true
        
        articlesTitle!?.text  = "\(articles) \(NSLocalizedString("artículos",comment:""))"
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        
        valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
        let yLabel = (self.bounds.height - 27) / 2
        
        articlesTitle!?.frame = CGRect(x: 16, y: yLabel, width: 101, height: 14)
        
        if IS_IPAD {
            subtotalTitle!.frame = CGRect(x: self.bounds.width - 175, y: yLabel, width: 101, height: 12)
            totalTitle!.frame = CGRect(x: self.bounds.width - 175, y: totalTitle!.frame.maxY + 3, width: 101, height: 12)
            
            valueSubtotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: totalTitle!.frame.minY, width: 50, height: 12)
            valueTotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 12)
        } else {
            subtotalTitle!.frame = CGRect(x: 146, y: yLabel, width: 101, height: 12)
            totalTitle!.frame = CGRect(x: 146, y: totalTitle!.frame.maxY + 3, width: 101, height: 12)
            
            valueSubtotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: totalTitle!.frame.minY, width: 50, height: 12)
            valueTotal!.frame = CGRect(x: totalTitle!.frame.maxX + 8, y: savingTitle!.frame.minY, width: 50, height: 12)
        }
    }
    
    func setValuesNotArtNotShipping(subtotal:String,iva:String,saving:String,total:String) {
        
        articlesTitle!?.isHidden = true
        shippingCostTitle!.isHidden = true
        valueShippingCost!.isHidden = true
        
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
        let formatedIVA = CurrencyCustomLabel.formatString(iva as NSString)
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving as NSString)
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        
        valueSubtotal!.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueIva!.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueTotalSaving!.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        valueTotal!.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
    }
    
}
