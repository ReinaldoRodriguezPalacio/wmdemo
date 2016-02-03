//
//  BadgeView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class BadgeView : UIView {
    
    let title = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.whiteColor()
        
        title.frame = CGRectMake(AppDelegate.separatorHeigth(),AppDelegate.separatorHeigth(),self.bounds.width,self.bounds.height)
        title.textColor = WMColor.light_blue
        title.textAlignment = .Center
        title.font = WMFont.fontMyriadProRegularOfSize(9)
        //self.layer.backgroundColor = UIColor.whiteColor().CGColor

        self.layer.cornerRadius = self.bounds.width / 2
        //self.alpha = 0
        self.transform = CGAffineTransformMakeScale(0, 0)
        
        self.addSubview(title)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = self.bounds.width / 2
    }
    
    
    func showBadge(animated:Bool) {
        if (animated == false) {
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }else{
            UIView.animateKeyframesWithDuration(0.5 / 2, delay:  0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: { (complete:Bool) -> Void in
                    UIView.animateKeyframesWithDuration(0.5 / 2, delay: 0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                        self.transform = CGAffineTransformMakeScale(0.9, 0.9)
                        }) { (complete:Bool) -> Void in
                            UIView.animateKeyframesWithDuration(0.5 / 2, delay: 0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                                }) { (complete:Bool) -> Void in
                            }
                    }
            })
        }
    }
    
    func updateTitle(numProducts:Int){
       

            if numProducts > 0 {
                self.hidden = false
                self.title.text = String(numProducts)
                UIView.animateKeyframesWithDuration(0.9, delay:  0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.3) { () -> Void in
                        self.transform = CGAffineTransformMakeScale(1.4, 1.4)
                    }
                    UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.3) { () -> Void in
                        self.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    }
                    UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.3) { () -> Void in
                        self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }
                    }, completion: { (complete:Bool) -> Void in
                        
                })
            }else{
                
                self.title.text = String(numProducts)
                self.hidden = true
            }
        
    }
    
}