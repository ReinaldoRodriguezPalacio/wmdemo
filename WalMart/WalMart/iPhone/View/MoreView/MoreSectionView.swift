//
//  MoreSectionView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class MoreSectionView : UIView {
    
    var viewReturn : UILabel!
    
    func setup(title:String) {
        
        viewReturn = UILabel()
        viewReturn.font = WMFont.fontMyriadProRegularOfSize(11)
        viewReturn.textColor = WMColor.reg_gray
        viewReturn.backgroundColor = WMColor.light_light_gray
        viewReturn.text = title
        self.addSubview(viewReturn)
        
        self.backgroundColor = WMColor.light_light_gray
        
    }
    
    override func layoutSubviews() {
        if viewReturn != nil {
            viewReturn.frame = CGRectMake(16, self.bounds.minY, self.bounds.width - 32, self.bounds.height)
        }
    }
    
}