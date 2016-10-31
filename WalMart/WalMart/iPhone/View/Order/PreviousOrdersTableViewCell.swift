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
        
        trackingNumberLabel = UILabel(frame: CGRect(x: 16, y: 0, width: (IS_IPAD ? 182 : 64), height: 46))
        trackingNumberLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        trackingNumberLabel.textColor = WMColor.reg_gray
        
        dateLabel = UILabel(frame: CGRect(x: (IS_IPAD ? 214 : 91), y: 0, width: (IS_IPAD ? 182 : 64), height: 46))
        dateLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        dateLabel.textColor = WMColor.reg_gray
        
        statusLabel = UILabel(frame: CGRect(x: (IS_IPAD ? 412 : 171), y: 0, width: (IS_IPAD ? 193 : 100), height: 46))
        statusLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        statusLabel.textColor = WMColor.reg_gray
        statusLabel.numberOfLines = 2
        statusLabel.textAlignment = NSTextAlignment.left
        
        countItems = UILabel(frame: CGRect(x: (IS_IPAD ? 621 : self.bounds.width - 32), y: 0, width: (IS_IPAD ? 46 : 18), height: 46))
        countItems.font = WMFont.fontMyriadProRegularOfSize(12)
        countItems.textColor = WMColor.reg_gray
        countItems.textAlignment = NSTextAlignment.center
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.light_gray
        self.viewSeparator.frame = CGRect(x: trackingNumberLabel.frame.minX ,y: self.frame.maxY - AppDelegate.separatorHeigth(),width: self.frame.width - trackingNumberLabel.frame.minX,height: AppDelegate.separatorHeigth())
        self.addSubview(viewSeparator)
        
        self.addSubview(trackingNumberLabel)
        self.addSubview(dateLabel)
        self.addSubview(statusLabel)
        self.addSubview(countItems)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        viewSeparator.frame = CGRect(x: trackingNumberLabel.frame.minX, y: self.bounds.maxY - AppDelegate.separatorHeigth(), width: self.bounds.width - trackingNumberLabel.frame.minX,height: AppDelegate.separatorHeigth())
        //statusLabel.frame = CGRectMake(self.bounds.width - 94, 18, 70, 14)
    }
    
    func setValues(_ date:String,trackingNumber:String,status:String, countsItem:String) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let date = dateFormat.date(from: date)
        
        //dateFormat.dateFormat = "dd MMM yy"
        let resultDate = dateFormat.string(from: date!)
        
        dateLabel.text = resultDate
        trackingNumberLabel.text = trackingNumber
        statusLabel.text = status
        countItems.text = "(" + countsItem + ")"
        
        statusLabel.textColor = PreviousOrdersTableViewCell.setColorStatus(status)
    }
    
    class func setColorStatus(_ status:String) -> UIColor? {
        var ColorStatus : UIColor?
        
        switch status {
        case "Pedido creado":
            ColorStatus =  WMColor.yellow
        case "Pago pendiente":
            ColorStatus = WMColor.UIColorFromRGB(0xFE8C25)
        case "Pago no confirmado":
            ColorStatus = WMColor.UIColorFromRGB(0xF86721)
        case "Pago confirmado":
            ColorStatus = WMColor.UIColorFromRGB(0x2899F9)
        case "Revisando pago":
            ColorStatus = WMColor.UIColorFromRGB(0xF70C1A)
        case "Cancelado":
            ColorStatus =  WMColor.dark_gray
        default:
            ColorStatus =  WMColor.dark_gray
        }
        
        return ColorStatus
    }
    
    
    
}
