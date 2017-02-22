//
//  PreShoppingCartView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/28/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class PreShoppingCartView : UIView {
    
    //&var customlabel : CurrencyCustomLabel!
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
        
        imgBackground.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 88)
        title.frame = CGRect(x: 0, y: (self.frame.height / 2) - 32, width: self.frame.width, height: 16)
        imgIcon.frame = CGRect(x: (self.frame.width / 2) - 28, y: self.title.frame.minY - 61, width: 56, height: 48)
        //articles.frame  = CGRectMake(0, title.frame.maxY + 8, self.frame.width, 16)
        //shopButton.frame = CGRectMake((self.frame.width / 2) - 68.5, imgBackground.frame.maxY + (44 - 17) , 137, 34)
        //customlabel.frame = self.shopButton.bounds
        
        if self.emptySC! {
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 150, y: imgBackground.frame.maxY + 10 , width: 300, height: 60)
        } else {
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 68.5, y: imgBackground.frame.maxY + 27, width: 137, height: 34)
        }
        
    }
    
    func setValues(_ colorBg:UIColor,imgBgName:String,imgIconName:String,title:String,articles:String,total:String,totalColor:UIColor,empty:Bool) {
        self.backgroundColor = colorBg
        self.imgBackground.image = UIImage(named: imgBgName)
        self.imgIcon.image = UIImage(named: imgIconName)
        self.title.text = title
        //self.articles.text = articles
        shopButton.setTitle(articles, for: UIControlState())
        
        self.emptySC =  empty
        if empty {
            shopButton.backgroundColor = UIColor.clear
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 150, y: imgBackground.frame.maxY + (36 - 26) , width: 300, height: 60)
            shopButton.setTitleColor(UIColor.white, for: UIControlState())
            shopButton.titleLabel?.numberOfLines = 0
            shopButton.titleLabel?.textAlignment = .center
        } else {
            shopButton.backgroundColor = UIColor.white
            shopButton.setTitleColor(totalColor, for: UIControlState())
            shopButton.frame = CGRect(x: (self.frame.width / 2) - 68.5, y: imgBackground.frame.maxY + (44 - 17) , width: 137, height: 34)
            shopButton.titleLabel?.numberOfLines = 0
            shopButton.titleLabel?.textAlignment = .center
        }
        
        tapGesture.isEnabled = true
        shopButton.isEnabled = true
        
       // updateButtonLabel(total,colorText:totalColor)
    }
    
    func tapGR() {
        tapGesture.isEnabled = false
        shopButton.isEnabled = false
        if tapAction != nil {
            tapAction()
           
        }
    }
    
    
//    func updateButtonLabel(labelTotal:String,colorText:UIColor){
//        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
//        let fmtTotal = CurrencyCustomLabel.formatString(labelTotal)
//        let shopStrComplete = "\(shopStr) \(fmtTotal)"
//        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: colorText, interLine: false)
//        
//    }
    
}
