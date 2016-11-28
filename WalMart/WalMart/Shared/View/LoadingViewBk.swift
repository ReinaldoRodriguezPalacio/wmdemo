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
            self.label?.text = self.text as? String
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        
        self.label = UILabel()
        self.label!.numberOfLines = 0
        //self.label!.textColor = Color.productDetailDescColor
        self.label!.textAlignment = .center
        self.label!.backgroundColor = UIColor.clear
        //self.label!.font = Font.fontWhitneyMediumOfSize(18)
        self.addSubview(self.label!)
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.indicator!.startAnimating()
        self.addSubview(self.indicator!)
        self.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        let width = self.frame.size.width - 20.0
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let computedRect: CGRect = self.label!.text!.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:self.label!.font], context: nil)
        self.label!.frame = CGRect(x: 0.0,y: 0.0,width: width, height: computedRect.size.height)
        self.label!.center = CGPoint(x: self.frame.size.width/2,y: (self.frame.size.height/2) - computedRect.size.height)
        self.indicator!.center = CGPoint(x: self.frame.size.width/2,y: (self.frame.size.height/2) + self.indicator!.frame.size.height)
    }

    func updateText(_ text:String, enableIndicator:Bool) {
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
