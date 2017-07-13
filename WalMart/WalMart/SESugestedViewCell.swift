//
//  SESugestedViewCell.swift
//  WalMart
//
//  Created by Vantis on 11/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class SESugestedViewCell: UIView {
    
    var btnProduct: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        btnProduct = UIButton()
        btnProduct.titleLabel!.font = WMFont.fontMyriadProLightOfSize(12)
        btnProduct.backgroundColor = WMColor.light_light_blue
        btnProduct.titleLabel!.textColor = UIColor.white
        btnProduct.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        btnProduct.layer.cornerRadius = 10
        self.addSubview(btnProduct)
    }
    
    func setValue(_ item: String) {
        
        btnProduct.setTitle(item, for: UIControlState())
        btnProduct.contentEdgeInsets = UIEdgeInsetsMake(5,15,5,15)
        btnProduct.sizeToFit()

        
    }
    
    
}
