//
//  CheckOutShippingCell.swift
//  WalMart
//
//  Created by Everardo Garcia on 01/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class CheckOutShippingCell: UITableViewCell {
    

    var labelNumber: UILabel?
    var descriptionTitle: UILabel?
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        self.descriptionTitle = UILabel()
        self.descriptionTitle!.numberOfLines = 1
        self.descriptionTitle!.textAlignment = .Left
        self.descriptionTitle!.backgroundColor = UIColor.clearColor()
        
        self.descriptionTitle!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.descriptionTitle!.textColor = WMColor.gray
        self.contentView.addSubview(self.descriptionTitle!)
        
     
        self.labelNumber = UILabel()
        self.labelNumber!.numberOfLines = 2
        self.labelNumber!.textAlignment = .Left
        self.labelNumber!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.labelNumber!)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 20.0
        let width:CGFloat = bounds.width - (2*margin)
        
        self.labelNumber!.frame = CGRectMake(bounds.width - 40, 0.0, 30, bounds.size.height)
        self.descriptionTitle!.frame = CGRectMake(margin, 0.0, width -  self.labelNumber!.frame.width, bounds.size.height)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(value: String, quanty: String ) {
        var quantyInt =  Int(quanty)
        
        self.descriptionTitle!.text = value
        self.labelNumber!.text = "\(quanty)"
        
    }
    
}


