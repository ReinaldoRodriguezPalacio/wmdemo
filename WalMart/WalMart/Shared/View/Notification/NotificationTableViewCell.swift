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
        
        dateLabel = UILabel(frame: CGRect(x: 16, y: 16, width: 100, height: 16))
        dateLabel?.textColor = WMColor.light_blue
        dateLabel?.font = WMFont.fontMyriadProLightOfSize(16)
        self.addSubview(dateLabel!)
        
        hourLabel = UILabel (frame: CGRect(x: 269, y: 16, width: 35, height: 16))
        hourLabel?.textColor = WMColor.light_blue
        hourLabel?.font = WMFont.fontMyriadProLightOfSize(16)
        hourLabel?.textAlignment = .right
        self.addSubview(hourLabel!)
        
        descLabel = UILabel (frame: CGRect(x: 16, y: hourLabel!.frame.maxY + 8, width: self.frame.size.width - 32, height: 40))
        descLabel?.textColor = WMColor.reg_gray
        descLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        descLabel?.numberOfLines = 3
        descLabel?.lineBreakMode =  .byClipping
        descLabel?.adjustsFontSizeToFitWidth =  true
        
        self.addSubview(descLabel!)
        
        line = CALayer()
        line.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(line, at: 1000)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hourLabel?.frame =  CGRect(x: self.frame.width - 51, y: 16, width: 35, height: 16)
        descLabel!.frame = CGRect(x: 16, y: hourLabel!.frame.maxY + 8, width: self.frame.size.width - 32, height: 40)
        line.frame = CGRect(x: 0,y: self.bounds.maxY - 1,width: self.bounds.width, height: 1)

    }
    
}
