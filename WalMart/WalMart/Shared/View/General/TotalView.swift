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
        articlesTitle.textColor = WMColor.reg_gray
        articlesTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        articlesTitle.textAlignment = .left
        articlesTitle.frame = CGRect(x: 16, y: 16, width: 101, height: 14)
        
        subtotalTitle = UILabel()
        subtotalTitle.text = NSLocalizedString("shoppingcart.subtotal",comment:"")
        subtotalTitle.textColor = WMColor.reg_gray
        subtotalTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        subtotalTitle.textAlignment = .right
        subtotalTitle.frame = CGRect(x: 146, y: 16, width: 101, height: 14)
        
        shippingCostTitle = UILabel()
        shippingCostTitle.text = NSLocalizedString("Costo envío",comment:"")
        shippingCostTitle.textColor = WMColor.reg_gray
        shippingCostTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        shippingCostTitle.textAlignment = .right
        shippingCostTitle.frame = CGRect(x: 146, y: subtotalTitle.frame.maxY + 6, width: 101, height: 14)
        
        ivaTitle = UILabel()
        ivaTitle.text = NSLocalizedString("Impuestos",comment:"")
        ivaTitle.textColor = WMColor.reg_gray
        ivaTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        ivaTitle.textAlignment = .right
        ivaTitle.frame = CGRect(x: 146, y: shippingCostTitle.frame.maxY + 6, width: 101, height: 14)

        savingTitle = UILabel()
        savingTitle.text = NSLocalizedString("Descuento",comment:"")
        savingTitle.textColor =  WMColor.green
        savingTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        savingTitle.textAlignment = .right
        savingTitle.frame = CGRect(x: 146, y: ivaTitle.frame.maxY + 3, width: 101, height: 14)
        
        totalTitle = UILabel()
        totalTitle.text = NSLocalizedString("Total",comment:"")
        totalTitle.textColor = WMColor.orange
        totalTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        totalTitle.textAlignment = .right
        totalTitle.frame = CGRect(x: 146, y: ivaTitle.frame.maxY + 20, width: 101, height: 14)
        
        //values
        
        valueSubtotal = CurrencyCustomLabel(frame: CGRect(x: subtotalTitle.frame.maxX + 8, y: subtotalTitle.frame.minY, width: 50, height: 14))
        valueSubtotal.textAlignment = .right
        
        valueShippingCost = CurrencyCustomLabel(frame: CGRect(x: shippingCostTitle.frame.maxX + 8, y: shippingCostTitle.frame.minY, width: 50, height: 14))
        valueShippingCost.textAlignment = .right
        
        valueIva = CurrencyCustomLabel(frame: CGRect(x: ivaTitle.frame.maxX + 8, y: ivaTitle.frame.minY, width: 50, height: 14))
        valueIva.textAlignment = .right
        
        valueTotal = CurrencyCustomLabel(frame: CGRect(x: totalTitle.frame.maxX + 8, y: totalTitle.frame.minY, width: 50, height: 14))
        valueTotal.textAlignment = .right
        
        valueTotalSaving = CurrencyCustomLabel(frame: CGRect(x: ivaTitle.frame.maxX + 8, y: savingTitle.frame.minY, width: 50, height: 14))
        valueTotalSaving.textAlignment = .right
        
        
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
    
    
    
    func setValues(articles:String,subtotal:String,shippingCost:String,iva:String,saving:String,total:String){
        
        articlesTitle.text  = "\(articles) \(NSLocalizedString("artículos",comment:""))"
        
        let formatedSubTotal = CurrencyCustomLabel.formatString(subtotal as NSString)
        let formatedShippingCost = CurrencyCustomLabel.formatString(shippingCost as NSString)
        let formatedIVA = CurrencyCustomLabel.formatString(iva as NSString)

        valueSubtotal.updateMount(formatedSubTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueShippingCost.updateMount(formatedShippingCost, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        valueIva.updateMount(formatedIVA, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.reg_gray, interLine: false)
        
        let formatedTotalSaving = CurrencyCustomLabel.formatString(saving as NSString)
        valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
        
        let formatedTotal = CurrencyCustomLabel.formatString(total as NSString)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
    }
    
    
    
    
}
