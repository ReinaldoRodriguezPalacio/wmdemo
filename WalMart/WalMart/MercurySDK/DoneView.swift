//
//  DoneView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/15/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class DoneView : UIView {
    
    var information: UILabel!
    var viewLoadingDoneAnimate : UIView!
    var imageBackground: UIImageView!
    var iconLoadingDone : UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        information = UILabel(frame: CGRectMake(16, 23, self.frame.size.width - 32, 36))
        information.textAlignment = NSTextAlignment.Center
        information.textColor = WMColor.light_blue
        information.font = WMFont.fontMyriadProLightOfSize(18)
        information.numberOfLines = 2
        information.text = "¡Gracias!"
        
        imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        imageBackground.image = UIImage(named: "donedelivery")
        
        let imgIcon =  UIImage(named:"done_order")
        iconLoadingDone = UIImageView(frame: CGRectMake((self.frame.width / 2) - (imgIcon!.size.width / 2), 90, imgIcon!.size.width, imgIcon!.size.height))
        self.iconLoadingDone.image = imgIcon
        self.iconLoadingDone.transform = CGAffineTransformMakeScale(0, 0)
        
        viewLoadingDoneAnimate = UIView()
        viewLoadingDoneAnimate.backgroundColor = WMColor.green.colorWithAlphaComponent(0.5)
        viewLoadingDoneAnimate.frame = CGRectMake(0, 0,  imgIcon!.size.width - 2, imgIcon!.size.height - 2)
        viewLoadingDoneAnimate.center = iconLoadingDone.center
        viewLoadingDoneAnimate.layer.cornerRadius = (imgIcon!.size.height - 2) / 2
        viewLoadingDoneAnimate.transform = CGAffineTransformMakeScale(1.2,1.2)
        
        self.addSubview(imageBackground)
        self.addSubview(information)
        self.addSubview(viewLoadingDoneAnimate)
        self.addSubview(iconLoadingDone)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func animate() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.duration = 0.4
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = 1
        animation.values = [0, 1.3,1]
        self.iconLoadingDone.layer.addAnimation(animation, forKey: "grow")
    }
    
    
    
}