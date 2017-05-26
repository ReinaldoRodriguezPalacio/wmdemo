//
//  ProviderProductHeaderView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProviderProductHeaderView: UIView {
    
    var productImage: UIImageView!
    var productDescriptionLabel: UILabel!
    var productTypeLabel: UILabel!
    var bottomBorder: CALayer!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.white
     
        productImage = UIImageView()
        productImage?.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(productImage!)
        
        productDescriptionLabel = UILabel()
        productDescriptionLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        productDescriptionLabel.textAlignment = .left
        productDescriptionLabel.textColor = WMColor.dark_gray
        productDescriptionLabel.numberOfLines = 2
        self.addSubview(productDescriptionLabel!)
        
        productTypeLabel = UILabel()
        productTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        productTypeLabel.textAlignment = .left
        productTypeLabel.textColor = WMColor.dark_gray
        self.addSubview(productTypeLabel!)
        
        self.bottomBorder = CALayer()
        self.bottomBorder.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(bottomBorder, at: 99)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let productDescriptionSize = productDescriptionLabel.text!.size(attributes: [NSFontAttributeName: productDescriptionLabel!.font])
        let productDescriptionWidth: CGFloat = self.frame.width - (productImage.frame.maxX + 32)
        let productDescriptionHeight: CGFloat = (productDescriptionWidth - productDescriptionSize.width) > 0 ? 15 : 30
        productImage.frame = CGRect(x: 16, y: 16, width: 56, height: 56)
        productDescriptionLabel.frame = CGRect(x: productImage.frame.maxX + 16, y: 22, width: productDescriptionWidth, height: productDescriptionHeight)
        productTypeLabel.frame = CGRect(x: productImage.frame.maxX + 16, y: productDescriptionLabel.frame.maxY + 4, width: self.frame.width - (productImage.frame.maxX + 32), height: 15)
        self.bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.size.width, height: 1)
    }
    
    
    func setValues(_ productImageURL:String,productShortDescription:String,productType:String) {
        
        
        self.productImage!.setImageWith(URL(string: productImageURL)!, placeholderImage: UIImage(named:"img_default_table"))
        self.productDescriptionLabel!.text = productShortDescription
        self.productTypeLabel!.text = productType
    }
}
