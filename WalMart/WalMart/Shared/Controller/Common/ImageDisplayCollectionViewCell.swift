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
        
        self.scrollView = ImageScrollView(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        self.scrollView!.backgroundColor = UIColor.white
        self.contentView.addSubview(self.scrollView!)
    }
    
    func setImageToDisplay(_ image:UIImage) {
        self.scrollView!.displayImage(image)
    }
    
    func setImageUrlToDisplay(_ url:String) {
        self.scrollView!.displayImageWithUrl(url)
    }
    
    override func layoutSubviews() {
        let bounds = self.contentView.frame
        self.scrollView!.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        self.scrollView!.contentSize = bounds.size
    }
    
    
}
