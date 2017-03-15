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
    let contentModeOrig = UIViewContentMode.scaleAspectFit
    
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
        productImage?.contentMode = UIViewContentMode.scaleAspectFit
        
        productShortDescriptionLabel = UILabel()
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel!.textColor =  WMColor.gray
        
        productPriceLabel = CurrencyCustomLabel(frame: CGRect.zero)
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
    func setValues(_ productImageURL:String,productShortDescription:String,productPrice:String) {
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        
        self.productImage!.contentMode = self.contentModeOrig
        self.productImage!.setImageWith(URL(string: productImageURL)!, placeholderImage: UIImage(named:"img_default_table"))        
        productShortDescriptionLabel!.text = productShortDescription
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
    }
    deinit {
        //print("deinit")
        self.cellScrollView.delegate = nil
    }
    
    
    
    
    
}
