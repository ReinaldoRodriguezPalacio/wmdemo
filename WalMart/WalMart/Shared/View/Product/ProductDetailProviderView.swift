//
//  ProductDetailProviderView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 23/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailProviderView: UIView {
    
    var providerLabel: UILabel!
    var ratingLabel: UILabel!
    var deliberyLabel:UILabel!
    var otherProvidersLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        providerLabel = UILabel()
        providerLabel.textColor = WMColor.light_blue
        providerLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        providerLabel.textAlignment = .center
        self.addSubview(providerLabel!)
        
        deliberyLabel = UILabel()
        deliberyLabel.textColor = WMColor.gray
        deliberyLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        deliberyLabel.textAlignment = .center
        self.addSubview(deliberyLabel!)
        
        otherProvidersLabel = UILabel()
        otherProvidersLabel.textColor = WMColor.gray
        otherProvidersLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        otherProvidersLabel.textAlignment = .center
        self.addSubview(otherProvidersLabel!)
        
        ratingLabel = UILabel()
        ratingLabel.textColor = UIColor.white
        ratingLabel.font = WMFont.fontMyriadProRegularOfSize(9)
        ratingLabel.backgroundColor = WMColor.light_blue
        ratingLabel.layer.cornerRadius = 2
        ratingLabel.textAlignment = .center
        ratingLabel.clipsToBounds = true
        self.addSubview(ratingLabel!)
        
    }
    
    func setValues(provider: [String:Any]){
        
        if let providerName = provider["name"] as? String {
            providerLabel.text = "Vendido por \(providerName)                "
        }
        
        if let delibery = provider["deliberyTime"] as? String {
            deliberyLabel.text = "entrega entre \(delibery)"
        }
        
        if let otherProviders = provider["otherProviders"] as? String {
            otherProvidersLabel.text = "Disponible en otros precios y otros \(otherProviders) proveedores"
        }
        
        if let rating = provider["rating"] as? Double {
            ratingLabel.text = "\(rating) de 5 *"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        providerLabel.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: 22)
        deliberyLabel.frame = CGRect(x: 0.0, y: providerLabel.frame.maxY, width: self.frame.width, height: 22)
        otherProvidersLabel.frame = CGRect(x: 0.0, y: deliberyLabel.frame.maxY, width: self.frame.width, height: 22)
        ratingLabel.frame = CGRect(x: self.frame.width - 172.0 , y: 3.0, width: 50, height: 16)
    }

}
