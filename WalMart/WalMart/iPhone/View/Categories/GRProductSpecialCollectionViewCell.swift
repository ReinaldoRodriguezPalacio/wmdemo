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
        
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (64 / 2), y: 8, width: 64, height: 64)
        
        self.productPriceLabel!.frame = CGRect(x: 4, y: self.productImage!.frame.maxY  , width: self.frame.width - 8 , height: 14)
        self.productPriceLabel!.alpha = 0
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 16, y: self.productPriceLabel!.frame.maxY - 14 , width: self.frame.width - 32, height: 33)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        
        //let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
    }
    
    
    
    
    
}
