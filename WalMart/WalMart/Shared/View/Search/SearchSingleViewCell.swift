//
//  SearchSingleViewCellTableViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 08/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class SearchSingleViewCell: UITableViewCell {

    var fontTitle: UIFont?
    var fontTitleKey: UIFont?
    var title: UILabel?
    var priceLabel : CurrencyCustomLabel? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        var bounds = self.frame.size
        
        self.priceLabel = CurrencyCustomLabel(frame: CGRectMake(bounds.width - 80 - 15 , 0.0, 80 , bounds.height - 1.0))
        self.priceLabel?.textAlignment =  NSTextAlignment.Right
        self.title = UILabel()
        
        self.title!.textColor = WMColor.searchCategoriesAllColor
        self.title!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.title!)
        self.contentView.addSubview(priceLabel!)
        
        self.contentView.backgroundColor = UIColor.clearColor()
        self.fontTitle = WMFont.fontMyriadProRegularOfSize(14)
        self.fontTitleKey = WMFont.fontMyriadProBoldOfSize(14)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setValueTitle(value:AnyObject, forKey key:String, andPrice price:String) {
        self.priceLabel?.textAlignment =  NSTextAlignment.Right
        if let keyword = value as? String {
            self.title!.attributedText = SearchSingleViewCell.attributedText(key, value: keyword, fontKey: self.fontTitleKey!, fontValue: self.fontTitle!)
        }
        let formatedPrice = CurrencyCustomLabel.formatString(price)
        self.priceLabel?.updateMount(formatedPrice, font: fontTitle!, color:self.title!.textColor, interLine: false)
        self.priceLabel!.textAlignment = .Right
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        var bounds = self.frame.size
        self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.title!.frame = CGRectMake(15.0, 0.0, bounds.width - 80.0 - 30.0, bounds.height - 1.0)
        self.priceLabel!.frame = CGRectMake(bounds.width - 80 - 15 , 0.0, 80 , bounds.height - 1.0)
    }
    
    //MARK: - Utils
    class func attributedText(key:NSString, value:NSString, fontKey:UIFont, fontValue:UIFont) -> NSMutableAttributedString {
        var attributedTxt = NSMutableAttributedString(string:value)
        attributedTxt.addAttribute(NSFontAttributeName, value: fontValue, range: NSMakeRange (0, value.length))
        var range = value.rangeOfString(key, options: .CaseInsensitiveSearch)
        if range.location != NSNotFound {
            attributedTxt.addAttribute(NSFontAttributeName, value: fontKey, range: NSMakeRange (range.location, key.length))
        }
        return attributedTxt
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        var color : UIColor!
        if highlighted == true {
            color = WMColor.UIColorFromRGB(0xFFFFFF, alpha: 1)
        }else{
            color = UIColor.clearColor()
        }
        var codeChange = {() -> Void  in
            self.backgroundColor = color
            self.contentView.backgroundColor = color
        }

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                codeChange()
            })
    }
    
    
}

