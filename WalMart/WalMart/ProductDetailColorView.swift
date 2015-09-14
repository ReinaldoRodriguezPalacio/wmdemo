//
//  ProductDetailColorView.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailColorView: UIView {
    let buttonWidth = 13
    let buttonSpace = 28
    let backViewWidth = 20
    var colors:[AnyObject]! = nil
    var scrollView: UIScrollView? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    
    func setup() {
        
    }
    
    func buildColorView()
    {
        if colors == nil { colors = []}
        if colors.count != 0{
            let butonsWidthCenter = ((colors.count * (backViewWidth + buttonSpace)) + buttonSpace) / 2
            let viewWidthCenter = self.frame.width / 2
            let buttonPositionY = CGFloat(self.frame.height / 2) - CGFloat(backViewWidth / 2)
            var startPos = CGFloat(viewWidthCenter) - CGFloat(butonsWidthCenter)
            for color in self.colors{
                startPos += CGFloat(buttonSpace)
                var backView = UIView(frame: CGRectMake(startPos, buttonPositionY, CGFloat(backViewWidth), CGFloat(backViewWidth)))
                backView.layer.cornerRadius = 4
                
                var colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
                let buttonPosition = (CGFloat(backViewWidth) - CGFloat(buttonWidth)) / 2
                colorButton.frame = CGRectMake(CGFloat(buttonPosition), CGFloat(buttonPosition), CGFloat(buttonWidth), CGFloat(buttonWidth))
                colorButton.layer.cornerRadius = 2
                colorButton.backgroundColor = WMColor.UIColorFromRGB(color as! UInt, alpha: 1.0)
                colorButton.addTarget(self, action: "selectColor:", forControlEvents: UIControlEvents.TouchUpInside)
                
                backView.addSubview(colorButton)
                self.addSubview(backView)
                startPos += CGFloat(backViewWidth)
            }
        }
    }
    
    func selectColor(sender: AnyObject)
    {
        self.clearColorButtons()
        var button  = sender as! UIButton
        var backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.UIColorFromRGB(0x888A8E, alpha: 0.8).CGColor
    }
    
    func clearColorButtons(){
        for view in self.subviews
        {
            view.layer.borderWidth = 0
            view.layer.borderColor = WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.8).CGColor
        }
    }
}