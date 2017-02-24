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
        self.bgImageView.image = UIImage(named: "wishlist_empty")
        descLabel.textAlignment = .center
        self.descLabel.font = WMFont.fontMyriadProLightOfSize(16.0)
        self.textLabel!.font = WMFont.fontMyriadProRegularOfSize(16.0)
        returnButton.isHidden = true
    }
    
    
    override func layoutSubviews() {
        imageEmptyViewIconBtn.frame = CGRect(x: 267, y: 142, width: imageEmptyViewIconBtn.image!.size.width, height: imageEmptyViewIconBtn.image!.size.height)
        bgImageView.frame = CGRect(x: 0, y: 0, width: bgImageView.image!.size.width, height: bgImageView.image!.size.height)
        descLabel.frame = CGRect(x: 175, y: 110, width: 322, height: 20)
        self.textLabel!.frame = CGRect(x: 175, y: self.descLabel.frame.maxY + 12.0, width: 322, height: 16.0)
    }

    
}
