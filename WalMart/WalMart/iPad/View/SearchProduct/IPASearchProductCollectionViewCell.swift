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
        
        self.addProductToShopingCart!.setImage(UIImage(named: "productToShopingCart"), for: UIControlState())
        self.addProductToShopingCart!.addTarget(self, action: Selector("addProductToShoping"), for: UIControlEvents.touchUpInside)
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 8, y: 0, width: self.frame.width - 16 , height: 46)
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (140 / 2), y: self.productShortDescriptionLabel!.frame.maxY , width: 140, height: 140)
        self.productPriceThroughLabel!.frame = CGRect(x: 0, y: self.productImage!.frame.maxY + 6 , width: self.bounds.width , height: 15)
        self.productPriceLabel!.frame = CGRect(x: 0, y: self.productPriceThroughLabel!.frame.maxY , width: self.bounds.width , height: 30)
        self.addProductToShopingCart!.frame = CGRect(x: self.bounds.maxX - 82,y: self.productImage!.frame.maxY + 16 , width: 66 , height: 34)
        //self.presale.frame =  CGRectMake((self.frame.width / 2) - (widthPresale / 2),self.productImage!.frame.maxY + 3, widthPresale, 14)
    }
    

    
}
