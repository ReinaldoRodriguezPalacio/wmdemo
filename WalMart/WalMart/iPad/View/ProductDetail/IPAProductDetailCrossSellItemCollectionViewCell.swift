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
        
        self.productImage!.frame = CGRect(x: 16, y: 0,  width: self.frame.width - 32, height: 126)
        
        self.productPriceLabel!.frame = CGRect(x: 16, y: self.productImage!.frame.maxY + 2 , width: self.frame.width - 32 , height: 14)
        //self.productPriceLabel!.textAlignment = .Center
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 16, y: self.productPriceLabel!.frame.maxY   , width: self.frame.width - 32, height: 36)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
  

    
    
}
