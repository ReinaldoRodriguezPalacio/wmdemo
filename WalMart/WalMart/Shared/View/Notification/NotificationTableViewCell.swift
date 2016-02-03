//
//  NotificationTableViewCell.swift
//  WalMart
//
//  Created by Alejandro Miranda on 18/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class NotificationTableViewCell : UITableViewCell {
    
    
    var dateLabel : UILabel? = nil
    var hourLabel : UILabel? = nil
    var descLabel : UILabel? = nil
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        dateLabel = UILabel(frame: CGRectMake(16, 16, 100, 16))
        dateLabel?.textColor = WMColor.light_blue
        dateLabel?.font = WMFont.fontMyriadProLightOfSize(16)
        self.addSubview(dateLabel!)
        
        hourLabel = UILabel (frame: CGRectMake(269, 16, 35, 16))
        hourLabel?.textColor = WMColor.light_blue
        hourLabel?.font = WMFont.fontMyriadProLightOfSize(16)
        hourLabel?.textAlignment = .Right
        self.addSubview(hourLabel!)
        
        descLabel = UILabel (frame: CGRectMake(16, hourLabel!.frame.maxY + 8, 300, 40))
        descLabel?.textColor = WMColor.gray
        descLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        descLabel?.numberOfLines = 3
        self.addSubview(descLabel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hourLabel?.frame =  CGRectMake(self.frame.width - 51, 16, 35, 16)
    }
    
}