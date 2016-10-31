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
        self.selectionStyle = .none
        backgroundColor = WMColor.light_light_gray
        
        total = UILabel()
        total.text = NSLocalizedString("previousorder.total",comment:"")
        total.textColor = WMColor.orange
        total.font = WMFont.fontMyriadProSemiboldOfSize(14)
        total.textAlignment = .right
        total.frame = CGRect(x: 146, y: 20, width: 101, height: 12)
        
        totalSavingTitle = UILabel()
        totalSavingTitle.text = NSLocalizedString("previousorder.saving",comment:"")
        totalSavingTitle.textColor =  WMColor.green
        totalSavingTitle.font = WMFont.fontMyriadProSemiboldOfSize(14)
        totalSavingTitle.textAlignment = .right
        totalSavingTitle.frame = CGRect(x: 146, y: 35, width: 101, height: 12)
        
        valueTotal = CurrencyCustomLabel(frame: CGRect(x: total.frame.maxX + 8, y: total.frame.minY, width: 50, height: 12))
        valueTotal.textAlignment = .right
        valueTotalSaving = CurrencyCustomLabel(frame: CGRect(x: total.frame.maxX + 8, y: totalSavingTitle.frame.minY, width: 50, height: 12))
        valueTotalSaving.textAlignment = .right
        
        self.addSubview(total)
        self.addSubview(totalSavingTitle)
        
        self.addSubview(valueTotal)
        self.addSubview(valueTotalSaving)
    }
    
    override func layoutSubviews() {
        if IS_IPAD {
            total.frame = CGRect(x: self.bounds.width - 175, y: 20, width: 101, height: 12)
            totalSavingTitle.frame = CGRect(x: self.bounds.width - 175, y: 35, width: 101, height: 12)
            
            valueTotal.frame = CGRect(x: total.frame.maxX + 8, y: total.frame.minY, width: 50, height: 12)
            valueTotalSaving.frame = CGRect(x: total.frame.maxX + 8, y: totalSavingTitle.frame.minY, width: 50, height: 12)
        }
    }
    
    func setValues(_ total: String,totalSaving:String){
        
        let formatedTotal = CurrencyCustomLabel.formatString(total)
        valueTotal.updateMount(formatedTotal, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.orange, interLine: false)
        
        let formatedTotalSaving = CurrencyCustomLabel.formatString(totalSaving)
        valueTotalSaving.updateMount(formatedTotalSaving, font: WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.green, interLine: false)
    }
    
}
