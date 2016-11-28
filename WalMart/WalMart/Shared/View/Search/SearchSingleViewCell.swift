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
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        
        let bounds = self.frame.size
        
        self.priceLabel = CurrencyCustomLabel(frame: CGRect(x: bounds.width - 80 - 15 , y: 0.0, width: 80 , height: bounds.height - 1.0))
        self.priceLabel?.textAlignment =  NSTextAlignment.right
        self.title = UILabel()
        
        self.title!.textColor = WMColor.light_blue
        self.title!.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.title!)
        self.contentView.addSubview(priceLabel!)
        
        self.contentView.backgroundColor = UIColor.clear
        self.fontTitle = WMFont.fontMyriadProRegularOfSize(14)
        self.fontTitleKey = WMFont.fontMyriadProBoldOfSize(14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setValueTitle(_ value:AnyObject, forKey key:String, andPrice price:String) {
        self.priceLabel?.textAlignment =  NSTextAlignment.right
        if let keyword = value as? String {
            self.title!.attributedText = SearchSingleViewCell.attributedText(key as NSString, value: keyword as NSString, fontKey: self.fontTitleKey!, fontValue: self.fontTitle!)
        }
        let formatedPrice = CurrencyCustomLabel.formatString(price)
        self.priceLabel?.updateMount(formatedPrice, font: fontTitle!, color:self.title!.textColor, interLine: false)
        self.priceLabel!.textAlignment = .right
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        self.title!.frame = CGRect(x: 15.0, y: 0.0, width: bounds.width - 80.0 - 30.0, height: bounds.height - 1.0)
        self.priceLabel!.frame = CGRect(x: bounds.width - 80 - 15 , y: 0.0, width: 80 , height: bounds.height - 1.0)
    }
    
    //MARK: - Utils
    class func attributedText(_ key:NSString, value:NSString, fontKey:UIFont, fontValue:UIFont) -> NSMutableAttributedString {
        let attributedTxt = NSMutableAttributedString(string:value as String)
        attributedTxt.addAttribute(NSFontAttributeName, value: fontValue, range: NSMakeRange (0, value.length))
        let range = value.range(of: key as String, options: .caseInsensitive)
        if range.location != NSNotFound {
            attributedTxt.addAttribute(NSFontAttributeName, value: fontKey, range: NSMakeRange (range.location, key.length))
        }
        return attributedTxt
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        var color : UIColor!
        if highlighted == true {
            color = UIColor.white
        }else{
            color = UIColor.clear
        }
        let codeChange = {() -> Void  in
            self.backgroundColor = color
            self.contentView.backgroundColor = color
        }

            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                codeChange()
            })
    }
    
    
}

