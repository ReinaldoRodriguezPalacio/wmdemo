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
    var colorbackground: UIColor?
    var textColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.colorbackground = UIColor.white
        self.textColor = WMColor.light_blue
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.colorbackground = UIColor.white
        self.textColor = WMColor.light_blue
        setup()
    }
    
     init(frame: CGRect, backgroundColor: UIColor, textColor:UIColor){
        super.init(frame: frame)
        self.colorbackground = backgroundColor
        self.textColor = textColor
        setup()
    }
    
    func setup() {
        
        self.backgroundColor =  self.colorbackground!
        
        title.frame = CGRect(x: AppDelegate.separatorHeigth(),y: AppDelegate.separatorHeigth(),width: self.bounds.width,height: self.bounds.height)
        title.textColor = self.textColor!
        title.textAlignment = .center
        title.font = WMFont.fontMyriadProRegularOfSize(9)
        //self.layer.backgroundColor = UIColor.whiteColor().CGColor

        self.layer.cornerRadius = self.bounds.width / 2
        //self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        self.addSubview(title)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = self.colorbackground!
        self.layer.cornerRadius = self.bounds.width / 2
    }
    
    
    func showBadge(_ animated:Bool) {
        if (animated == false) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }else{
            UIView.animateKeyframes(withDuration: 0.5 / 2, delay:  0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { (complete:Bool) -> Void in
                    UIView.animateKeyframes(withDuration: 0.5 / 2, delay: 0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        }) { (complete:Bool) -> Void in
                            UIView.animateKeyframes(withDuration: 0.5 / 2, delay: 0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
                                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                }) { (complete:Bool) -> Void in
                            }
                    }
            })
        }
    }
    
    func updateTitle(_ numProducts:Int){
       
            if numProducts > 0 {
                
                self.title.text = String(numProducts)
                
                if isHidden {
                    self.isHidden = false
                    UIView.animateKeyframes(withDuration: 0.9, delay:  0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) { () -> Void in
                            self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) { () -> Void in
                            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3) { () -> Void in
                            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }
                        }, completion: { (complete:Bool) -> Void in
                            
                    })
                }
                
            }else{
                self.title.text = String(numProducts)
                self.isHidden = true
            }
        
    }
    
}
