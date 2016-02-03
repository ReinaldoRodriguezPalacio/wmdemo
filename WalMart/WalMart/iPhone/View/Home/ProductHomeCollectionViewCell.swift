//
//  ProductHomeCollectionVIewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ProductHomeCollectionViewCell : ProductCollectionViewCell {
    
    var borderViewTop : UIView!
    var iconDiscount : UIImageView!
    var imagePresale : UIImageView!
    
    
    override func setup() {
        super.setup()
        
        iconDiscount = UIImageView(image:UIImage(named:"saving_icon"))
        iconDiscount.frame = CGRectMake(8,8,19,19)
        self.addSubview(iconDiscount)
        
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.hidden =  true
        self.addSubview(imagePresale)

        productShortDescriptionLabel!.numberOfLines = 3
        
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (75 / 2), 15, 75, 75)
        
        self.productPriceLabel!.frame = CGRectMake(4, self.productImage!.frame.maxY  , self.frame.width - 8 , 14)
        
        self.productShortDescriptionLabel!.frame = CGRectMake(16, self.productPriceLabel!.frame.maxY  , self.frame.width - 32, 33)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        
        let borderView = UIView(frame: CGRectMake(self.frame.width, 0, widthAndHeightSeparator, self.frame.height))
        borderView.backgroundColor = WMColor.lineSaparatorColor
        self.addSubview(borderView)
        
        borderViewTop = UIView(frame: CGRectMake(0,self.frame.height - widthAndHeightSeparator, self.frame.width,widthAndHeightSeparator ))
        borderViewTop.backgroundColor = WMColor.lineSaparatorColor
        self.addSubview(borderViewTop)
        
    }
    
    func setValues(productImageURL:String,productShortDescription:String,productPrice:String,saving:String,preorderable:Bool,listPrice:Bool ) {
        super.setValues(productImageURL,productShortDescription:productShortDescription,productPrice:productPrice)
        iconDiscount.alpha = saving != "" && saving != "null" ? 1 : 0
        imagePresale.hidden = !preorderable
        productPriceLabel!.label2?.hidden = false
        if  saving != "" && saving != "null"  {
            productPriceLabel!.updateMount(saving, font: WMFont.fontMyriadProSemiboldSize(10), color: WMColor.green, interLine: false)
            productPriceLabel!.label2?.hidden = true
            productPriceLabel?.label1?.lineBreakMode = .ByTruncatingTail
        }
        if listPrice {
            productPriceLabel!.label1?.textColor = WMColor.green
            productPriceLabel!.label2?.textColor = WMColor.green
        }

    }
    
}