//
//  IPOFamilyTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPOFamilyTableViewCell : UITableViewCell {
    
    
    var titleLabel : UILabel!
    var separator : UIView!
    var viewBgSel : UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.UIColorFromRGB(0xF0F2FA)
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = WMColor.light_blue
        
        separator = UIView()
        separator.backgroundColor = WMColor.lineSaparatorColor
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(separator)
        self.addSubview(titleLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)
        titleLabel.frame = CGRectMake(20, 0, self.bounds.width - 40, self.bounds.height)
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        separator.frame = CGRectMake(0, self.bounds.height - widthAndHeightSeparator, self.bounds.width, widthAndHeightSeparator)
    }
    
    func setTitle(title:String){
        titleLabel.text = title
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