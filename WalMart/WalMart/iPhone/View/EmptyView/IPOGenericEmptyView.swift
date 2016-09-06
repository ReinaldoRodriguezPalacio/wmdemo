//
//  IPOGenericEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/6/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

enum IPOGenericEmptyViewKey : String {
    case Banner = "empty.productdetail.banner"
    case Text = "empty.productdetail.texto"
    case Barcode = "empty.productdetail.barras"
    case Recent = "empty.productdetail.recent"
}

struct IPOGenericEmptyViewSelected {
    static var Selected : String = "empty.productdetail.banner"
}


class IPOGenericEmptyView : IPOEmptyView {
    
    override func setup() {
        super.setup()
        
        iconImageView.image = UIImage(named:"detail_OhOh")
        
        descLabel.text = NSLocalizedString(IPOGenericEmptyViewSelected.Selected,comment:"")
        descLabel.numberOfLines = 3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel.frame = CGRectMake(50, 28.0, self.bounds.width - 100, 42)
        self.returnButton.frame = CGRectMake((self.bounds.width - 160 ) / 2, self.bounds.size.height - 140, 160 , 40)
    }
    
    
    
}