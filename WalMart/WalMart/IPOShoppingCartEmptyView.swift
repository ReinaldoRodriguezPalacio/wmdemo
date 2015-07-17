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
        
        if IS_IPHONE_4_OR_LESS == true {
            self.addSubview(returnButton)
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel.frame = CGRectMake(0.0, 60.0, self.bounds.width, 16.0)
        if IS_IPHONE_4_OR_LESS == true {
              self.returnButton.frame = CGRectMake((self.bounds.width - 160 ) / 2, self.bounds.height - 100, 160 , 40)
        }
        
    }
    
}