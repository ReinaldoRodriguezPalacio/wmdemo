//
//  ProductCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductCollectionViewCell : UICollectionViewCell {
    
    var upcProduct : String?
    
    var placeHolderImage : UIImage? = nil
    
    var productImage : UIImageView? = nil
    var productShortDescriptionLabel : UILabel? = nil
    var productPriceLabel : CurrencyCustomLabel? = nil
    var hideImage : UIView!
    var completeimageaction : (() -> Void)?
    var lowStock : UILabel?
    
    
    let contentModeOrig = UIViewContentMode.ScaleAspectFit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(frame: CGRect,loadImage:(() -> Void)) {
        super.init(frame: frame)
        completeimageaction = loadImage
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    
        
        
    }
    
    
    func setup() {
    
        productImage = UIImageView()
        
        productShortDescriptionLabel = UILabel()
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel!.textColor =  WMColor.gray_reg
        productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        productPriceLabel = CurrencyCustomLabel(frame: CGRectZero)
        //productPriceLabel!.font = WMFont.fontMyriadProSemiboldSize(14)
        //productPriceLabel!.textColor = WMColor.orange
        
        lowStock = UILabel()
        lowStock!.font = WMFont.fontMyriadProRegularOfSize(12)
        lowStock!.numberOfLines = 1
        lowStock!.textColor =  WMColor.light_red
        lowStock!.hidden = true
        lowStock!.text = "Últimas piezas"
        
        self.contentView.addSubview(lowStock!)
        self.contentView.addSubview(productImage!)
        self.contentView.addSubview(productShortDescriptionLabel!)
        self.contentView.addSubview(productPriceLabel!)
    
    }
    
    func setImage (image : UIImage){
           placeHolderImage = image
        self.productImage!.image = image
    }
    
    func setValues(productImageURL:String,productShortDescription:String,productPrice:String) {
        
        
        //upcProduct = productShortDescription
        
        let formatedPrice = CurrencyCustomLabel.formatString("\(productPrice)")

        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURL(NSURL(string: productImageURL), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.productImage!.contentMode = self.contentModeOrig
                self.productImage!.image = image
                if self.completeimageaction != nil {
                    self.completeimageaction!()
                }
            }, failure: { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                if self.completeimageaction != nil {
                    self.completeimageaction!()
                }
        })

        
        productShortDescriptionLabel!.text = productShortDescription
        
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
        
        if hideImage != nil {
            hideImage.hidden = true
        }
        
    }
    
    func hideImageView() {
        if hideImage == nil {
            hideImage = UIView(frame:self.productImage!.bounds)
            hideImage.backgroundColor = UIColor.whiteColor()
            self.productImage!.addSubview(hideImage)
        }
        hideImage.hidden = false
    }
    
    func showImageView() {
        if hideImage != nil {
            hideImage.hidden = true
        }
    }
    
}

