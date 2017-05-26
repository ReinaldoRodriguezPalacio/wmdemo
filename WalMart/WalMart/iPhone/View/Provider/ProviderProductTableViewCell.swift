//
//  ProviderProductTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProviderProductTableViewCell : UITableViewCell {
    
    var providerNameLabel: UILabel!
    var deliveryLabel: UILabel!
    var productPriceLabel: CurrencyCustomLabel!
    var shopButton: UIButton!
    var bottomBorder: CALayer!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        deliveryLabel = UILabel()
        deliveryLabel.font = WMFont.fontMyriadProLightOfSize(11)
        deliveryLabel.textColor = WMColor.gray
        deliveryLabel.numberOfLines = 1
        
        providerNameLabel = UILabel()
        providerNameLabel.frame = CGRect(x: 12, y: 0, width: self.bounds.width - (12 * 2), height: 40.0)
        providerNameLabel.font =  WMFont.fontMyriadProRegularOfSize(14)
        providerNameLabel.numberOfLines = 1
        providerNameLabel.textAlignment = .left
        providerNameLabel.textColor = WMColor.light_blue
        
        productPriceLabel = CurrencyCustomLabel(frame: CGRect(x: 8, y: 40 , width: self.bounds.width - 16, height: 20))
        productPriceLabel?.textAlignment = .left
        
        shopButton = UIButton()
        shopButton.backgroundColor = WMColor.yellow
        shopButton.layer.cornerRadius = 15
        shopButton.setTitleColor(UIColor.white, for: .normal)
        shopButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        shopButton.setTitle("Agregar", for: .normal)
        
        self.bottomBorder = CALayer()
        self.bottomBorder.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(bottomBorder, at: 99)
        
        self.addSubview(providerNameLabel)
        self.addSubview(deliveryLabel)
        self.addSubview(productPriceLabel!)
        self.addSubview(shopButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        providerNameLabel.frame = CGRect(x:16, y:16, width: self.bounds.width - 16, height: 15.0)
        deliveryLabel.frame = CGRect(x: 16, y:40 , width: self.bounds.width - 16, height: 12)
        productPriceLabel!.frame = CGRect(x:16, y: 65 , width: self.bounds.width - 16, height: 20)
        shopButton.frame = CGRect(x: self.frame.width - 112, y: self.frame.height - 46, width: 96, height: 32)
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.size.width, height: 1)
    }
    
    func setValues(_ provider:[String:Any]){
        
        if let providerName = provider["name"] as? String {
            providerNameLabel.text = providerName
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
