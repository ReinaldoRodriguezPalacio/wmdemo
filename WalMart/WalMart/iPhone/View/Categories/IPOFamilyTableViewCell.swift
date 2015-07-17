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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = WMColor.familyTextColor
        
        separator = UIView()
        separator.backgroundColor = WMColor.lineSaparatorColor
        self.addSubview(separator)
        
        self.addSubview(titleLabel)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRectMake(20, 0, self.bounds.width - 40, self.bounds.height)
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        separator.frame = CGRectMake(0, self.bounds.height - widthAndHeightSeparator, self.bounds.width, widthAndHeightSeparator)
    }
    
    func setTitle(title:String){
        titleLabel.text = title
    }
    
    
    
}