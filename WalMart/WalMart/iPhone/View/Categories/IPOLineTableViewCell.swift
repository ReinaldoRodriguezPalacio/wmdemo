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
        titleLabel.textColor = WMColor.lineTextColor
        
        separator = UIView()
        separator.backgroundColor = WMColor.categoryLineSeparatorColor
        self.addSubview(separator)
        
        
        
        self.addSubview(titleLabel)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
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

    
}