//
//  IPAFamilyTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAFamilyTableViewCell : IPOFamilyTableViewCell {
    
    var separatorView : UIView!
    
    override func setup() {
        super.setup()
        
        self.titleLabel.textColor = UIColor.whiteColor()
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor.whiteColor()
        self.addSubview(separatorView)
        
        var bgColorView = UIView()
        bgColorView.backgroundColor =  WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.12)
        self.selectedBackgroundView = bgColorView
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.separatorView.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, 1)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.separatorView.hidden = selected
    }
    

}