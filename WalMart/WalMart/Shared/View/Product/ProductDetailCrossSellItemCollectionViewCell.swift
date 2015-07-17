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
        
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (75 / 2), 0, 75, 75)
        
        self.productPriceLabel!.frame = CGRectMake(4, self.productImage!.frame.maxY  , self.frame.width - 8 , 14)
        //self.productPriceLabel!.textAlignment = .Center
        
        self.productShortDescriptionLabel!.frame = CGRectMake(4, self.productPriceLabel!.frame.maxY + 7 , self.frame.width - 8, 36)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
}