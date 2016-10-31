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
    
    let contentModeOrig = UIViewContentMode.scaleAspectFit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(frame: CGRect,loadImage:@escaping (() -> Void)) {
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
        productShortDescriptionLabel!.textColor =  WMColor.reg_gray
        productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        productPriceLabel = CurrencyCustomLabel(frame: CGRect.zero)
        //productPriceLabel!.font = WMFont.fontMyriadProSemiboldSize(14)
        //productPriceLabel!.textColor = WMColor.orange
    
        self.contentView.addSubview(productImage!)
        self.contentView.addSubview(productShortDescriptionLabel!)
        self.contentView.addSubview(productPriceLabel!)
    
    }
    
    func setImage (_ image : UIImage){
           placeHolderImage = image
        self.productImage!.image = image
    }
    
    func setValues(_ productImageURL:String,productShortDescription:String,productPrice:String) {
        
        
        //upcProduct = productShortDescription
        
        let formatedPrice = CurrencyCustomLabel.formatString("\(productPrice)")

        self.productImage!.contentMode = UIViewContentMode.center
        self.productImage!.setImageWith(URL(string: productImageURL), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:URLRequest!, response:HTTPURLResponse!, image:UIImage!) -> Void in
                self.productImage!.contentMode = self.contentModeOrig
                self.productImage!.image = image
                if self.completeimageaction != nil {
                    self.completeimageaction!()
                }
            }, failure: { (request:URLRequest!, response:HTTPURLResponse!, error:NSError!) -> Void in
                if self.completeimageaction != nil {
                    self.completeimageaction!()
                }
        })

        
        productShortDescriptionLabel!.text = productShortDescription
        
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
        
        if hideImage != nil {
            hideImage.isHidden = true
        }
        
    }
    
    func hideImageView() {
        if hideImage == nil {
            hideImage = UIView(frame:self.productImage!.bounds)
            hideImage.backgroundColor = UIColor.white
            self.productImage!.addSubview(hideImage)
        }
        hideImage.isHidden = false
    }
    
    func showImageView() {
        if hideImage != nil {
            hideImage.isHidden = true
        }
    }
    
}

