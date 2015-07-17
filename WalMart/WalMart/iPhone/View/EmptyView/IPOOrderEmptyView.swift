//
//  IPOOrderEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/2/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOOrderEmptyView : IPOEmptyView {
    
    override func setup() {
        super.setup()
        iconImageView.image = UIImage(named:"empty_orders")
        descLabel.text = NSLocalizedString("empty.orders",comment:"")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }    
}