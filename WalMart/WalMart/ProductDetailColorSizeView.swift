//
//  ProductDetailColorView.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductDetailColorSizeDelegate {
    func selectDetailItem(selected:String, itemType: String)
}

class ProductDetailColorSizeView: UIView {
    let buttonWidth = 13
    let buttonSpace = 28
    let backViewWidth = 20
    var items:[AnyObject]! = nil
    var viewToInsert: UIView? = nil
    var scrollView: UIScrollView? = nil
    var buildforColors: Bool! = true
    var delegate: ProductDetailColorSizeDelegate?
    
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
        buildItemsView()
    }

    
    func setup() {
        self.scrollView = UIScrollView(frame: self.frame)
        self.scrollView?.scrollEnabled = false
        self.viewToInsert = UIView(frame: self.frame)
        self.viewToInsert! = self
        //self.addSubview(scrollView!)
        buildItemsView()
    }
    
    func buildItemsView()
    {
        if items == nil { items = []}
        if items.count != 0{
            var butonsWidthCenter: CGFloat = CGFloat(((items.count * (backViewWidth + buttonSpace)) + buttonSpace) / 2)
            
            if !buildforColors!{
                butonsWidthCenter = CGFloat(buttonSpace)
                for item in self.items{
                    butonsWidthCenter += self.getButtonWidth(item["value"] as? String) + CGFloat(buttonSpace)
                }
                butonsWidthCenter += CGFloat(buttonSpace)
                butonsWidthCenter = butonsWidthCenter / 2
            }
            
            let viewWidthCenter = self.frame.width / 2
            let buttonPositionY = CGFloat(self.frame.height / 2) - CGFloat(backViewWidth / 2)
            var startPos = CGFloat(viewWidthCenter) - CGFloat(butonsWidthCenter)
            if CGFloat(self.frame.width) < CGFloat(butonsWidthCenter * 2)
            {
                self.addSubview(scrollView!)
                self.scrollView!.scrollEnabled = true
                self.scrollView!.contentSize = CGSizeMake(CGFloat(butonsWidthCenter * 2), self.frame.height)
                //viewToInsert = self.scrollView!
                startPos = 0
            }
        
            if buildforColors!{
                self.buildColorButtons(items,startPos: startPos,buttonPositionY: buttonPositionY)
            }
            else{
                self.buildSizeButtons(items,startPos: startPos,buttonPositionY: buttonPositionY)
            }
        }
    }
    
    func buildColorButtons(items: [AnyObject], startPos:CGFloat, buttonPositionY:CGFloat){
        var position = startPos
        var count = 0
        for item in self.items{
            position += CGFloat(buttonSpace)
            var backView = UIView(frame: CGRectMake(position, buttonPositionY, CGFloat(backViewWidth), CGFloat(backViewWidth)))
            backView.layer.cornerRadius = 4
        
            var colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            let buttonPosition = (CGFloat(backViewWidth) - CGFloat(buttonWidth)) / 2
            colorButton.frame = CGRectMake(CGFloat(buttonPosition), CGFloat(buttonPosition), CGFloat(buttonWidth), CGFloat(buttonWidth))
            colorButton.layer.cornerRadius = 2
            var intColor = UInt(item["value"] as! String, radix: 16)
            colorButton.backgroundColor = WMColor.UIColorFromRGB(intColor!, alpha: 1.0)
            colorButton.addTarget(self, action: "selectColor:", forControlEvents: UIControlEvents.TouchUpInside)
            colorButton.tag = count
        
            backView.addSubview(colorButton)
            self.viewToInsert!.addSubview(backView)
            position += CGFloat(backViewWidth)
            count++
        }
    }
    
    func buildSizeButtons(items: [AnyObject], startPos:CGFloat, buttonPositionY:CGFloat){
        var position = startPos
        var count = 0
        for item in self.items{
            position += CGFloat(buttonSpace)
            let sizeButonWidth = self.getButtonWidth(item["value"] as? String)
            let backViewSizeWidth = sizeButonWidth + 7.0
            var backView = UIView(frame: CGRectMake(position, buttonPositionY, backViewSizeWidth , CGFloat(backViewWidth)))
            backView.layer.cornerRadius = 4
        
            var sizeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            let buttonPosition = (CGFloat(backViewSizeWidth) - CGFloat(sizeButonWidth)) / 2
            sizeButton.frame = CGRectMake(CGFloat(buttonPosition), 4.2,sizeButonWidth , CGFloat(buttonWidth))
            sizeButton.layer.cornerRadius = 2
            sizeButton.setTitle(item["value"] as? String, forState: UIControlState.Normal)
            sizeButton.setTitleColor(WMColor.UIColorFromRGB(0x0E1219, alpha: 0.8), forState: UIControlState.Normal)
            sizeButton.setTitleColor(WMColor.UIColorFromRGB(0xC5C5CC, alpha: 0.8), forState: UIControlState.Disabled)
            sizeButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
            sizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            sizeButton.addTarget(self, action: "selectSize:", forControlEvents: UIControlEvents.TouchUpInside)
            sizeButton.enabled = item["enabled"] as! Bool
            sizeButton.tag = count
            backView.addSubview(sizeButton)
            self.viewToInsert!.addSubview(backView)
            position += CGFloat(backViewSizeWidth)
            count++
        }
    }
    
    func getButtonWidth(text:String?) -> CGFloat {
        var stringSize = text!.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14)])
        var buttonWidth = stringSize.width < 13 ? 13 : stringSize.width
        return buttonWidth
    }

    
    func selectColor(sender: AnyObject)
    {
        self.clearColorButtons()
        var button  = sender as! UIButton
        var backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.UIColorFromRGB(0x888A8E, alpha: 0.8).CGColor
        var item: AnyObject = items[button.tag]
        delegate?.selectDetailItem(item["value"] as! String, itemType: item["type"] as! String)
    }
    
    
    func selectSize(sender: AnyObject)
    {
        self.clearColorButtons()
        var button  = sender as! UIButton
        var backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.UIColorFromRGB(0x888A8E, alpha: 0.8).CGColor
        var item: AnyObject = items[button.tag]
        delegate?.selectDetailItem(item["value"] as! String, itemType: item["type"] as! String)
    }
    
    func enableButtonWhithTitles(titles: [String])
    {
        clearColorButtons()
        for title in titles{
            for view in self.viewToInsert!.subviews {
                if view.subviews.count > 0 && view.subviews[0].isKindOfClass(UIButton){
                    let button = view.subviews[0] as! UIButton
                    button.enabled = (button.titleLabel?.text == title)
                    if titles.count == 1 && button.enabled{
                        button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    }
                }
            }
        }
    }
    
    func selectButton(selected: String){
        var count = 0
        for item in self.items{
            if item["value"] as! String == selected{
                break
            }
            count++
        }
        
        for view in self.viewToInsert!.subviews {
            if view.subviews.count > 0 && view.subviews[0].isKindOfClass(UIButton){
                let button = view.subviews[0] as! UIButton
                if button.tag == count {
                    button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                }
            }
        }
    }
    
    func clearColorButtons(){
        for view in self.viewToInsert!.subviews
        {
            view.layer.borderWidth = 0
            view.layer.borderColor = WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.8).CGColor
        }
    }
}