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
        
        dateLabel = UILabel(frame: CGRectMake(16, 18, 70, 14))
        dateLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        dateLabel.textColor = WMColor.gray
        
        trackingNumberLabel = UILabel(frame: CGRectMake(103, 18, 130, 14))
        trackingNumberLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        trackingNumberLabel.textColor = WMColor.light_blue
        
        statusLabel = UILabel(frame: CGRectMake(self.bounds.width - 94, 18, 70, 14))
        statusLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        statusLabel.textColor = WMColor.gray
        statusLabel.textAlignment = NSTextAlignment.Right
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.productDetailBarButtonBorder
        self.viewSeparator.frame = CGRectMake(dateLabel.frame.minX,self.frame.maxY - AppDelegate.separatorHeigth(),self.frame.width - dateLabel.frame.minX,AppDelegate.separatorHeigth())
        self.addSubview(viewSeparator)
        
        
        self.addSubview(dateLabel)
        self.addSubview(trackingNumberLabel)
        self.addSubview(statusLabel)
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        viewSeparator.frame = CGRectMake(dateLabel.frame.minX,self.bounds.maxY - AppDelegate.separatorHeigth(),self.bounds.width - dateLabel.frame.minX,AppDelegate.separatorHeigth())
        statusLabel.frame = CGRectMake(self.bounds.width - 94, 18, 70, 14)
        
    }
    
    
    func setValues(date:String,trackingNumber:String,status:String) {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let date = dateFormat.dateFromString(date)
        
        dateFormat.dateFormat = "dd MMM yy"
        let resultDate = dateFormat.stringFromDate(date!)
        
        dateLabel.text = resultDate
        trackingNumberLabel.text = trackingNumber
        statusLabel.text = status
        
       
        
    }
    
    
    
}