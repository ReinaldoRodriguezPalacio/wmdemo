//
//  WMLoadingView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class WMLoadingView : UIView {
    

    var loadImage : LoadingIconView!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        self.backgroundColor = UIColor.whiteColor()
        loadImage = LoadingIconView(frame: CGRectMake(0, 0, 116, 120))
        self.addSubview(loadImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //loadImage.center = CGPointMake(self.bounds.width / 2, self.bounds.height / 2)
        //loadImage.center = self.center
    }
    
    func startAnnimating(isVisibleTab: Bool) {
        if isVisibleTab{
            loadImage.frame = CGRectMake ((self.frame.width - 116) / 2, (self.frame.height - 46 - 220 ) / 2 , 116,  120)
        }
        else{
            loadImage.center = CGPointMake(self.bounds.width / 2, self.bounds.height / 2)
            //loadImage.frame = CGRectMake ((self.frame.width - 116) / 2, (self.frame.height - 220 ) / 2 , 116,  120)
        }
        self.alpha = 1.0
        if !loadImage._isAnnimating {
            loadImage.startAnnimating()
        }
    }
    
    func stopAnnimating() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.alpha = 0.0
            }) { (anima:Bool) -> Void in
                self.removeFromSuperview()
                self.loadImage.stopAnnimating()
        }
    }
    
}