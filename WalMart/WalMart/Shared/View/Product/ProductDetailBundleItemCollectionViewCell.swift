//
//  ProductDetailBundleItemCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailBundleItemCollectionViewCell : ProductCollectionViewCell {
    
    
    override func setup() {
        super.setup()
        
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (75 / 2), 15, 75, 75)

        
        self.productShortDescriptionLabel!.frame = CGRectMake(4, self.productImage!.frame.maxY + 7 , self.frame.width - 8, 36)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
    
    func setValues(productImageURL: String, productShortDescription: String) {
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: "")
         self.productPriceLabel?.hidden = true
    }
    
    
}