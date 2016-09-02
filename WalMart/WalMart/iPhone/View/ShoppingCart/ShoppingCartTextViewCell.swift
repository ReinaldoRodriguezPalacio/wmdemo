//
//  ShoppingCartTextViewCell.swift
//  WalMart
//
//  Created by Everardo Garcia on 12/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class ShoppingCartTextViewCell: UITableViewCell {
    
    var numberCodeLabel: UILabel?
    var labelNumber: UILabel?
    var descriptionTitle: UILabel?
    var codeView: UIImageView?
    var delimiter: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        self.descriptionTitle = UILabel()
        self.descriptionTitle!.numberOfLines = 2
        self.descriptionTitle!.textAlignment = .Left
        self.descriptionTitle!.backgroundColor = UIColor.clearColor()
        
        self.descriptionTitle!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .Left
        let attrString = NSMutableAttributedString(string: NSLocalizedString("shoppingCart.message.cost", comment:""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.descriptionTitle!.attributedText  = attrString
        self.descriptionTitle!.textColor = WMColor.gray_reg
        self.contentView.addSubview(self.descriptionTitle!)
        
        self.delimiter = UIView()
        self.delimiter!.backgroundColor  =  WMColor.light_gray
        self.contentView.addSubview(self.delimiter!)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 20.0
        let width:CGFloat = bounds.width - (2*margin)
        self.descriptionTitle!.frame = CGRectMake(margin, 0.0, width, bounds.size.height)
       // self.delimiter!.frame = CGRectMake(0.0, bounds.height - 1.0, bounds.width, 1.0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(value: String , hiddenDelimiter: Bool) {
         self.descriptionTitle!.text = value
        self.delimiter!.hidden = hiddenDelimiter
    }
}

