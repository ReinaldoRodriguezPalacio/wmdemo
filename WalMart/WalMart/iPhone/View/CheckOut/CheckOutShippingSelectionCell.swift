//
//  CheckOutShippingSelectionCell.swift
//  WalMart
//
//  Created by Everardo Garcia on 06/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//


import UIKit

class CheckOutShippingSelectionCell: CheckOutShippingDetailCell {
    
    var selectedButton: UIButton?
    var delivaryCost : CurrencyCustomLabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.selectedButton = UIButton()
        self.selectedButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.selectedButton!.setImage(UIImage(named:"check_full"), forState: UIControlState.Selected)
        self.selectedButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.selectedButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.contentView.addSubview(self.selectedButton!)
        
        delivaryCost = CurrencyCustomLabel(frame: CGRectMake(self.frame.width - 66, 16, 50, 18))
        delivaryCost!.textAlignment = .Right
        self.contentView.addSubview(delivaryCost!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedButton!.frame = CGRectMake(16, 29, 16, 16)
        self.type!.frame = CGRectMake(self.selectedButton!.frame.maxX + 16.0, 16 , 205, 12)
        self.util!.frame = CGRectMake(self.selectedButton!.frame.maxX + 16.0, self.type!.frame.maxY + 6, 205, 10)
        self.date!.frame = CGRectMake(self.selectedButton!.frame.maxX + 16.0, self.util!.frame.maxY + 6, 205, 12)
        self.delivaryCost!.frame =  CGRectMake(self.frame.width - 66, 16, 50, 18)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedButton!.selected = selected
    }
    
    
    func setValues(type: String, util: String, date: String , selected : Bool) {
        self.type!.text = type
        self.util!.text = util
        self.date!.text = date
        self.selectedButton!.selected = self.selected
    }
    
    func setCostDelivery(cost:String){
        delivaryCost!.updateMount( CurrencyCustomLabel.formatString(cost), font: WMFont.fontMyriadProSemiboldOfSize(18), color: WMColor.orange, interLine: false)
    }
    
    
    
    
}




