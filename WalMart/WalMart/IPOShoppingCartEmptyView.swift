//
//  IPOShoppingCartEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/2/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOShoppingCartEmptyView : IPOEmptyView {
    
    override func setup() {
        super.setup()
        iconImageView.image = UIImage(named:"empty_cart")
        descLabel.text = NSLocalizedString("empty.shoppingcart",comment:"")
        returnButton.setTitle( NSLocalizedString("noti.keepshopping",comment:"") , for: UIControlState())
        
        if IS_IPHONE_4_OR_LESS == true {
            self.addSubview(returnButton)
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel.frame = CGRect(x: 0.0, y: 25.0, width: self.bounds.width, height: 16.0)
        if IS_IPHONE_4_OR_LESS == true {
              self.returnButton.frame = CGRect(x: (self.bounds.width - 160 ) / 2, y: self.bounds.height - 100, width: 160 , height: 40)
        }
        
    }
    
}
