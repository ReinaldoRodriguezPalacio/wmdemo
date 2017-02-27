//
//  PreShoppingCartView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/28/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class PreShoppingCartView : UIView {
    
    var imgBackground : UIImageView!
    var imgIcon : UIImageView!
    var title : UILabel!
    var articles : UILabel!
    var shopButton : UIButton!
    var emptySC : Bool! = false
    var tapGesture : UITapGestureRecognizer!
    
    var shopAction : (() -> Void)!
    var tapAction : (() -> Void)!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        
        imgBackground = UIImageView(frame: CGRect.zero)
        imgBackground.contentMode = .scaleAspectFill
        self.addSubview(imgBackground)
        
        imgIcon = UIImageView(frame: CGRect.zero)
        self.addSubview(imgIcon)
        
        title = UILabel(frame: CGRect.zero)
        title.font = WMFont.fontMyriadProLightOfSize(16)
        title.textColor = UIColor.white
        title.textAlignment = .center
        self.addSubview(title)
        
        shopButton = UIButton(frame: CGRect.zero)
        shopButton.layer.cornerRadius = 17
        shopButton.backgroundColor = UIColor.white
        shopButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        shopButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        shopButton.addTarget(self, action: #selector(PreShoppingCartView.tapGR), for: UIControlEvents.touchUpInside)
        self.addSubview(shopButton)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreShoppingCartView.tapGR))
        self.addGestureRecognizer(tapGesture)
        
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imgBackgroundHeight = self.frame.height - 88
        let remainView = self.frame.height - imgBackgroundHeight
        let yPosition = (imgBackgroundHeight - (48 + 16 + 8)) / 2
        
        imgBackground.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: imgBackgroundHeight)
        imgIcon.frame = CGRect(x: (self.frame.width / 2) - 28, y: yPosition, width: 56, height: 48)
        title.frame = CGRect(x: 0, y: imgIcon.frame.maxY + 8, width: self.frame.width, height: 16)

        if self.emptySC! {
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 150, y: imgBackground.frame.maxY + 10 + (IS_IPHONE_4_OR_LESS ? 15 : 0), width: 300, height: 60)
        } else {
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 68.5, y: imgBackground.frame.maxY + 27 + (IS_IPHONE_4_OR_LESS ? 12 : 0), width: 137, height: 34)
        }
        
    }
    
    func setValues(_ colorBg: UIColor, imgBgName: String, imgIconName: String, title: String, articles: String, total:String, totalColor: UIColor, empty: Bool) {

        self.backgroundColor = colorBg
        self.imgBackground.image = UIImage(named: imgBgName)
        self.imgIcon.image = UIImage(named: imgIconName)
        self.title.text = title

        shopButton.setTitle(articles, for: UIControlState())
        
        self.emptySC = empty
        
        if empty {
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 150, y: imgBackground.frame.maxY + (36 - 26) + (IS_IPHONE_4_OR_LESS ? 15 : 0) , width: 300, height: 60)
            shopButton.backgroundColor = UIColor.clear
            shopButton.setTitleColor(UIColor.white, for: UIControlState())
            shopButton.titleLabel?.numberOfLines = 0
            shopButton.titleLabel?.textAlignment = .center
        } else {
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 68.5, y: imgBackground.frame.maxY + (44 - 17) + (IS_IPHONE_4_OR_LESS ? 12 : 0), width: 137, height: 34)
            shopButton.backgroundColor = UIColor.white
            shopButton.setTitleColor(totalColor, for: UIControlState())
            shopButton.titleLabel?.numberOfLines = 0
            shopButton.titleLabel?.textAlignment = .center
        }
        
        tapGesture.isEnabled = true
        shopButton.isEnabled = true
        
    }
    
    func tapGR() {
        tapGesture.isEnabled = false
        shopButton.isEnabled = false
        if tapAction != nil {
            tapAction()
           
        }
    }
    
}
