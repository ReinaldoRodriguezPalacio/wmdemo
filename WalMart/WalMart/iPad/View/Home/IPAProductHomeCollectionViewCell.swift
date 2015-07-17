//
//  IPAProductHomeCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductHomeCollectionViewCell  : ProductHomeCollectionViewCell {
    
    
    
    override func setup() {
        super.setup()
        
        productShortDescriptionLabel!.numberOfLines = 3
        
        self.productImage!.frame = CGRectMake(16, 16, self.frame.width - 32 , 116)
        
        self.productPriceLabel!.frame = CGRectMake(16, self.productImage!.frame.maxY  , self.frame.width - 32 , 14)
        
        self.productShortDescriptionLabel!.frame = CGRectMake(16, self.productPriceLabel!.frame.maxY  , self.frame.width - 32, 33)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
     
        
      
        
    }
    
        
   
    
    
    
    
}