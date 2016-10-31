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
        
        self.selectionStyle = .none
        
        self.type = UILabel()
        self.type!.numberOfLines = 1
        self.type!.textAlignment = .left
        self.type!.backgroundColor = UIColor.clear
        
        self.type!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.type!.textColor = WMColor.light_blue
        self.contentView.addSubview(self.type!)
        
        self.util = UILabel()
        self.util!.numberOfLines = 2
        self.util!.textAlignment = .left
        self.util!.backgroundColor = UIColor.clear
        self.util!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.util!.textColor = WMColor.dark_gray
        self.contentView.addSubview(self.util!)
        
        self.date = UILabel()
        self.date!.numberOfLines = 1
        self.date!.textAlignment = .left
        self.date!.backgroundColor = UIColor.clear
        
        self.date!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.date!.textColor = WMColor.dark_gray
        self.contentView.addSubview(self.date!)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 20.0
        let width:CGFloat = bounds.width - (2*margin)
        
        self.type!.frame = CGRect(x: 16, y: 8, width: width, height: 15)
        self.util!.frame = CGRect(x: 16, y: self.type!.frame.maxY, width: width, height: 15)
        self.date!.frame = CGRect(x: 16, y: self.util!.frame.maxY, width: width, height: 15)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(_ type: String, util: String, date: String ) {
        
        self.type!.text = type
        self.util!.text = util
        self.date!.text = date

    }
    
}



