//
//  IPAProductDetailCrossSellItemCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPAProductDetailCrossSellItemCollectionViewCell : ProductCollectionViewCell {
    
    
    override func setup() {
        super.setup()
        
        self.productImage!.frame = CGRectMake(16, 0,  self.frame.width - 32, 126)
        
        self.productPriceLabel!.frame = CGRectMake(16, self.productImage!.frame.maxY + 2 , self.frame.width - 32 , 14)
        //self.productPriceLabel!.textAlignment = .Center
        
        self.productShortDescriptionLabel!.frame = CGRectMake(16, self.productPriceLabel!.frame.maxY   , self.frame.width - 32, 36)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
  

    
    
}