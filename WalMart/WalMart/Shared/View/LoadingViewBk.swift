//
//  LoadingView.swift
//  WalMart
//
//  Created by neftali on 23/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class LoadingViewBk: UIView {

    var label: UILabel? = nil
    var indicator: UIActivityIndicatorView? = nil

    var text: NSString? {
        didSet {
            self.label?.text = self.text
        }
    }
    
    var textColor: UIColor? {
        didSet {
            self.label?.textColor = self.textColor!
        }
    }
    
    var activityIndicatorStyle: UIActivityIndicatorViewStyle? {
        didSet {
            self.indicator?.activityIndicatorViewStyle = self.activityIndicatorStyle!
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        
        self.label = UILabel()
        self.label!.numberOfLines = 0
        //self.label!.textColor = Color.productDetailDescColor
        self.label!.textAlignment = .Center
        self.label!.backgroundColor = UIColor.clearColor()
        //self.label!.font = Font.fontWhitneyMediumOfSize(18)
        self.addSubview(self.label!)
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.indicator!.startAnimating()
        self.addSubview(self.indicator!)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews() {
        var width = self.frame.size.width - 20.0
        var size = CGSizeMake(width, CGFloat.max)
        var computedRect: CGRect = self.label!.text!.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.label!.font], context: nil)
        self.label!.frame = CGRectMake(0.0,0.0,width, computedRect.size.height)
        self.label!.center = CGPointMake(self.frame.size.width/2,(self.frame.size.height/2) - computedRect.size.height)
        self.indicator!.center = CGPointMake(self.frame.size.width/2,(self.frame.size.height/2) + self.indicator!.frame.size.height)
    }

    func updateText(text:String, enableIndicator:Bool) {
        self.label!.text = text
        if enableIndicator {
            self.indicator!.startAnimating()
        }
        else {
            self.indicator!.stopAnimating()
        }
        self.setNeedsLayout()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

    
}
