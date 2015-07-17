//
//  ProductDetailBannerMediaCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailBannerMediaCollectionViewCell : UICollectionViewCell {
    var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        imageView = UIImageView()
        imageView.frame =  CGRectMake(0, 12 ,self.bounds.width, self.bounds.height - 24 )
        //imageView.frame = self.bounds
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame =  CGRectMake(0, 12 ,self.bounds.width, self.bounds.height - 24 )
    }

    
}