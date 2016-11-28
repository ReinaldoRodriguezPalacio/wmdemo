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
        
        descLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 197, height: self.frame.height))
        descLabel.text = NSLocalizedString("home.youarein",comment:"")
        descLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        descLabel.textColor = UIColor.white
        self.addSubview(descLabel)
        
        gotoGroceries = UIButton(frame: CGRect(x: descLabel.frame.maxX + 9, y: (self.frame.height / 2) - (24 / 2), width: 80, height: 24))
        gotoGroceries.setTitle( NSLocalizedString("home.gotosuper",comment:""), for: UIControlState())
        gotoGroceries.addTarget(self, action: #selector(IPOGroceriesView.openGroceriesApp), for: UIControlEvents.touchUpInside)
        gotoGroceries.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        gotoGroceries.backgroundColor = WMColor.green
        gotoGroceries.layer.cornerRadius = gotoGroceries.frame.height / 2
        self.addSubview(gotoGroceries)
        
        
    }
    
    func generateBlurImageWithView(_ viewToBlur:UIView?) {
        if  self.bluredImage == nil {
            self.bluredImage = UIImageView()
            self.bluredImage!.frame = self.bounds
            self.bluredImage!.clipsToBounds = true
            self.addSubview(self.bluredImage!)
        }
        if viewToBlur != nil {
            autoreleasepool {
                UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1.0);
                viewToBlur!.layer.render(in: UIGraphicsGetCurrentContext()!)
                let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
                UIGraphicsEndImageContext();
                viewToBlur!.layer.contents = nil
                self.bluredImage!.image = cloneImage.applyLightEffect()
                self.sendSubview(toBack: self.bluredImage!)
            }
        }
    }

    
    func openGroceriesApp() {
        
        let appScheme = "walmartGroceries://"
        let appStoreURL = URL(string: appScheme)
        if UIApplication.shared.canOpenURL(appStoreURL!) {
            UIApplication.shared.openURL(appStoreURL!)
        } else {
            let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id919747235")
            if UIApplication.shared.canOpenURL(appStoreURL!) {
                UIApplication.shared.openURL(appStoreURL!)
            }
        }
    }
    
    
    
}
