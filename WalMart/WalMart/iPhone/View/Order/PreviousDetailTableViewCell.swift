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
        
        self.detailView = UIView(frame:CGRect(x: 0, y: 0.0, width: self.frame.width, height: self.frame.height - 40))
        self.detailView.backgroundColor = UIColor.white
        
        self.nameLabel = UILabel(frame:CGRect(x: 16, y: 16, width: self.frame.width - 16.0, height: 16.0))
        self.nameLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel.textColor = WMColor.reg_gray
        self.detailView.addSubview(self.nameLabel)
        
        self.deliveryTypeLabel = UILabel(frame:CGRect(x: 16, y: 16, width: self.frame.width - 16.0, height: 16.0))
        self.deliveryTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryTypeLabel.textColor = WMColor.reg_gray
        self.deliveryTypeLabel.numberOfLines = 2
        self.detailView.addSubview(self.deliveryTypeLabel)
        
        self.deliveryAddressLabel = UILabel(frame:CGRect(x: 16, y: 16, width: self.frame.width - 16.0, height: 16.0))
        self.deliveryAddressLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryAddressLabel.textColor = WMColor.reg_gray
        self.deliveryAddressLabel.numberOfLines = 4
        self.detailView.addSubview(self.deliveryAddressLabel)
        
        self.paymentTypeLabel = UILabel(frame:CGRect(x: 16, y: 16, width: self.frame.width - 16.0, height: 16.0))
        self.paymentTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.paymentTypeLabel.textColor = WMColor.reg_gray
        self.detailView.addSubview(self.paymentTypeLabel)
        
        self.addSubview(self.detailView)
    }
    
    override func layoutSubviews() {
        self.downBorder.isHidden = true
        self.descLabel.isHidden = true
    }
    
    func setValuesDetail(_ values:NSDictionary){
        
        self.itemShipping = values as! [AnyHashable : Any]
        
        self.nameLabel.text = values["name"] as? String
        self.deliveryTypeLabel.text = values["deliveryType"] as? String
        let address = values["deliveryAddress"] as? String
        self.deliveryAddressLabel.text = address
        self.paymentTypeLabel.text = values["paymentType"] as? String//"Pago en línea"
        
        var rectSize = size(forText: self.deliveryTypeLabel.text! as NSString, withFont: deliveryAddressLabel.font, andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.greatestFiniteMagnitude))
        self.deliveryTypeLabel.frame = CGRect(x: 16, y: self.nameLabel.frame.maxY + 8.0, width: self.frame.width - 16.0, height: rectSize.height)
        
        rectSize = size(forText: self.deliveryAddressLabel.text! as NSString, withFont: deliveryAddressLabel.font, andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.greatestFiniteMagnitude))
        self.deliveryAddressLabel.frame = CGRect(x: 16, y: self.deliveryTypeLabel.frame.maxY + 8.0, width: self.frame.width - 16.0, height: rectSize.height)
        
        rectSize = size(forText: self.paymentTypeLabel.text! as NSString, withFont: deliveryAddressLabel.font, andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.greatestFiniteMagnitude))
        self.paymentTypeLabel.frame = CGRect(x: 16, y: self.deliveryAddressLabel.frame.maxY + 8.0, width: self.frame.width - 16.0, height: rectSize.height)
    }
    
    func sizeCell(_ width:CGFloat,values:NSDictionary, showHeader: Bool) -> CGFloat {
        var heigth = 16.0 as CGFloat
        
        let name = values["name"] as? String
        let type = values["deliveryType"] as? String
        let address = values["deliveryAddress"] as? String
        let typePaymen = values["paymentType"] as? String
        
        var rectSize = size(forText: name! as NSString, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.max))
        heigth += rectSize.height + 8.0
        
        rectSize = size(forText: type!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.max))
        heigth += rectSize.height + 8.0
        
        rectSize = size(forText: address!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.max))
        heigth += rectSize.height + 8.0
        
        rectSize = size(forText: typePaymen!, withFont:WMFont.fontMyriadProRegularOfSize(14), andSize: CGSize(width: self.frame.width - 16.0, height: CGFloat.max))
        heigth += rectSize.height + 32.0
        
        return heigth
    }
    
    func size(forText text:NSString, withFont font:UIFont, andSize size:CGSize) -> CGSize {
        let computedRect: CGRect = text.boundingRect(with: size,
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil)
        
        return CGSize(width: computedRect.size.width, height: computedRect.size.height)
    }
}
