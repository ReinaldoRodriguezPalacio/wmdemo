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
        //imageBackground.contentMode = UIViewContentMode.left
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(16)
        
        imageBackground.frame = self.bounds
        titleLabel.frame = CGRect(x: 0, y: 66, width: self.frame.width , height: 16)
        imageIcon.frame = CGRect(x: (self.frame.width / 2) - 14, y: 22 , width: 28, height: 28)
        buttonClose.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isOpen == false {
            imageBackground.frame = self.bounds
            titleLabel.frame = CGRect(x: 0, y: 66, width: self.frame.width , height: 16)
            imageIcon.frame = CGRect(x: (self.frame.width / 2) - 14, y: 22 , width: 28, height: 28)
            buttonClose.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        }
    }
    
    


    
}
