//
//  IPAShoppingCartEmptyView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 12/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPAShoppingCartEmptyView: IPOShoppingCartEmptyView {
   

    override func layoutSubviews() {
        super.layoutSubviews()
        self.returnButton.frame = CGRectMake((self.bounds.width - 160 ) / 2, self.bounds.height - 85, 160 , 40)
        iconImageView.frame = CGRectMake(0.0, 0.0,  self.bounds.width,  self.bounds.height)//  self.bounds.height)
    }
    
}
