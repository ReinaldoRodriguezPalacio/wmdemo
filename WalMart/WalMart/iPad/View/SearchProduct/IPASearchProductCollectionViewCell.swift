//
//  IPASearchProductCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchProductCollectionViewCell : SearchProductCollectionViewCell {
    let widthPresale : CGFloat = 56
    
    
    override func setup() {
        super.setup()
      
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), forState: UIControlState.Normal)
        self.addProductToShopingCart!.addTarget(self, action: Selector("addProductToShoping"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.productShortDescriptionLabel!.frame = CGRectMake(8, 0, self.frame.width - 16 , 46)
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (140 / 2), self.productShortDescriptionLabel!.frame.maxY , 140, 140)
        self.productPriceThroughLabel!.frame = CGRectMake(0, self.productImage!.frame.maxY + 6 , self.bounds.width , 15)
        self.productPriceLabel!.frame = CGRectMake(0, self.productPriceThroughLabel!.frame.maxY , self.bounds.width , 30)
        self.addProductToShopingCart!.frame = CGRectMake(self.bounds.maxX - 82,self.productImage!.frame.maxY + 16 , 66 , 34)
        //self.presale.frame =  CGRectMake((self.frame.width / 2) - (widthPresale / 2),self.productImage!.frame.maxY + 3, widthPresale, 14)
    }
    

    
}