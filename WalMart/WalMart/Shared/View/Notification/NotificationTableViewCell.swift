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
    var line: CALayer!
    
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
        
        descLabel = UILabel (frame: CGRectMake(16, hourLabel!.frame.maxY + 8, self.frame.size.width - 32, 40))
        descLabel?.textColor = WMColor.reg_gray
        descLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        descLabel?.numberOfLines = 3
        descLabel?.lineBreakMode =  .ByClipping
        descLabel?.adjustsFontSizeToFitWidth =  true
        
        self.addSubview(descLabel!)
        
        line = CALayer()
        line.backgroundColor = WMColor.light_light_gray.CGColor
        self.layer.insertSublayer(line, atIndex: 1000)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hourLabel?.frame =  CGRectMake(self.frame.width - 51, 16, 35, 16)
        descLabel!.frame = CGRectMake(16, hourLabel!.frame.maxY + 8, self.frame.size.width - 32, 40)
        line.frame = CGRectMake(0,self.bounds.maxY - 1,self.bounds.width, 1)

    }
    
}