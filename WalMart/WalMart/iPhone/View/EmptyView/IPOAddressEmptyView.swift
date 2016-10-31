//
//  IPOAddressEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/2/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOAddressEmptyView : IPOEmptyView {
    
    override func setup() {
        super.setup()
        
        iconImageView.image = UIImage(named:"empty_adress")
        descLabel.text = NSLocalizedString("empty.address",comment:"")
        descLabel.numberOfLines = 0
        
        returnButton.backgroundColor = WMColor.green
        returnButton.setTitle(NSLocalizedString("profile.address.new",comment:""), for: UIControlState())
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
