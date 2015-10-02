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
        titleLabel.textColor = WMColor.lineTextColor
        
        separator = UIView()
        separator.backgroundColor = WMColor.categoryLineSeparatorColor
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(separator)
        self.addSubview(titleLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)
        titleLabel.frame = CGRectMake(40, 0, self.bounds.width - 40, self.bounds.height)

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
    
    override func setSelected(selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.hidden = !selected
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.hidden = true
    }
}