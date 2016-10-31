//
//  ProductDetailCrossSellItemCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailCrossSellItemCollectionViewCell : ProductCollectionViewCell {
    
    
    override func setup() {
        super.setup()
        
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (75 / 2), y: 0, width: 75, height: 75)
        
        self.productPriceLabel!.frame = CGRect(x: 4, y: self.productImage!.frame.maxY  , width: self.frame.width - 8 , height: 14)
        //self.productPriceLabel!.textAlignment = .Center
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 4, y: self.productPriceLabel!.frame.maxY + 7 , width: self.frame.width - 8, height: 36)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
}
