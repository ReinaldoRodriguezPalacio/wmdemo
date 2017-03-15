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
        
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (75 / 2), y: 15, width: 75, height: 75)
        
        imageShoppingCart = UIImageView(image: UIImage(named: "ProductToShopingCart"))
        imageShoppingCart.frame = CGRect(x: (75 / 2) - (24 / 2), y: 75 - 24, width: 24, height: 24)
        self.productImage!.addSubview(imageShoppingCart)
        
        self.productPriceLabel!.frame = CGRect(x: 4, y: self.productImage!.frame.maxY  + 10 , width: self.frame.width - 8 , height: 14)
        //self.productPriceLabel!.textAlignment = .Center
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 4, y: self.productPriceLabel!.frame.maxY  , width: self.frame.width - 8, height: 44)
        self.productShortDescriptionLabel!.textAlignment = .center
        self.productShortDescriptionLabel!.numberOfLines = 3
        
        
    }
    
    
    func setValues(_ productImageURL:String,productShortDescription:String,productPrice:String,grayScale:Bool) {
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        
        let request = NSMutableURLRequest(url: URL(string: productImageURL)!)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        
        self.productImage!.contentMode = self.contentModeOrig
        self.productImage!.setImage(with: URL(string: productImageURL)!, and: UIImage(named:"img_default_cell"), success: { (image) in
            if grayScale == true {
                self.productImage!.image = self.convertImageToGrayScale(image)
            } else {
                self.productImage!.image = image
            }
        }, failure: {})

        productShortDescriptionLabel!.text = productShortDescription

        if grayScale {
            productShortDescriptionLabel?.textColor = UIColor.lightGray
            productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: UIColor.lightGray, interLine: false)
            imageShoppingCart.image = UIImage(named: "cart_desabled")
        } else {
            productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
            imageShoppingCart.image = UIImage(named: "ProductToShopingCart")
        }
        
    }
    
    func convertImageToGrayScale(_ image:UIImage) -> UIImage {
        
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo().rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context?.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
    
}
