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
        
        imgBackground = UIImageView(frame: CGRectZero)
        self.addSubview(imgBackground)
        
        imgIcon = UIImageView(frame: CGRectZero)
        self.addSubview(imgIcon)
        
        title = UILabel(frame: CGRectZero)
        title.font = WMFont.fontMyriadProLightOfSize(16)
        title.textColor = UIColor.whiteColor()
        title.textAlignment = .Center
        self.addSubview(title)
        
//        articles = UILabel(frame: CGRectZero)
//        articles.font = WMFont.fontMyriadProRegularOfSize(14)
//        articles.textColor = UIColor.whiteColor()
//        articles.textAlignment = .Center
//        self.addSubview(articles)
        
        shopButton = UIButton(frame: CGRectZero)
        shopButton.layer.cornerRadius = 17
        shopButton.backgroundColor = UIColor.whiteColor()
        shopButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        shopButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        shopButton.addTarget(self, action: #selector(PreShoppingCartView.tapGR), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(shopButton)
        
//        customlabel = CurrencyCustomLabel(frame:CGRectMake(0, 0, 137, 34))
//        customlabel.backgroundColor = UIColor.clearColor()
//        customlabel.setCurrencyUserInteractionEnabled(true)
       // shopButton.addSubview(customlabel)
        //shopButton.sendSubviewToBack(customlabel)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreShoppingCartView.tapGR))
        self.addGestureRecognizer(tapGesture)
        
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgBackground.frame = CGRectMake(0, 0, self.frame.width, self.frame.height - 88)
        title.frame = CGRectMake(0, (self.frame.height / 2) - 32, self.frame.width, 16)
        imgIcon.frame = CGRectMake((self.frame.width / 2) - 28, self.title.frame.minY - 61, 56, 48)
        //articles.frame  = CGRectMake(0, title.frame.maxY + 8, self.frame.width, 16)
        //shopButton.frame = CGRectMake((self.frame.width / 2) - 68.5, imgBackground.frame.maxY + (44 - 17) , 137, 34)
        //customlabel.frame = self.shopButton.bounds
        
        if self.emptySC! {
            shopButton.frame = CGRectMake((self.frame.width / 2) - 150, imgBackground.frame.maxY + 10 , 300, 60)
        } else {
            shopButton.frame = CGRectMake((self.frame.width / 2) - 68.5, imgBackground.frame.maxY + 27, 137, 34)
        }
        
    }
    
    func setValues(colorBg:UIColor,imgBgName:String,imgIconName:String,title:String,articles:String,total:String,totalColor:UIColor,empty:Bool) {
        self.backgroundColor = colorBg
        self.imgBackground.image = UIImage(named: imgBgName)
        self.imgIcon.image = UIImage(named: imgIconName)
        self.title.text = title
        //self.articles.text = articles
        shopButton.setTitle(articles, forState: UIControlState.Normal)
        
        self.emptySC =  empty
        if empty {
            shopButton.backgroundColor = UIColor.clearColor()
            shopButton.frame = CGRectMake((self.frame.width / 2) - 150, imgBackground.frame.maxY + (36 - 26) , 300, 60)
            shopButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            shopButton.titleLabel?.numberOfLines = 0
            shopButton.titleLabel?.textAlignment = .Center
        } else {
            shopButton.backgroundColor = UIColor.whiteColor()
            shopButton.setTitleColor(totalColor, forState: UIControlState.Normal)
            shopButton.frame = CGRectMake((self.frame.width / 2) - 68.5, imgBackground.frame.maxY + (44 - 17) , 137, 34)
            shopButton.titleLabel?.numberOfLines = 0
            shopButton.titleLabel?.textAlignment = .Center
        }
        
        tapGesture.enabled = true
        shopButton.enabled = true
        
       // updateButtonLabel(total,colorText:totalColor)
    }
    
    func tapGR() {
        tapGesture.enabled = false
        shopButton.enabled = false
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