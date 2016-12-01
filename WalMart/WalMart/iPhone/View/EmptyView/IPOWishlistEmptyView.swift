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
        iconImageView.isHidden = true
        
        imageEmptyView = UIImageView(image: UIImage(named: "empty_wishlist"))
        self.insertSubview(imageEmptyView, at: 0)
        
        imageEmptyViewIconBtn = UIImageView(image: UIImage(named: "empty_wishlist_icon"))
        self.addSubview(imageEmptyViewIconBtn)
        
        self.descLabel.text = NSLocalizedString("empty.wishlist.title",comment:"")
        self.descLabel.numberOfLines = 0
        self.descLabel.textColor = WMColor.light_blue
        self.descLabel.font = WMFont.fontMyriadProLightOfSize(14.0)
        
        self.textLabel = UILabel()
        self.textLabel!.textAlignment = .center
        self.textLabel!.textColor = WMColor.light_blue
        self.textLabel!.font = WMFont.fontMyriadProRegularOfSize(14.0)
        self.textLabel!.text = NSLocalizedString("empty.wishlist.text", comment:"")
        self.addSubview(self.textLabel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel!.frame = CGRect(x: 0.0, y: self.descLabel.frame.maxY + 12.0, width: self.frame.width, height: 16.0)
        //var size = self.imageEmptyViewIconBtn.image!.size
        self.imageEmptyViewIconBtn.frame = CGRect(x: 98.0, y: self.descLabel!.frame.maxY + 12.0, width: 16.0, height: 16.0)
    }
    
    override func returnActionSel() {
        super.returnActionSel()
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST_EMPTY.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST_EMPTY.rawValue, action: WMGAIUtils.ACTION_BACK_MY_LIST.rawValue, label: "")
    }
    
}
