//
//  ProviderViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 24/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class ProviderViewCell : UICollectionViewCell {
    
    var titleLabel = UILabel()
    var deliveryLabel = UILabel()
    var priceProduct : NSString!
    var productPriceLabel : CurrencyCustomLabel? = nil
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = WMColor.light_gray
        self.layer.cornerRadius = 5
        
        deliveryLabel.font = WMFont.fontMyriadProLightOfSize(11)
        deliveryLabel.textColor = WMColor.gray
        deliveryLabel.numberOfLines = 1
        
        titleLabel.frame = CGRect(x: 12, y: 0, width: self.bounds.width - (12 * 2), height: 40.0)
        titleLabel.font =  WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.textColor = WMColor.light_blue
        
        productPriceLabel = CurrencyCustomLabel(frame: CGRect(x: 8, y: 40 , width: self.bounds.width - 16, height: 20))
        productPriceLabel?.textAlignment = .left
        
        self.addSubview(titleLabel)
        self.addSubview(deliveryLabel)
        self.addSubview(productPriceLabel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x:8, y:16, width: self.bounds.width - 16, height: 15.0)
        productPriceLabel!.frame = CGRect(x: 8, y: 40 , width: self.bounds.width - 16, height: 20)
        deliveryLabel.frame = CGRect(x: 8, y: 65, width: self.bounds.width - 16, height: 12)
    }
    
    func setValues(_ provider:[String:Any]){
        
        
        if let providerName = provider["name"] as? String {
            titleLabel.text = providerName
        }
        
        if let delibery = provider["deliberyTime"] as? String {
            deliveryLabel.text = "entrega entre \(delibery)"
        }
        
        if let price = provider["price"] as? String {
            let formatedPrice = CurrencyCustomLabel.formatString(price as NSString)
           self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.orange, interLine: false)
        }
    }
}
