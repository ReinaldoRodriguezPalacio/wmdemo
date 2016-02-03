//
//  IPOGroceriesView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPOGroceriesView : UIView {
    
    var bluredImage : UIImageView? = nil
    var descLabel : UILabel!
    var gotoGroceries : UIButton!
    var bgView : UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        bgView = UIView(frame: self.bounds)
        bgView.backgroundColor = WMColor.light_blue
        self.addSubview(bgView)
        self.clipsToBounds = true
        
        descLabel = UILabel(frame: CGRectMake(16, 0, 197, self.frame.height))
        descLabel.text = NSLocalizedString("home.youarein",comment:"")
        descLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        descLabel.textColor = UIColor.whiteColor()
        self.addSubview(descLabel)
        
        gotoGroceries = UIButton(frame: CGRectMake(descLabel.frame.maxX + 9, (self.frame.height / 2) - (24 / 2), 80, 24))
        gotoGroceries.setTitle( NSLocalizedString("home.gotosuper",comment:""), forState: UIControlState.Normal)
        gotoGroceries.addTarget(self, action: "openGroceriesApp", forControlEvents: UIControlEvents.TouchUpInside)
        gotoGroceries.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        gotoGroceries.backgroundColor = WMColor.green
        gotoGroceries.layer.cornerRadius = gotoGroceries.frame.height / 2
        self.addSubview(gotoGroceries)
        
        
    }
    
    func generateBlurImageWithView(viewToBlur:UIView?) {
        if  self.bluredImage == nil {
            self.bluredImage = UIImageView()
            self.bluredImage!.frame = self.bounds
            self.bluredImage!.clipsToBounds = true
            self.addSubview(self.bluredImage!)
        }
        if viewToBlur != nil {
            autoreleasepool {
                UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1.0);
                viewToBlur!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                viewToBlur!.layer.contents = nil
                self.bluredImage!.image = cloneImage.applyLightEffect()
                self.sendSubviewToBack(self.bluredImage!)
            }
        }
    }

    
    func openGroceriesApp() {
        
        let appScheme = "walmartGroceries://"
        let appStoreURL = NSURL(string: appScheme)
        if UIApplication.sharedApplication().canOpenURL(appStoreURL!) {
            UIApplication.sharedApplication().openURL(appStoreURL!)
        } else {
            let appStoreURL = NSURL(string: "itms-apps://itunes.apple.com/app/id919747235")
            if UIApplication.sharedApplication().canOpenURL(appStoreURL!) {
                UIApplication.sharedApplication().openURL(appStoreURL!)
            }
        }
    }
    
    
    
}