//
//  CheckOutShippingDetailCell.swift
//  WalMart
//
//  Created by Everardo Garcia on 05/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//


import UIKit

class CheckOutShippingDetailCell: UITableViewCell {
    
    var type: UILabel?
    var util: UILabel?
    var date: UILabel?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        self.type = UILabel()
        self.type!.numberOfLines = 1
        self.type!.textAlignment = .Left
        self.type!.backgroundColor = UIColor.clearColor()
        
        self.type!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.type!.textColor = WMColor.gray_reg
        self.contentView.addSubview(self.type!)
        
        self.util = UILabel()
        self.util!.numberOfLines = 2
        self.util!.textAlignment = .Left
        self.util!.backgroundColor = UIColor.clearColor()
        self.util!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.contentView.addSubview(self.util!)
        
        self.date = UILabel()
        self.date!.numberOfLines = 1
        self.date!.textAlignment = .Left
        self.date!.backgroundColor = UIColor.clearColor()
        
        self.date!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.date!.textColor = WMColor.gray_reg
        self.contentView.addSubview(self.date!)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 20.0
        let width:CGFloat = bounds.width - (2*margin)
        
        self.type!.frame = CGRectMake(16, 8, width, 15)
        self.util!.frame = CGRectMake(16, self.type!.frame.maxY, width, 15)
        self.date!.frame = CGRectMake(16, self.util!.frame.maxY, width, 15)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(type: String, util: String, date: String ) {
        
        self.type!.text = type
        self.util!.text = util
        self.date!.text = date

    }
    
}



