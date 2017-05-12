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
    var oneLine = false
    
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
        label!.isHidden =  true
        
        priceLabel = CurrencyCustomLabel()
        priceLabel!.textAlignment = .left
        priceLabel!.isHidden =  true
        
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
        self.viewBgSel!.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - 1.0)

        priceLabel?.frame = CGRect(x: bounds.width - 58, y: 0, width: 50, height: self.bounds.height)
        label.frame = CGRect(x: priceLabel!.frame.minX - 48, y: 0, width: 40, height: self.bounds.height)
        titleLabel.frame = CGRect(x: 16, y: 0, width: label!.frame.minX - 8 - 16, height: self.bounds.height)

        if showSeparator {
            separator.alpha = 1
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            separator.frame = CGRect(x: 0, y: self.bounds.height - widthAndHeightSeparator, width: self.bounds.width, height: widthAndHeightSeparator)
        } else {
            separator.alpha = 0
        }
        
    }
    
    func setTitle(_ title:String){
        titleLabel.text = title
    }
    
    func setValues(_ price:String){
        self.newFrame  =  true
        label!.isHidden =  false
        priceLabel?.isHidden =  false
        let fmtTotal = CurrencyCustomLabel.formatString(price as NSString)
        priceLabel?.updateMount(fmtTotal, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.isHidden = !selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.isHidden = true
    }
}
