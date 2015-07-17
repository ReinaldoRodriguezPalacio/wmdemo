//
//  IPAEmptyWishlistView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/18/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAEmptyWishlistView : IPOWishlistEmptyView {
    
    override func setup() {
        super.setup()
        imageEmptyView.image = UIImage(named: "wishlist_empty")
        descLabel.textAlignment = .Center
        self.descLabel.font = WMFont.fontMyriadProLightOfSize(16.0)
        self.textLabel!.font = WMFont.fontMyriadProRegularOfSize(16.0)
        returnButton.hidden = true
    }
    
    
    override func layoutSubviews() {
        imageEmptyViewIconBtn.frame = CGRectMake(267, 142, imageEmptyViewIconBtn.image!.size.width, imageEmptyViewIconBtn.image!.size.height)
        imageEmptyView.frame = CGRectMake(0, 0, imageEmptyView.image!.size.width, imageEmptyView.image!.size.height)
        descLabel.frame = CGRectMake(175, 110, 322, 20)
        self.textLabel!.frame = CGRectMake(175, self.descLabel.frame.maxY + 12.0, 322, 16.0)
    }

    
}