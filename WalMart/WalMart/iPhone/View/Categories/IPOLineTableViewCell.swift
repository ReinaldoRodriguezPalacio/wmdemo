//
//  IPOLineTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPOLineTableViewCell : UITableViewCell {
    
    
    var titleLabel : UILabel!
    var separator : UIView!
    var showSeparator : Bool = false
    var viewBgSel : UIView!
    var priceLabel : CurrencyCustomLabel?
    var label : UILabel!
    var newFrame  =  false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.light_light_gray
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = WMColor.dark_gray
        
        
        label = UILabel()
        label!.font = WMFont.fontMyriadProLightOfSize(15)
        label!.textColor = WMColor.empty_gray
        label!.text = "desde"
        label!.hidden =  true
        
        priceLabel = CurrencyCustomLabel()
        priceLabel!.textAlignment = .Left
        priceLabel!.hidden =  true
        
        separator = UIView()
        separator.backgroundColor = WMColor.light_gray
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(separator)
        self.addSubview(titleLabel)
        self.addSubview(label)
        self.addSubview(priceLabel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)

        titleLabel.frame = self.newFrame ? CGRectMake(16, 0, 182, self.bounds.height) : CGRectMake(40, 0, self.bounds.width - 40, self.bounds.height)
        label.frame = CGRectMake(titleLabel.frame.maxX + 5, 0, 40, self.bounds.height)
        priceLabel?.frame =  CGRectMake(label.frame.maxX + 5, 0, 50, self.bounds.height)


        if showSeparator {
            separator.alpha = 1
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            separator.frame = CGRectMake(0, self.bounds.height - widthAndHeightSeparator, self.bounds.width, widthAndHeightSeparator)
        }else{
            separator.alpha = 0
        }
        
    }
    
    func setTitle(title:String){
        titleLabel.text = title
    }
    
    func setValues(price:String){
        self.newFrame  =  true
        label!.hidden =  false
        priceLabel?.hidden =  false
        let fmtTotal = CurrencyCustomLabel.formatString(price)
        priceLabel?.updateMount(fmtTotal, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.hidden = !selected
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.hidden = true
    }
}