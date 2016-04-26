//
//  IPASectionHeaderSearchReusable.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPASectionHeaderSearchReusableDelegate {
        func showFamilyController()
}


class IPASectionHeaderSearchReusable : UICollectionReusableView {
    
    var title : UIButton!
    var titleImage : UIImageView!
    var delegate : IPASectionHeaderSearchReusableDelegate!
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        
        
        title = UIButton(frame: CGRectMake((self.frame.width / 2) - 200, (self.frame.height / 2) - 12, 400, 24))
        title.backgroundColor = WMColor.light_blue
        title.addTarget(self, action: #selector(IPASectionHeaderSearchReusable.didTapInTitle), forControlEvents: UIControlEvents.TouchUpInside)
        title.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        title.titleLabel!.font =  WMFont.fontMyriadProRegularOfSize(16)
        title.titleLabel!.textAlignment = .Left
        title.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        title.titleEdgeInsets = UIEdgeInsetsMake(2.0, 10, 0, 0.0);
        title.layer.cornerRadius = 4
        
        let imageDown = UIImage(named: "categories_title_down")
        titleImage = UIImageView(frame: CGRectMake(0, 0, imageDown!.size.width, imageDown!.size.height))
        titleImage.image = imageDown
        
        title.addSubview(titleImage)

        self.addSubview(title)
        

    }
    
    
    func didTapInTitle() {
        title.backgroundColor = WMColor.blue
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.titleImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        })
        
        if delegate != nil {
            delegate.showFamilyController()
        }
    }
    
    
    func setSelected(){
        title.backgroundColor = WMColor.blue
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.titleImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        })
    }
    
    
    func dismissPopover() {
        dispatch_async(dispatch_get_main_queue(),{
            self.title.backgroundColor = WMColor.light_blue
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.titleImage.transform = CGAffineTransformMakeRotation(CGFloat(0))
            })
        })
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleImage.frame = CGRectMake(self.title.frame.width - titleImage.frame.width - 10 ,(self.title.frame.height / 2) - (titleImage.frame.height / 2), titleImage.frame.width, titleImage.frame.height)
    }
    
}