//
//  IPABannerCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPABannerCollectionViewCell : BannerCollectionViewCell {
    var nextAction: Bool = false
    override func getCurrentController() -> HomeBannerImageViewController {
        
        
        if dataSource!.count > 0 {
            var bannerUrl = ""
            let dictBanner = dataSource![self.currentItem!]
            if let strUrl = dictBanner["urlTablet"]  {
                bannerUrl = strUrl
            }
            if let strUrl = dictBanner["bannerUrlTablet"] {
                bannerUrl = strUrl
            }
            
            let imageController = HomeBannerImageViewController()
            imageController.view.frame = pageViewController.view.bounds
            imageController.setCurrentImage(bannerUrl)
            imageController.view.tag = self.currentItem!
            imageController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapOnItembanner:"))
       
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.buttonTerms.alpha =  self.getCurrentTerms() == "" ? 0 : 1
                }) { (complete:Bool) -> Void in
            }

            
            return imageController
        }
        
        return HomeBannerImageViewController()
    }
}