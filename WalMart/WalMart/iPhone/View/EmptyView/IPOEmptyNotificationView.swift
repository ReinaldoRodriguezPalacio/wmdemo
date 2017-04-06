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
        self.bgImageView.image = UIImage(named:"notification_emptyscreen")
        self.descLabel.text =  NSLocalizedString("notificationEmptyscreen.title",comment:"")
        
       // self.returnButton.alpha = 0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if UIDevice.current.userInterfaceIdiom == .phone  {
            descLabel.frame = CGRect(x: 0.0, y: 28.0, width: self.bounds.width, height: 16.0)
        } else {
            descLabel.frame = CGRect(x: 0.0, y: 56.0, width: self.bounds.width, height: 16.0)
        }
    }
    
    
    
}
