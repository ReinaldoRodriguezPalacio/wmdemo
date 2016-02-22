//
//  ShoppingCartCrossSellItemCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShoppingCartCrossSellItemCollectionViewCell : ProductCollectionViewCell {
    
    var imageShoppingCart : UIImageView!
    
    override func setup() {
        super.setup()
        
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (75 / 2), 15, 75, 75)
        
        imageShoppingCart = UIImageView(image: UIImage(named: "ProductToShopingCart"))
        imageShoppingCart.frame = CGRectMake((75 / 2) - (24 / 2), 75 - 24, 24, 24)
        self.productImage!.addSubview(imageShoppingCart)
        
        self.productPriceLabel!.frame = CGRectMake(4, self.productImage!.frame.maxY  + 10 , self.frame.width - 8 , 14)
        //self.productPriceLabel!.textAlignment = .Center
        
        self.productShortDescriptionLabel!.frame = CGRectMake(4, self.productPriceLabel!.frame.maxY  , self.frame.width - 8, 44)
        self.productShortDescriptionLabel!.textAlignment = .Center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
    
    func setValues(productImageURL:String,productShortDescription:String,productPrice:String,grayScale:Bool) {
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice)
        
        let request = NSMutableURLRequest(URL: NSURL(string: productImageURL)!)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        
        self.productImage!.contentMode = UIViewContentMode.Center
        
        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURL(NSURL(string: productImageURL), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.productImage!.contentMode = self.contentModeOrig
            if grayScale == true {
                self.productImage!.image = self.convertImageToGrayScale(image)
            } else {
                self.productImage!.image = image
            }
            
            }, failure: nil)
        
        productShortDescriptionLabel!.text = productShortDescription
        
        
        if grayScale {
            productShortDescriptionLabel?.textColor = UIColor.lightGrayColor()
            productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: UIColor.lightGrayColor(), interLine: false)
            imageShoppingCart.image = UIImage(named: "cart_desabled")
        } else {
            productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
            imageShoppingCart.image = UIImage(named: "ProductToShopingCart")
        }
        
    }
    
    func convertImageToGrayScale(image:UIImage) -> UIImage {
        
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, 0, colorSpace, CGBitmapInfo().rawValue)
        CGContextDrawImage(context, imageRect,image.CGImage)
        let imageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: imageRef!)
        return newImage
    }
    
}