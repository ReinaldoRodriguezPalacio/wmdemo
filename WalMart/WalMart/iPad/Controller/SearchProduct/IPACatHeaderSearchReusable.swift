//
//  IPACatHeaderSearchReusable.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol IPACatHeaderSearchReusableDelegate{
    func closeCategory()
}


class IPACatHeaderSearchReusable : UICollectionReusableView {
    
    var imageBg : UIImageView!
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    var btnClose : UIButton!
    var delegate : IPACatHeaderSearchReusableDelegate!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        imageBg = UIImageView(frame: self.bounds)
        self.addSubview(imageBg)
        
        btnClose = UIButton()
        btnClose.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        btnClose.addTarget(self, action: "closeCategory", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnClose.frame = CGRectMake(16 ,3 ,100,100)
        self.addSubview(btnClose)
        
        imageIcon = UIImageView()
        imageIcon.frame = CGRectMake((self.bounds.width / 2) - 24, 48, 48, 48)
        self.addSubview(imageIcon)
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProLightOfSize(25)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.frame = CGRectMake(16, 112, self.bounds.width - 32, 50)
        self.addSubview(titleLabel)
        
        let gestrure = UITapGestureRecognizer(target: self, action: "closeCategory")
        self.addGestureRecognizer(gestrure)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        btnClose.frame = CGRectMake(16 ,3 ,100,100)
        imageIcon.frame = CGRectMake((self.bounds.width / 2) - 24, 48, 48, 48)
        titleLabel.frame = CGRectMake(16, 112, self.bounds.width - 32, 50)
    }
    
    
    func setValues(imgBg:UIImage?,imgIcon:UIImage?,titleStr:String) {
        imageBg.image = imgBg
        imageIcon.image = imgIcon
        titleLabel.text = titleStr
    }
    
    func closeCategory() {
        if delegate != nil {
            delegate.closeCategory()
        }
    }
    
}