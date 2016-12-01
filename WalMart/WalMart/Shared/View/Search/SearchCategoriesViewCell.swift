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
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        
        self.departament = UILabel()
        self.departament!.textColor = WMColor.gray
        self.departament!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        self.title = UILabel()
        self.title!.textColor = WMColor.light_blue
        self.title!.backgroundColor = UIColor.clear
        self.title!.font = WMFont.fontMyriadProRegularOfSize(14)

        //self.title!.numberOfLines = 2
        self.contentView.addSubview(self.title!)
        self.contentView.addSubview(self.departament!)
        
        self.contentView.backgroundColor = UIColor.clear
        self.fontTitle = WMFont.fontMyriadProRegularOfSize(14)
        self.fontTitleKey = WMFont.fontMyriadProBoldOfSize(14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setValueTitle(_ value:String, forKey key:String, andDepartament departament:String) {
        self.title!.attributedText = SearchSingleViewCell.attributedText(key as NSString, value: value as NSString, fontKey: self.fontTitleKey!, fontValue: self.fontTitle!)
        self.departament!.text = departament;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        self.title!.frame = CGRect(x: 15.0, y: 12, width: bounds.width - 30.0, height: 12)
        self.departament!.frame = CGRect(x: 15 , y: 33 , width: bounds.width - 30.0 , height: 12)
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
