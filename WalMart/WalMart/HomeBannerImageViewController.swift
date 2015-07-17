//
//  HomeBannerImageViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class HomeBannerImageViewController : UIViewController {
    
    
    var imageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageView  ==  nil {
            imageView = UIImageView(frame: self.view.bounds)
        }
        self.view.addSubview(imageView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.frame = self.view.bounds
    }
    
    func setCurrentImage(urlImage:String){
        if let urlObj = NSURL(string:"http://\(urlImage)" ) {
            if imageView  ==  nil {
                imageView = UIImageView(frame: self.view.bounds)
            }
            imageView.setImageWithURL(urlObj)
        }
    }
    
}