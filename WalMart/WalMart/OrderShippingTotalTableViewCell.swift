//
//  OrderShippingTotalTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 26/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class OrderShippingTotalTableViewCell  : UITableViewCell {
    
    var total : UILabel!
    var totalSavingTitle : UILabel!
    
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
        self.selectionStyle = .None
        backgroundColor = WMColor.light_light_gray
        
        total = UILabel()
        total.text = NSLocalizedString("previousorder.total",comment:"")
        total.textColor = WMColor.orange
        total.font = WMFont.fontMyriadProSemiboldOfSize(14)
        total.textAlignment = .Right
        total.frame = CGRectMake(146, 20, 101, 12)
        
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("previousorder.saving",comment:"")
        totalSavingTitle.textColor =  WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        totalSavingTitle.textAlignment = .Right
        totalSavingTitle.frame = CGRectMake(146, 35, 101, 12)
        
        valueTotal = CurrencyCustomLabel(frame: CGRectMake(total.frame.maxX + 8, total.frame.minY, 50, 12))
        valueTotal.textAlignment = .Right
        valueTotalSaving = CurrencyCustomLabel(frame: CGRectMake(total.frame.maxX + 8, totalSavingTitle.frame.minY, 50, 12))
        valueTotalSaving.textAlignment = .Right
        
        self.addSubview(total)
        self.addSubview(totalSavingTitle)
        
        self.addSubview(valueTotal)
        self.addSubview(valueTotalSaving)
    }
    
    func setValues(total: String,totalSaving:String){
        
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
        let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving)
        valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
    }
    
}