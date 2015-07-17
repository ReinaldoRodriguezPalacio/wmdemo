//
//  IPODepartmentCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/3/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPODepartmentCollectionViewCell : DepartmentCollectionViewCell {
    
    override func setup() {
        super.setup()
        imageBackground.contentMode = UIViewContentMode.Left
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(16)
        
        imageBackground.frame = self.bounds
        titleLabel.frame = CGRectMake(0, 66, self.frame.width , 16)
        imageIcon.frame = CGRectMake((self.frame.width / 2) - 14, 22 , 28, 28)
        buttonClose.frame = CGRectMake(0, 0, 40, 40)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isOpen == false {
            imageBackground.frame = self.bounds
            titleLabel.frame = CGRectMake(0, 66, self.frame.width , 16)
            imageIcon.frame = CGRectMake((self.frame.width / 2) - 14, 22 , 28, 28)
            buttonClose.frame = CGRectMake(0, 0, 40, 40)
        }
    }
    
    


    
}