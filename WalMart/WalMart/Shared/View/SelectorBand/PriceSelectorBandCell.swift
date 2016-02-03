//
//  PriceSelectorBandCell.swift
//  WalMart
//
//  Created by neftali on 12/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class PriceSelectorBandCell: SelectorBandCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label!.textColor = UIColor.whiteColor()
    }

}
