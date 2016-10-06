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
    
        self.categoryButton?.setTitle(NSLocalizedString("preferences.category.all.button",comment:""), forState: UIControlState.Normal)
        self.categoryButton!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.categoryButton!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        self.categoryButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(15)
        self.categoryButton!.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        self.categoryButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.categoryButton!.titleEdgeInsets = UIEdgeInsetsMake(2, 10, 0, 0);
        self.addSubview(self.categoryButton!)
        
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.categoryButton!.frame = CGRectMake(15, 0, self.bounds.width, bounds.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
