//
//  PreviousOrdersTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class PreviousOrdersTableViewCell: UITableViewCell {
    
    var dateLabel : UILabel!
    var trackingNumberLabel : UILabel!
    var statusLabel : UILabel!
    var statusIcon : UIImageView!
    var viewSeparator : UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         setup()
    }
    
    
    func setup() {
        
        dateLabel = UILabel()
        dateLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        dateLabel.textColor = WMColor.light_blue
        
        trackingNumberLabel = UILabel()
        trackingNumberLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        trackingNumberLabel.textColor = WMColor.gray
        
        statusLabel = UILabel()
        statusLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        statusLabel.textColor = WMColor.gray
        statusLabel.textAlignment = NSTextAlignment.right
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.light_gray
        self.viewSeparator.frame = CGRect(x: dateLabel.frame.minX,y: self.frame.maxY - AppDelegate.separatorHeigth(),width: self.frame.width - dateLabel.frame.minX,height: AppDelegate.separatorHeigth())
        self.addSubview(viewSeparator)
        
        
        self.addSubview(dateLabel)
        self.addSubview(trackingNumberLabel)
        self.addSubview(statusLabel)
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let labelWidth: CGFloat = (self.frame.width - 102) / 2
        trackingNumberLabel.frame = CGRect(x:16, y: 18, width: IS_IPAD ? 284 : labelWidth - 10, height: 14)
        dateLabel.frame = CGRect(x: trackingNumberLabel.frame.maxX, y: 18, width: 70, height: 14)
        statusLabel.frame = CGRect(x: dateLabel.frame.maxX, y: 18, width: IS_IPAD ? 284 : labelWidth + 10, height: 14)
        viewSeparator.frame = CGRect(x: 0,y: self.bounds.maxY - AppDelegate.separatorHeigth(),width: self.bounds.width,height: AppDelegate.separatorHeigth())
        
        
    }
    
    
    func setValues(_ date:String,trackingNumber:String,status:String) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let date = dateFormat.date(from: date)
        
        dateFormat.dateFormat = "dd MMM yy"
        let resultDate = dateFormat.string(from: date!)
        
        dateLabel.text = resultDate
        trackingNumberLabel.text = trackingNumber
        statusLabel.text = status
        
       
        
    }
    
    
    
}
