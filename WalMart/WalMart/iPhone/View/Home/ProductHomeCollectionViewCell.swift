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
        iconDiscount.frame = CGRect(x: 8,y: 8,width: 19,height: 19)
        self.addSubview(iconDiscount)
        
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)

        productShortDescriptionLabel!.numberOfLines = 3
        
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (75 / 2), y: 15, width: 75, height: 75)
        
        self.productPriceLabel!.frame = CGRect(x: 4, y: self.productImage!.frame.maxY  , width: self.frame.width - 8 , height: 14)
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 16, y: self.productPriceLabel!.frame.maxY  , width: self.frame.width - 32, height: 33)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        
        let borderView = UIView(frame: CGRect(x: self.frame.width, y: 0, width: widthAndHeightSeparator, height: self.frame.height))
        borderView.backgroundColor = WMColor.light_light_gray
        self.addSubview(borderView)
        
        borderViewTop = UIView(frame: CGRect(x: 0,y: self.frame.height - widthAndHeightSeparator, width: self.frame.width,height: widthAndHeightSeparator ))
        borderViewTop.backgroundColor = WMColor.light_light_gray
        self.addSubview(borderViewTop)
        
    }
    
    func setValues(_ productImageURL:String,productShortDescription:String,productPrice:String,saving:String,preorderable:Bool,listPrice:Bool ) {
        super.setValues(productImageURL,productShortDescription:productShortDescription,productPrice:productPrice)
        iconDiscount.alpha = saving != "" && saving != "null" ? 1 : 0
        imagePresale.isHidden = !preorderable
        productPriceLabel!.label2?.isHidden = false
        if  saving != "" && saving != "null"  {
            productPriceLabel!.updateMount(saving, font: WMFont.fontMyriadProSemiboldSize(10), color: WMColor.green, interLine: false)
            productPriceLabel?.label1?.lineBreakMode = .byTruncatingTail
        }
        
        if listPrice {
            productPriceLabel!.label1?.textColor = WMColor.green
            productPriceLabel!.label2?.textColor = WMColor.green
        }

    }
    
}
