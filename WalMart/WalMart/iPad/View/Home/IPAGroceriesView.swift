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
        bgView.backgroundColor = UIColor.white
        
        descLabel.textColor = WMColor.light_blue
        descLabel.frame = CGRect(x: 368, y: 0, width: 197, height: self.frame.height)
        
        gotoGroceries.frame = CGRect(x: descLabel.frame.maxX + 9, y: (self.frame.height / 2) - (24 / 2), width: 80, height: 24)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.frame = self.bounds
       
        
    }
    
    
    
}
