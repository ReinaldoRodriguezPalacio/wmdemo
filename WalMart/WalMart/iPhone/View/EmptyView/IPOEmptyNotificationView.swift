//
//  IPOEmptyNotificationView.swift
//  WalMart
//
//  Created by Alejandro Miranda on 22/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class IPOEmptyNotificationView : IPOEmptyView {
    
    override func setup() {
        super.setup()
        
        iconImageView.image = UIImage(named:"notification_emptyscreen")
        self.returnButton.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    
}