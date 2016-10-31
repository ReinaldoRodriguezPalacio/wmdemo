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
        
        self.productImage!.frame = CGRect(x: 16, y: 16, width: self.frame.width - 32 , height: 116)
        
        self.productPriceLabel!.frame = CGRect(x: 16, y: self.productImage!.frame.maxY  , width: self.frame.width - 32 , height: 14)
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 16, y: self.productPriceLabel!.frame.maxY  , width: self.frame.width - 32, height: 33)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
     
        
      
        
    }
    
        
   
    
    
    
    
}
