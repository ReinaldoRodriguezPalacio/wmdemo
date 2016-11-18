//
//  BannerDetailCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class BannerDetailCollectionViewCell : UICollectionViewCell {
 
    
    var imageBanner: UIImageView!
    var imageURL : String? {
        didSet {

            imageBanner.setImageWithURL(NSURL(string: "http://\(imageURL!)"))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        imageBanner = UIImageView(frame:CGRectMake(0, 0, self.frame.width, self.frame.height))
        self.addSubview(imageBanner)
    }
    
    
    
}