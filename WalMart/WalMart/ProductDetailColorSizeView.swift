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
    let buttonWidth = 20
    let buttonSpace = 30
    let backViewWidth = 28
    var items:[AnyObject]! = nil
    var viewToInsert: UIView? = nil
    var scrollView: UIScrollView? = nil
    var buildforColors: Bool! = false
    var delegate: ProductDetailColorSizeDelegate?
    var bottomBorder: CALayer!
    var topBorder: CALayer!
    var showTopBorder: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bottomBorder.frame = CGRectMake(0.0, self.frame.height - 1, self.frame.size.width, 1)
        self.topBorder.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 1)
        buildItemsView()
    }

    
    func setup() {
        self.scrollView = UIScrollView(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
        self.scrollView?.scrollEnabled = false
        self.viewToInsert = UIView(frame: self.frame)
        self.viewToInsert! = self
        self.bottomBorder = CALayer()
        self.bottomBorder.backgroundColor = WMColor.light_light_gray.CGColor
        self.layer.insertSublayer(bottomBorder, atIndex: 99)
        self.topBorder = CALayer()
        self.topBorder.backgroundColor = WMColor.light_light_gray.CGColor
        if self.showTopBorder {
          self.layer.insertSublayer(topBorder, atIndex: 100)
        }
        buildItemsView()
    }
    
    func buildItemsView()
    {
        if items == nil { items = []}
        if items.count != 0 && self.subviews.count == 0{
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
                self.scrollView = UIScrollView(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
                self.scrollView!.scrollEnabled = true
                self.scrollView!.contentSize = CGSizeMake(CGFloat(butonsWidthCenter * 2), self.frame.height)
                viewToInsert = self.scrollView!
                self.addSubview(scrollView!)
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
            let backView = UIView(frame: CGRectMake(position, buttonPositionY, CGFloat(backViewWidth), CGFloat(backViewWidth)))
            backView.layer.cornerRadius = 4
            let tap = UITapGestureRecognizer(target: self, action: Selector("backViewTap:"))
            //tap.delegate = self
            backView.addGestureRecognizer(tap)
        
            let colorButton = UIButton(type: UIButtonType.Custom)
            let buttonPosition = (CGFloat(backViewWidth) - CGFloat(buttonWidth)) / 2
            colorButton.frame = CGRectMake(CGFloat(buttonPosition), CGFloat(buttonPosition), CGFloat(buttonWidth), CGFloat(buttonWidth))
            colorButton.layer.cornerRadius = 2
            var stringColor: String = item["value"]! as! String
            if stringColor.contains("#"){
                stringColor = stringColor.substringFromIndex(stringColor.startIndex.advancedBy(1))
            }
            let intColor = UInt(stringColor, radix: 16)
            colorButton.backgroundColor = WMColor.UIColorFromRGB(intColor!, alpha: 1.0)
            colorButton.addTarget(self, action: "selectColor:", forControlEvents: UIControlEvents.TouchUpInside)
            colorButton.tag = count
            if intColor >= 16700000 {
                colorButton.layer.borderWidth = 0.5
                colorButton.layer.borderColor = WMColor.dark_gray.CGColor
            }else{
                colorButton.layer.borderColor = UIColor.whiteColor().CGColor
                colorButton.layer.borderWidth = 0.0
            }
        
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
            let backView = UIView(frame: CGRectMake(position, buttonPositionY, backViewSizeWidth , CGFloat(backViewWidth)))
            backView.layer.cornerRadius = 4
        
            let sizeButton = UIButton(type: UIButtonType.Custom)
            let buttonPosition = (CGFloat(backViewSizeWidth) - CGFloat(sizeButonWidth)) / 2
            sizeButton.frame = CGRectMake(CGFloat(buttonPosition), 4.8,sizeButonWidth , CGFloat(buttonWidth))
            sizeButton.layer.cornerRadius = 2
            sizeButton.setTitle(item["value"] as? String, forState: UIControlState.Normal)
            sizeButton.setTitleColor(WMColor.dark_gray, forState: UIControlState.Normal)
            sizeButton.setTitleColor(WMColor.light_gray, forState: UIControlState.Disabled)
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
        let stringSize = text!.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14)])
        let buttonWidth = stringSize.width < 13 ? 13 : stringSize.width
        return buttonWidth
    }

    func backViewTap(sender: UIGestureRecognizer){
        let backView = sender.view!
        let button  = backView.subviews[0] as! UIButton
        selectColor(button)
    }
    
    func selectColor(sender: AnyObject)
    {
        self.clearColorButtons()
        let button  = sender as! UIButton
        let backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.gray.CGColor
        let item: AnyObject = items[button.tag]
        delegate?.selectDetailItem(item["value"] as! String, itemType: item["type"] as! String)
    }
    
    
    func selectSize(sender: AnyObject)
    {
        self.clearColorButtons()
        let button  = sender as! UIButton
        let backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.gray.CGColor
        let item: AnyObject = items[button.tag]
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
            view.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    func deleteTopBorder(){
        self.topBorder.removeFromSuperlayer()
    }
    
    func clearView(){
        for view in self.viewToInsert!.subviews
        {
            view.removeFromSuperview()
        }
    }
    
    func buildViewForColors(items:[[String:AnyObject]]){
        if items.count > 0 {
            var unit = items.first!["value"] as! String
            if unit.contains("#"){
                unit = unit.substringFromIndex(unit.startIndex.advancedBy(1))
            }
            let intColor = UInt(unit, radix: 16)
            self.buildforColors = (intColor != nil)
        }
    }
}