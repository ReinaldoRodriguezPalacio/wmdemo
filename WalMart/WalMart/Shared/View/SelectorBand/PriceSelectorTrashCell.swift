//
//  PriceSelectorTrashCell.swift
//  WalMart
//
//  Created by neftali on 12/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class PriceSelectorTrashCell: UICollectionViewCell {

    var icon: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.icon = UIImageView(frame: CGRectMake(0.0, 0.0, frame.size.width, frame.size.height))
        self.icon!.image = UIImage(named: "cart_delete")
        self.contentView.addSubview(self.icon!)
    }

}
