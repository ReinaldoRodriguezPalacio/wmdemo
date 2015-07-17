//
//  IPOSearchResultEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 24/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class IPOSearchResultEmptyView : IPOEmptyView {
    
    override func setup() {
        super.setup()
        
        iconImageView.image = UIImage(named:"not_found_bg")
        descLabel.numberOfLines = 3
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel.frame = CGRectMake(50, 28.0, self.bounds.width - 100, 42)
    }
    
    
    
}