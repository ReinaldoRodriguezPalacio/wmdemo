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
        
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (75 / 2), y: 15, width: 75, height: 75)

        
        self.productShortDescriptionLabel!.frame = CGRect(x: 4, y: self.productImage!.frame.maxY + 7 , width: self.frame.width - 8, height: 36)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
    
    func setValues(_ productImageURL: String, productShortDescription: String) {
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: "")
         self.productPriceLabel?.isHidden = true
    }
    
    
}
