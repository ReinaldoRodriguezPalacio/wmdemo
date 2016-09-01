//
//  PreviousDetailTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class PreviousDetailTableViewCell : ProductDetailCharacteristicsTableViewCell {
    var itemShipping = [:]
    var isHeaderView = true
    
    var detailView = UIView()
    var nameLabel = UILabel()
    var deliveryTypeLabel = UILabel()
    var deliveryAddressLabel = UILabel()
    var paymentTypeLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override func setup() {
        let labelDesc = UILabel()
        labelDesc.numberOfLines = 0
        self.addSubview(labelDesc)
        
        self.detailView = UIView(frame:CGRectMake(0, 0.0, self.frame.width, self.frame.height - 40))
        self.detailView.backgroundColor = UIColor.whiteColor()
        
        self.nameLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.nameLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel.textColor = WMColor.gray
        self.detailView.addSubview(self.nameLabel)
        
        self.deliveryTypeLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.deliveryTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryTypeLabel.textColor = WMColor.gray
        self.deliveryTypeLabel.numberOfLines = 2
        self.detailView.addSubview(self.deliveryTypeLabel)
        
        self.deliveryAddressLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.deliveryAddressLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryAddressLabel.textColor = WMColor.gray
        self.deliveryAddressLabel.numberOfLines = 4
        self.detailView.addSubview(self.deliveryAddressLabel)
        
        self.paymentTypeLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.paymentTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.paymentTypeLabel.textColor = WMColor.gray
        self.detailView.addSubview(self.paymentTypeLabel)
        
        self.addSubview(self.detailView)
    }
    
    override func layoutSubviews() {
        self.downBorder.hidden = true
        self.descLabel.hidden = true
    }
    
    func setValuesDetail(values:NSDictionary){
        
        self.itemShipping = values
        
        self.nameLabel.text = values["name"] as? String
        self.deliveryTypeLabel.text = values["deliveryType"] as? String
        let address = values["deliveryAddress"] as? String
        self.deliveryAddressLabel.text = address
        self.paymentTypeLabel.text = values["paymentType"] as? String//"Pago en línea"
        
        var rectSize = size(forText: self.deliveryTypeLabel.text!, withFont: deliveryAddressLabel.font, andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        self.deliveryTypeLabel.frame = CGRectMake(16, self.nameLabel.frame.maxY + 8.0, self.frame.width - 16.0, rectSize.height)
        
        rectSize = size(forText: self.deliveryAddressLabel.text!, withFont: deliveryAddressLabel.font, andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        self.deliveryAddressLabel.frame = CGRectMake(16, self.deliveryTypeLabel.frame.maxY + 8.0, self.frame.width - 16.0, rectSize.height)
        
        rectSize = size(forText: self.paymentTypeLabel.text!, withFont: deliveryAddressLabel.font, andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        self.paymentTypeLabel.frame = CGRectMake(16, self.deliveryAddressLabel.frame.maxY + 8.0, self.frame.width - 16.0, rectSize.height)
    }
    
    func sizeCell(width:CGFloat,values:NSDictionary, showHeader: Bool) -> CGFloat {
        var heigth = 16.0 as CGFloat
        
        let name = values["name"] as? String
        let type = values["deliveryType"] as? String
        let address = values["deliveryAddress"] as? String
        let typePaymen = values["paymentType"] as? String
        
        var rectSize = size(forText: name!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        heigth += rectSize.height + 8.0
        
        rectSize = size(forText: type!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        heigth += rectSize.height + 8.0
        
        rectSize = size(forText: address!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        heigth += rectSize.height + 8.0
        
        rectSize = size(forText: typePaymen!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        heigth += rectSize.height + 32.0
        
        return heigth
    }
    
    func size(forText text:NSString, withFont font:UIFont, andSize size:CGSize) -> CGSize {
        let computedRect: CGRect = text.boundingRectWithSize(size,
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil)
        
        return CGSizeMake(computedRect.size.width, computedRect.size.height)
    }
}