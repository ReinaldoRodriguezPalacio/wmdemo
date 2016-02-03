//
//  SearchCategoriesViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class SearchCategoriesViewCell: UITableViewCell {
    var fontTitle: UIFont?
    var fontTitleKey: UIFont?
    var title: UILabel?
    var departament : UILabel? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        self.departament = UILabel()
        self.departament!.textColor = WMColor.gray
        self.departament!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        self.title = UILabel()
        self.title!.textColor = WMColor.light_blue
        self.title!.backgroundColor = UIColor.clearColor()
        self.title!.font = WMFont.fontMyriadProRegularOfSize(14)

        //self.title!.numberOfLines = 2
        self.contentView.addSubview(self.title!)
        self.contentView.addSubview(self.departament!)
        
        self.contentView.backgroundColor = UIColor.clearColor()
        self.fontTitle = WMFont.fontMyriadProRegularOfSize(14)
        self.fontTitleKey = WMFont.fontMyriadProBoldOfSize(14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setValueTitle(value:String, forKey key:String, andDepartament departament:String) {
        self.title!.attributedText = SearchSingleViewCell.attributedText(key, value: value, fontKey: self.fontTitleKey!, fontValue: self.fontTitle!)
        self.departament!.text = departament;
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.title!.frame = CGRectMake(15.0, 12, bounds.width - 30.0, 12)
        self.departament!.frame = CGRectMake(15 , 33 , bounds.width - 30.0 , 12)
    }

    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        var color : UIColor!
        if highlighted == true {
            color = UIColor.whiteColor()
        }else{
            color = UIColor.clearColor()
        }
        let codeChange = {() -> Void  in
            self.backgroundColor = color
            self.contentView.backgroundColor = color
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            codeChange()
        })
    }
    
}
