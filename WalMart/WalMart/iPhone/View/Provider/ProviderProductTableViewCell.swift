//
//  ProviderProductTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol ProviderProductTableViewCellDelegate: class {
    func selectQuantityForItem(cell:ProviderProductTableViewCell,productInCart:Cart?)
}

class ProviderProductTableViewCell : UITableViewCell {
    
    var providerNameLabel: UILabel!
    var deliveryLabel: UILabel!
    var productPriceLabel: CurrencyCustomLabel!
    var shopButton: UIButton!
    var bottomBorder: CALayer!
    var delegate: ProviderProductTableViewCellDelegate?
    var upc: String! = ""
    var productPrice: NSNumber?
    var quantity: NSNumber! = 0
    var onHandInventory: NSNumber! = 99
    
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
        shopButton.setTitle(NSLocalizedString("productdetail.shop",comment:""), for: .normal)
        shopButton.addTarget(self, action: #selector(selectQuantity), for: .touchUpInside)
        
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
    
    func selectQuantity() {
        let productincar = UserCurrentSession.sharedInstance.userHasQuantityUPCShoppingCart(upc)
        delegate?.selectQuantityForItem(cell: self, productInCart: productincar)
    }
    
    func setValues(_ provider:[String:Any]){
        
        self.upc = provider["offerId"] as! String
        
        if let providerName = provider["name"] as? String {
            providerNameLabel.text = providerName
        }
        
        if let delibery = provider["shipping"] as? String {
            deliveryLabel.text = delibery
        }
        
        if let price = provider["price"] as? NSString {
            self.productPrice = price.doubleValue as NSNumber
            let formatedPrice = CurrencyCustomLabel.formatString(price)
            self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.orange, interLine: false)
        }
        
        if let price = provider["onHandInventory"] as? NSString {
            self.onHandInventory = price.intValue as NSNumber
        }
        
        let productincar = UserCurrentSession.sharedInstance.userHasQuantityUPCShoppingCart(upc)
        var text = NSLocalizedString("productdetail.shop",comment:"")
        quantity = 0
        
        if productincar != nil && productincar?.quantity != 0 {
            quantity = productincar!.quantity
            if quantity.int32Value == 1 {
                text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
            }
            else {
                text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
                
            }
        }
        shopButton.setTitle(text, for: .normal)
    }
}
