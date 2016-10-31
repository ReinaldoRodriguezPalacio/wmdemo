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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        imageView = UIImageView()
        imageView.image = UIImage(named:"img_default_cell")
        imageView.frame =  CGRect(x: 0, y: 24 ,width: self.bounds.width, height: self.bounds.height - 48 )
        //imageView.frame = self.bounds
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame =  CGRect(x: 0, y: 24 ,width: self.bounds.width, height: self.bounds.height - 48 )
    }

    
}
