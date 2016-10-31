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
    var delimiter: CALayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.descriptionTitle = UILabel()
        self.descriptionTitle!.numberOfLines = 2
        self.descriptionTitle!.textAlignment = .left
        self.descriptionTitle!.backgroundColor = UIColor.clear
        
        self.descriptionTitle!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .left
        let attrString = NSMutableAttributedString(string: NSLocalizedString("shoppingCart.message.cost", comment:""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.descriptionTitle!.attributedText  = attrString
        self.descriptionTitle!.textColor = WMColor.reg_gray
        self.contentView.addSubview(self.descriptionTitle!)
        
        self.delimiter = CALayer()
        self.delimiter!.backgroundColor  =  WMColor.light_gray.cgColor
        self.contentView.layer.insertSublayer(self.delimiter!, at: 1000)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*margin)
        self.descriptionTitle!.frame = CGRect(x: margin, y: 0.0, width: width, height: bounds.size.height)
        self.delimiter!.frame = CGRect(x: 0.0, y: bounds.height - 1.0, width: bounds.width, height: 1.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(_ value: String , hiddenDelimiter: Bool) {
         self.descriptionTitle!.text = value
        self.delimiter!.isHidden = hiddenDelimiter
    }
}

