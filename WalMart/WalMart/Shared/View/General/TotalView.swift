//
//  TotalView.swift
//  WalMart
//
//  Created by Joel Juarez on 01/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class TotalView: UIView {
    
    var subtotalTitle : UILabel!
    var shippingCostTitle : UILabel!
    var ivaTitle : UILabel!
    var savingTitle : UILabel!
    var totalTitle : UILabel!
    var articlesTitle : UILabel!
    
    var valueSubtotal : CurrencyCustomLabel!
    var valueShippingCost : CurrencyCustomLabel!
    var valueIva : CurrencyCustomLabel!
    var valueTotalSaving : CurrencyCustomLabel!
    var valueTotal : CurrencyCustomLabel!
   
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
  
  
    override init(frame: CGRect) {
        super.init(frame: frame)
         setup()
    }
    
    func setup() {
        self.backgroundColor =  WMColor.light_light_gray
        
        
        articlesTitle = UILabel()
        articlesTitle.text = NSLocalizedString("articulos",comment:"")
        articlesTitle.textColor = WMColor.gray_reg
        articlesTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        articlesTitle.textAlignment = .Left
        articlesTitle.frame = CGRectMake(16, 16, 101, 14)
        
        subtotalTitle = UILabel()
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle.textColor = WMColor.gray_reg
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        subtotalTitle.textAlignment = .Right
        subtotalTitle.frame = CGRectMake(146, 16, 101, 14)
        
        shippingCostTitle = UILabel()
        shippingCostTitle.text = NSLocalizedString("Costo envío",comment:"")
        shippingCostTitle.textColor = WMColor.gray_reg
        shippingCostTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        shippingCostTitle.textAlignment = .Right
        shippingCostTitle.frame = CGRectMake(146, subtotalTitle.frame.maxY + 6, 101, 14)
        
        ivaTitle = UILabel()
        ivaTitle.text = NSLocalizedString("Impuestos",comment:"")
        ivaTitle.textColor = WMColor.gray_reg
        ivaTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        ivaTitle.textAlignment = .Right
        ivaTitle.frame = CGRectMake(146, shippingCostTitle.frame.maxY + 6, 101, 14)

        savingTitle = UILabel()
        savingTitle.text = NSLocalizedString("Descuento",comment:"")
        savingTitle.textColor =  WMColor.green
        savingTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        savingTitle.textAlignment = .Right
        savingTitle.frame = CGRectMake(146, ivaTitle.frame.maxY + 3, 101, 14)
        
        totalTitle = UILabel()
        totalTitle.text = NSLocalizedString("Total",comment:"")
        totalTitle.textColor = WMColor.gray_reg
        totalTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        totalTitle.textAlignment = .Right
        totalTitle.frame = CGRectMake(146, ivaTitle.frame.maxY + 20, 101, 14)
        
        //values
        
        valueSubtotal = CurrencyCustomLabel(frame: CGRectMake(subtotalTitle.frame.maxX + 8, subtotalTitle.frame.minY, 50, 14))
        valueSubtotal.textAlignment = .Right
        
        valueShippingCost = CurrencyCustomLabel(frame: CGRectMake(shippingCostTitle.frame.maxX + 8, shippingCostTitle.frame.minY, 50, 14))
        valueShippingCost.textAlignment = .Right
        
        valueIva = CurrencyCustomLabel(frame: CGRectMake(ivaTitle.frame.maxX + 8, ivaTitle.frame.minY, 50, 14))
        valueIva.textAlignment = .Right
        
        valueTotal = CurrencyCustomLabel(frame: CGRectMake(totalTitle.frame.maxX + 8, totalTitle.frame.minY, 50, 14))
        valueTotal.textAlignment = .Right
        
        valueTotalSaving = CurrencyCustomLabel(frame: CGRectMake(ivaTitle.frame.maxX + 8, savingTitle.frame.minY, 50, 14))
        valueTotalSaving.textAlignment = .Right
        
        
        self.addSubview(articlesTitle)
        
        self.addSubview(subtotalTitle)
        self.addSubview(shippingCostTitle)
        self.addSubview(ivaTitle)
        self.addSubview(savingTitle)
        self.addSubview(totalTitle)
        //values
        self.addSubview(valueSubtotal)
        self.addSubview(valueShippingCost)
        self.addSubview(valueIva)
        self.addSubview(valueTotal)
        self.addSubview(valueTotalSaving)
        
    }
    
    
    
    func setValues(articles articles:String,subtotal:String,shippingCost:String,iva:String,saving:String,total:String){
        
        articlesTitle.text  = "\(articles) \(NSLocalizedString("artículos",comment:""))"
        
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal)
        let formatedShippingCost = CurrencyCustomLabel.formatString(shippingCost)
        let formatedIVA = CurrencyCustomLabel.formatString(iva)

        valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.gray_reg, interLine: false)
        valueShippingCost.updateMount(formatedShippingCost, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.gray_reg, interLine: false)
        valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.gray_reg, interLine: false)
        
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving)
        valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.gray_reg, interLine: false)
        
    }
    
    
    
    
}