//
//  IPOEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/2/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//



import Foundation

let IS_IPAD = (UIDevice.currentDevice().model.lowercaseString.uppercaseString.rangeOfString("IPAD") == nil ? false : true )
let IS_IPHONE = (UIDevice.currentDevice().model.lowercaseString.uppercaseString.rangeOfString("IPHONE") == nil ? false : true )
let IS_IPOD = (UIDevice.currentDevice().model.lowercaseString.uppercaseString.rangeOfString("IPOD") == nil ? false : true )
let IS_RETINA = (UIScreen.mainScreen().scale >= 2.0)

let SCREEN_WIDTH =  UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_MAX_LENGTH = (max(SCREEN_WIDTH, SCREEN_HEIGHT))
let SCREEN_MIN_LENGTH = (min(SCREEN_WIDTH, SCREEN_HEIGHT))

let IS_IPHONE_4_OR_LESS = (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
let IS_IPHONE_5 = (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
let IS_IPHONE_6 = (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
let IS_IPHONE_6P = (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


class IPOEmptyView : UIView {
    
    var iconImageView : UIImageView!
    var descLabel : UILabel!
    var returnButton : UIButton!
    var returnAction : (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setup() {
        self.backgroundColor = WMColor.emptyBgColor
        iconImageView = UIImageView()
        
        descLabel = UILabel()
        descLabel.font = WMFont.fontMyriadProLightOfSize(14)
        descLabel.textColor = WMColor.emptyDescTextColor
        descLabel.textAlignment = NSTextAlignment.Center
        
        returnButton = UIButton()
        returnButton.titleLabel?.textColor = UIColor.whiteColor()
        returnButton.layer.cornerRadius = 20
        returnButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        returnButton.backgroundColor = WMColor.emptyBgRetunBlueColor
        returnButton.setTitle(NSLocalizedString("empty.return",comment:""), forState: UIControlState.Normal)
        returnButton.addTarget(self, action: "returnActionSel", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(iconImageView)
        self.addSubview(descLabel)
        
        //if IS_IPHONE_4_OR_LESS == false {
            self.addSubview(returnButton)
        //}
        
        self.insertSubview(iconImageView, atIndex: 0)
    }
    
    override func layoutSubviews() {
        if iconImageView != nil && iconImageView.image != nil {
         iconImageView.frame = CGRectMake(0.0, 0.0,  self.bounds.width,  iconImageView.image!.size.height)//  self.bounds.height)
        }
        self.descLabel.frame = CGRectMake(0.0, 28.0, self.bounds.width, 16.0)
        self.returnButton.frame = CGRectMake((self.bounds.width - 160 ) / 2, self.bounds.height - 100, 160 , 40)
    }

    func returnActionSel() {
        if returnAction != nil {
            returnAction!()
        }
    }
    
}