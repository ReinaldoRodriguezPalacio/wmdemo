//
//  ProductTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ProductTableViewCell : SWTableViewCell {
    var placeHolderImage : UIImage? = nil
    
    var productImage : UIImageView? = nil
    var productShortDescriptionLabel : UILabel? = nil
    var productPriceLabel : CurrencyCustomLabel? = nil
    let contentModeOrig = UIViewContentMode.ScaleAspectFit
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /*override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }*/
    
    func setup() {
        
        productImage = UIImageView()
        productImage?.contentMode = UIViewContentMode.ScaleAspectFit
        
        productShortDescriptionLabel = UILabel()
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel!.textColor =  WMColor.gray
        
        productPriceLabel = CurrencyCustomLabel(frame: CGRectZero)
        //productPriceLabel!.font = WMFont.fontMyriadProSemiboldSize(14)
        //productPriceLabel!.textColor = WMColor.orange
        
        self.contentView.addSubview(productImage!)
        self.contentView.addSubview(productShortDescriptionLabel!)
        self.contentView.addSubview(productPriceLabel!)
    }
    /**
     Set image in cell from url, price and product description
     
     - parameter productImageURL:         url image
     - parameter productShortDescription: product description
     - parameter productPrice:            product price
     */
    func setValues(productImageURL:String,productShortDescription:String,productPrice:String) {
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice)
        
        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURL(NSURL(string: productImageURL), placeholderImage: UIImage(named:"img_default_table"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.productImage!.contentMode = self.contentModeOrig
            self.productImage!.image = image
            }, failure: nil)
        
        productShortDescriptionLabel!.text = productShortDescription
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
    }
    deinit {
        //print("deinit")
        self.cellScrollView.delegate = nil
    }
    
    
    
    
    
}