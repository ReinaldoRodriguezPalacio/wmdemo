//
//  ProductDetrailNavCollectionReusableView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/4/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetrailNavCollectionReusableView : UICollectionReusableView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.gray
    }
}
