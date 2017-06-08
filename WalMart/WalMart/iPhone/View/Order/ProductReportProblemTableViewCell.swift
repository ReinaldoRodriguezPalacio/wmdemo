//
//  ProductReportProblemTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 08/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class ProductReportProblemTableViewCell: ProductTableViewCell {
    
    var providerLabel: UILabel!
    var quantityLabel: UILabel!
    var separatorLayer: CALayer!
    
    override func setup() {
        super.setup()
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 16, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        
        separatorLayer = CALayer()
        separatorLayer.backgroundColor = WMColor.light_light_gray.cgColor
        
        providerLabel = UILabel()
        providerLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        providerLabel.textColor = WMColor.dark_gray
        providerLabel.textAlignment = .left
        
        quantityLabel = UILabel()
        quantityLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        quantityLabel.textColor = WMColor.dark_gray
        quantityLabel.textAlignment = .left
        
        self.addSubview(providerLabel)
        self.addSubview(quantityLabel)
        self.layer.addSublayer(separatorLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 16, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        providerLabel.frame = CGRect(x: productImage!.frame.maxX + 16, y: productShortDescriptionLabel!.frame.maxY + 16,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 12)
        quantityLabel.frame = CGRect(x: productImage!.frame.maxX + 16, y: providerLabel!.frame.maxY,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 12)
        productPriceLabel!.frame = CGRect(x: self.frame.width - 86, y: productShortDescriptionLabel!.frame.maxY + 16,width: 70, height: 24)
        separatorLayer.frame = CGRect(x: 0, y: self.frame.height - 1,width: self.frame.width, height: 1)
    }
    
    func setValues(productImageURL:String,productShortDescription:String,productPrice:String,quantity:NSString,provider: String) {
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        let attrsBold = [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName: WMColor.dark_gray] as [String : Any]
        let attrsNormal = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName: WMColor.dark_gray] as [String : Any]
        
        var boldString = NSMutableAttributedString(string:"Proveedor - ", attributes:attrsBold)
        var normalString = NSMutableAttributedString(string: "\(provider)", attributes: attrsNormal)
        boldString.append(normalString)
        
        self.providerLabel.attributedText = boldString
        
        boldString = NSMutableAttributedString(string:"Artículos - ", attributes:attrsBold)
        normalString = NSMutableAttributedString(string: "\(quantity.intValue)", attributes: attrsNormal)
        boldString.append(normalString)
        
        self.quantityLabel.attributedText = boldString
        
         let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
    }
    
}
