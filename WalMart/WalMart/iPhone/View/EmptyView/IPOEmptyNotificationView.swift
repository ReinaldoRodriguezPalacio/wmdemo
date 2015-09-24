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
        
        self.descLabel.text =  NSLocalizedString("notificationEmptyscreen.title",comment:"")
        
        iconImageView.image = UIImage(named:"notification_emptyscreen")
        self.returnButton.alpha = 0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone  {
            descLabel.frame = CGRectMake(0.0, 28.0, self.bounds.width, 16.0)
        } else {
            descLabel.frame = CGRectMake(0.0, 56.0, self.bounds.width, 16.0)
        }
    }
    
    
    
}