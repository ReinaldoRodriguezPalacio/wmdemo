//
//  CategoryInterestTableViewCell.swift
//  WalMart
//
//  Created by Jesus Santa Olalla on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class CategoryInterestTableViewCell: UITableViewCell {

    var categoryButton:UIButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.categoryButton = UIButton()
    
        self.categoryButton?.setTitle(NSLocalizedString("preferences.category.all.button",comment:""), for: UIControlState())
        self.categoryButton!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.categoryButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.categoryButton!.titleLabel?.font = WMFont.fontMyriadProLightOfSize(16)
        self.categoryButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
        self.categoryButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.categoryButton!.titleEdgeInsets = UIEdgeInsetsMake(2, 10, 0, 0);
        self.categoryButton!.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
        self.addSubview(self.categoryButton!)
        
        self.backgroundColor = UIColor.clear
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.categoryButton!.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: bounds.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
