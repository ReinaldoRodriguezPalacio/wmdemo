//
//  ImageDisplayCollectionViewCell.swift
//  WalMart
//
//  Created by neftali on 21/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class ImageDisplayCollectionViewCell: UICollectionViewCell,UIScrollViewDelegate {
 
    var scrollView: ImageScrollView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect)  {
        super.init(frame: frame)
        
        self.scrollView = ImageScrollView(frame: CGRectMake(0.0, 0.0, frame.size.width, frame.size.height))
        self.scrollView!.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.scrollView!)
    }
    
    func setImageToDisplay(image:UIImage) {
        self.scrollView!.displayImage(image)
    }
    
    func setImageUrlToDisplay(url:String) {
        self.scrollView!.displayImageWithUrl(url)
    }
    
    override func layoutSubviews() {
        let bounds = self.contentView.frame
        self.scrollView!.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.scrollView!.contentSize = bounds.size
    }
    
    
}
