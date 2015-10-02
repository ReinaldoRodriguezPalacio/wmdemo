//
//  IPOWishlistEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/2/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOWishlistEmptyView : IPOEmptyView {
    
    
    var imageEmptyView = UIImageView()
    var imageEmptyViewIconBtn = UIImageView()
    var textLabel: UILabel?
    
    override func setup() {
        super.setup()
        
        //iconImageView.image = UIImage(named:"empty_list")
        iconImageView.hidden = true
        
        imageEmptyView = UIImageView(image: UIImage(named: "empty_wishlist"))
        self.insertSubview(imageEmptyView, atIndex: 0)
        
        imageEmptyViewIconBtn = UIImageView(image: UIImage(named: "empty_wishlist_icon"))
        self.addSubview(imageEmptyViewIconBtn)
        
        self.descLabel.text = NSLocalizedString("empty.wishlist.title",comment:"")
        self.descLabel.numberOfLines = 0
        self.descLabel.textColor = WMColor.UIColorFromRGB(0x2870c9)
        self.descLabel.font = WMFont.fontMyriadProLightOfSize(14.0)
        
        self.textLabel = UILabel()
        self.textLabel!.textAlignment = .Center
        self.textLabel!.textColor = WMColor.UIColorFromRGB(0x2870c9)
        self.textLabel!.font = WMFont.fontMyriadProRegularOfSize(14.0)
        self.textLabel!.text = NSLocalizedString("empty.wishlist.text", comment:"")
        self.addSubview(self.textLabel!)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel!.frame = CGRectMake(0.0, self.descLabel.frame.maxY + 12.0, self.frame.width, 16.0)
        //var size = self.imageEmptyViewIconBtn.image!.size
        self.imageEmptyViewIconBtn.frame = CGRectMake(98.0, self.descLabel!.frame.maxY + 12.0, 16.0, 16.0)
    }
    
}