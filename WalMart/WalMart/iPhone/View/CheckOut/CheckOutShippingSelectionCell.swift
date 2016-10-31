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
        self.selectionStyle = .none
        
        self.selectedButton = UIButton()
        self.selectedButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.selectedButton!.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
        self.selectedButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.selectedButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.contentView.addSubview(self.selectedButton!)
        
        delivaryCost = CurrencyCustomLabel(frame: CGRect(x: self.frame.width - 66, y: 16, width: 50, height: 18))
        delivaryCost!.textAlignment = .right
        self.contentView.addSubview(delivaryCost!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedButton!.frame = CGRect(x: 16, y: 29, width: 16, height: 16)
        self.type!.frame = CGRect(x: self.selectedButton!.frame.maxX + 16.0, y: 16 , width: 205, height: 12)
        self.util!.frame = CGRect(x: self.selectedButton!.frame.maxX + 16.0, y: self.type!.frame.maxY + 6, width: 205, height: 10)
        self.date!.frame = CGRect(x: self.selectedButton!.frame.maxX + 16.0, y: self.util!.frame.maxY + 6, width: 205, height: 12)
        self.delivaryCost!.frame =  CGRect(x: self.frame.width - 66, y: 16, width: 50, height: 18)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedButton!.isSelected = selected
    }
    
    
    func setValues(_ type: String, util: String, date: String , selected : Bool) {
        self.type!.text = type
        self.util!.text = util
        self.date!.text = date
        self.selectedButton!.isSelected = self.isSelected
    }
    
    func setCostDelivery(_ cost:String){
        delivaryCost!.updateMount( CurrencyCustomLabel.formatString(cost), font: WMFont.fontMyriadProSemiboldOfSize(18), color: WMColor.orange, interLine: false)
    }
    
    
    
    
}




