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
        btnClose.setImage(UIImage(named:"close"), for: UIControlState())
        btnClose.addTarget(self, action: #selector(IPACatHeaderSearchReusable.closeCategory), for: UIControlEvents.touchUpInside)
        
        btnClose.frame = CGRect(x: 16 ,y: 3 ,width: 100,height: 100)
        self.addSubview(btnClose)
        
        imageIcon = UIImageView()
        imageIcon.frame = CGRect(x: (self.bounds.width / 2) - 24, y: 48, width: 48, height: 48)
        self.addSubview(imageIcon)
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProLightOfSize(25)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 16, y: 112, width: self.bounds.width - 32, height: 50)
        self.addSubview(titleLabel)
        
        let gestrure = UITapGestureRecognizer(target: self, action: #selector(IPACatHeaderSearchReusable.closeCategory))
        self.addGestureRecognizer(gestrure)
        
        
    }
    
    override func layoutSubviews() {
        if self.frame.origin.y >= 0{
            super.layoutSubviews()
            btnClose.frame = CGRect(x: 16 ,y: 3 ,width: 100,height: 100)
            imageIcon.frame = CGRect(x: (self.bounds.width / 2) - 24, y: 48, width: 48, height: 48)
            titleLabel.frame = CGRect(x: 16, y: 112, width: self.bounds.width - 32, height: 50)
        }
        
    }
    
    
    func setValues(_ imgBg:UIImage?,imgIcon:UIImage?,titleStr:String) {
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
