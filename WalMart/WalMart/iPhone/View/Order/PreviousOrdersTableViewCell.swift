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
    var countItems : UILabel!
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
        
        trackingNumberLabel = UILabel(frame: CGRectMake(16, 0, 64, 46))
        trackingNumberLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        trackingNumberLabel.textColor = WMColor.gray
        
        dateLabel = UILabel(frame: CGRectMake(91, 0, 64, 46))
        dateLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        dateLabel.textColor = WMColor.gray
        
        statusLabel = UILabel(frame: CGRectMake(171, 0, 100, 46))
        statusLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        statusLabel.textColor = WMColor.gray
        statusLabel.numberOfLines = 2
        statusLabel.textAlignment = NSTextAlignment.Left
        
        countItems = UILabel(frame: CGRectMake(self.bounds.width - 34, 0, 18, 46))
        countItems.font = WMFont.fontMyriadProRegularOfSize(12)
        countItems.textColor = WMColor.gray
        countItems.textAlignment = NSTextAlignment.Center
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.light_gray
        self.viewSeparator.frame = CGRectMake(dateLabel.frame.minX,self.frame.maxY - AppDelegate.separatorHeigth(),self.frame.width - dateLabel.frame.minX,AppDelegate.separatorHeigth())
        self.addSubview(viewSeparator)
        
        self.addSubview(trackingNumberLabel)
        self.addSubview(dateLabel)
        self.addSubview(statusLabel)
        self.addSubview(countItems)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        viewSeparator.frame = CGRectMake(dateLabel.frame.minX,self.bounds.maxY - AppDelegate.separatorHeigth(),self.bounds.width - dateLabel.frame.minX,AppDelegate.separatorHeigth())
        //statusLabel.frame = CGRectMake(self.bounds.width - 94, 18, 70, 14)
    }
    
    func setValues(date:String,trackingNumber:String,status:String, countsItem:String) {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let date = dateFormat.dateFromString(date)
        
        //dateFormat.dateFormat = "dd MMM yy"
        let resultDate = dateFormat.stringFromDate(date!)
        
        dateLabel.text = resultDate
        trackingNumberLabel.text = trackingNumber
        statusLabel.text = status
        countItems.text = "(" + countsItem + ")"
        
        statusLabel.textColor = PreviousOrdersTableViewCell.setColorStatus(status)
    }
    
    class func setColorStatus(status:String) -> UIColor? {
        var ColorStatus : UIColor?
        
        switch status {
        case "Pedido creado":
            ColorStatus = WMColor.yellow
        case "Pago pendiente":
            ColorStatus = WMColor.orange
        case "Pago no confirmado":
            ColorStatus = WMColor.orange
        case "Pago confirmado":
            ColorStatus = WMColor.light_light_blue
        case "Revisando pago":
            ColorStatus = WMColor.light_red
        default:
            ColorStatus = WMColor.light_red
        }
        
        return ColorStatus
    }
    
    
    
}