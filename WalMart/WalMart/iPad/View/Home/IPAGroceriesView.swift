//
//  IPAGroceriesView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/25/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPAGroceriesView : IPOGroceriesView {
    
    override func setup() {
        super.setup()
        bgView.backgroundColor = WMColor.gotosuperipad 
        
        descLabel.textColor = WMColor.light_blue
        descLabel.frame = CGRectMake(368, 0, 197, self.frame.height)
        
        gotoGroceries.frame = CGRectMake(descLabel.frame.maxX + 9, (self.frame.height / 2) - (24 / 2), 80, 24)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.frame = self.bounds
       
        
    }
    
    
    
}