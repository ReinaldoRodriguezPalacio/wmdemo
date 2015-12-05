//
//  GRProductSpecialCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 07/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRProductSpecialCollectionViewCell : ProductCollectionViewCell {
    
    
    var jsonItemSelected : JSON!
    
    override func setup() {
        super.setup()
        
        productShortDescriptionLabel!.numberOfLines = 3
        
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (64 / 2), 8, 64, 64)
        
        self.productPriceLabel!.frame = CGRectMake(4, self.productImage!.frame.maxY  , self.frame.width - 8 , 14)
        self.productPriceLabel!.alpha = 0
        
        self.productShortDescriptionLabel!.frame = CGRectMake(16, self.productPriceLabel!.frame.maxY - 14 , self.frame.width - 32, 33)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        
        //let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
    }
    
    
    
    
    
}