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
        self.clipsToBounds = true
        bgImageView.image = UIImage(named:"not_found_bg")
        descLabel.numberOfLines = 3
        bgImageView.clipsToBounds = true 
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel.frame = CGRect(x: 50, y: (IS_IPAD ? 78.0 : 28.0), width: self.bounds.width - 100, height: 42)
    }
    
    
    
}
