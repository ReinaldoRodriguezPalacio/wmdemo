//
//  ProductDetailColorView.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


protocol ProductDetailColorSizeDelegate {
    func selectDetailItem(_ selected:String, itemType: String)
}

class ProductDetailColorSizeView: UIView {
    let buttonWidth = 20
    let buttonSpace = 30
    let backViewWidth = 28
    var items:[[String : Any]]! = nil
    var viewToInsert: UIView? = nil
    var scrollView: UIScrollView? = nil
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
        
        self.bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.size.width, height: 1)
        self.topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: 1)
        buildItemsView()
    }

    
    func setup() {
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.scrollView?.isScrollEnabled = false
        self.viewToInsert = UIView(frame: self.frame)
        self.viewToInsert! = self
        self.bottomBorder = CALayer()
        self.bottomBorder.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(bottomBorder, at: 99)
        self.topBorder = CALayer()
        self.topBorder.backgroundColor = WMColor.light_light_gray.cgColor
        if self.showTopBorder {
          self.layer.insertSublayer(topBorder, at: 100)
        }
        buildItemsView()
    }
    
    func buildItemsView()
    {
        if items == nil { items = []}
        if items.count != 0 && self.subviews.count == 0{
            var butonsWidthCenter: CGFloat = CGFloat(buttonSpace)
            
            for item in self.items{
                if self.buildItemForColor(item){
                    butonsWidthCenter += CGFloat(backViewWidth) + CGFloat(buttonSpace)
                }else{
                    butonsWidthCenter += self.getButtonWidth(item["value"] as? String) + CGFloat(buttonSpace)
                }
            }
            butonsWidthCenter += CGFloat(buttonSpace)
            butonsWidthCenter = butonsWidthCenter / 2
            
            let viewWidthCenter = self.frame.width / 2
            let buttonPositionY = CGFloat(self.frame.height / 2) - CGFloat(backViewWidth / 2)
            var startPos = CGFloat(viewWidthCenter) - CGFloat(butonsWidthCenter)
            if CGFloat(self.frame.width) < CGFloat(butonsWidthCenter * 2)
            {
                self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                self.scrollView!.isScrollEnabled = true
                self.scrollView!.contentSize = CGSize(width: CGFloat(butonsWidthCenter * 2), height: self.frame.height)
                viewToInsert = self.scrollView!
                self.addSubview(scrollView!)
                startPos = 0
            }
        
            var position = startPos
            var count = 0
            for item in self.items {
                position += CGFloat(buttonSpace)
                if self.buildItemForColor(item){
                    self.buildColorButton(item, position: position, buttonPositionY: buttonPositionY, count: count)
                    position += CGFloat(backViewWidth)
                }else{
                    let backViewSizeWidth = self.buildTextButton(item, position: position, buttonPositionY: buttonPositionY, count: count)
                    position += CGFloat(backViewSizeWidth)
                 
                }
                count += 1
            }
        }
    }
    
    func buildColorButton(_ item: [String:Any], position:CGFloat, buttonPositionY:CGFloat, count: Int){
        let backView = UIView(frame: CGRect(x: position, y: buttonPositionY, width: CGFloat(backViewWidth), height: CGFloat(backViewWidth)))
        backView.layer.cornerRadius = 4
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProductDetailColorSizeView.backViewTap(_:)))
        backView.addGestureRecognizer(tap)
            
        let colorButton = UIButton(type: UIButtonType.custom)
        let buttonPosition = (CGFloat(backViewWidth) - CGFloat(buttonWidth)) / 2
        colorButton.frame = CGRect(x: CGFloat(buttonPosition), y: CGFloat(buttonPosition), width: CGFloat(buttonWidth), height: CGFloat(buttonWidth))
        colorButton.layer.cornerRadius = 2
        var stringColor: String = item["value"]! as! String
        if stringColor.contains("#"){
            stringColor = stringColor.substring(from: stringColor.characters.index(stringColor.startIndex, offsetBy: 1))
        }
        let intColor = UInt(stringColor, radix: 16)
        colorButton.backgroundColor = WMColor.UIColorFromRGB(intColor!, alpha: 1.0)
        colorButton.addTarget(self, action: #selector(ProductDetailColorSizeView.selectColor(_:)), for: UIControlEvents.touchUpInside)
        colorButton.tag = count
        if intColor >= 16770000 {
            colorButton.layer.borderWidth = 0.5
            colorButton.layer.borderColor = WMColor.dark_gray.cgColor
            colorButton.layer.cornerRadius = 2
        }else{
            colorButton.layer.borderColor = UIColor.white.cgColor
            colorButton.layer.borderWidth = 0.0
        }
        
        if item["selected"]! as! Bool {
            backView.layer.borderWidth = 1
            backView.layer.borderColor = WMColor.gray.cgColor
        }

        backView.addSubview(colorButton)
        self.viewToInsert!.addSubview(backView)
    }
    
    func buildTextButton(_ item: [String:Any], position:CGFloat, buttonPositionY:CGFloat, count: Int) -> CGFloat{
        let sizeButonWidth = self.getButtonWidth(item["value"] as? String)
        let backViewSizeWidth = sizeButonWidth + 7.0
        let backView = UIView(frame: CGRect(x: position, y: buttonPositionY, width: backViewSizeWidth , height: CGFloat(backViewWidth)))
        backView.layer.cornerRadius = 4
            
        let sizeButton = UIButton(type: UIButtonType.custom)
        let buttonPosition = (CGFloat(backViewSizeWidth) - CGFloat(sizeButonWidth)) / 2
        sizeButton.frame = CGRect(x: CGFloat(buttonPosition), y: 4.8,width: sizeButonWidth , height: CGFloat(buttonWidth))
        sizeButton.layer.cornerRadius = 2
        sizeButton.setTitle(item["value"] as? String, for: UIControlState())
        sizeButton.setTitleColor(WMColor.dark_gray, for: UIControlState())
        sizeButton.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
        sizeButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        sizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        sizeButton.addTarget(self, action: #selector(ProductDetailColorSizeView.selectSize(_:)), for: UIControlEvents.touchUpInside)
        if let enabled = item["enabled"] as? Bool {
             sizeButton.isEnabled = enabled
        }else if let enabled = item["enabled"] as? NSNumber {
            sizeButton.isEnabled = enabled.boolValue
        }else{
            print("Error no return enabled value")
            sizeButton.isEnabled = false
        }
       
        sizeButton.tag = count
        
        if item["selected"]! as! Bool {
            backView.layer.borderWidth = 1
            backView.layer.borderColor = WMColor.gray.cgColor
        }

        backView.addSubview(sizeButton)
        self.viewToInsert!.addSubview(backView)
        return backViewSizeWidth
    }

    
    func getButtonWidth(_ text:String?) -> CGFloat {
        let stringSize = text!.size(attributes: [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14)])
        let buttonWidth = stringSize.width < 13 ? 13 : stringSize.width
        return buttonWidth
    }

    func backViewTap(_ sender: UIGestureRecognizer){
        let backView = sender.view!
        let button  = backView.subviews[0] as! UIButton
        selectColor(button)
    }
    
    func selectColor(_ sender: Any)
    {
        self.clearColorButtons()
        let button  = sender as! UIButton
        let backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.gray.cgColor
        let item: [String:Any] = items[button.tag]
        delegate?.selectDetailItem(item["value"] as! String, itemType: item["type"] as! String)
    }
    
    
    func selectSize(_ sender: Any)
    {
        self.clearColorButtons()
        let button  = sender as! UIButton
        let backView = button.superview!
        backView.layer.borderWidth = 1
        backView.layer.borderColor = WMColor.gray.cgColor
        let item: [String:Any] = items[button.tag]
        delegate?.selectDetailItem(item["value"] as! String, itemType: item["type"] as! String)
    }
    
    func enableButtonWhithTitles(_ titles: [String])
    {
        clearColorButtons()
        for title in titles{
            for view in self.viewToInsert!.subviews {
                if view.subviews.count > 0 && view.subviews[0].isKind(of: UIButton.self){
                    let button = view.subviews[0] as! UIButton
                    button.isEnabled = (button.titleLabel?.text == title)
                    if titles.count == 1 && button.isEnabled{
                        button.sendActions(for: UIControlEvents.touchUpInside)
                    }
                }
            }
        }
    }
    
    func selectButton(_ selected: String){
        var count = 0
        for item in self.items{
            if item["value"] as! String == selected{
                break
            }
            count += 1
        }
        
        for view in self.viewToInsert!.subviews {
            if view.subviews.count > 0 && view.subviews[0].isKind(of: UIButton.self){
                let button = view.subviews[0] as! UIButton
                if button.tag == count {
                    button.sendActions(for: UIControlEvents.touchUpInside)
                }
            }
        }
    }
    
    func clearColorButtons(){
        for view in self.viewToInsert!.subviews
        {
            view.layer.borderWidth = 0
            view.layer.borderColor = UIColor.white.cgColor
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
    
    func buildItemForColor(_ item:[String:Any]) -> Bool{
        var buildForColors = false
        var unit = item["value"] as! String
        if unit.contains("#"){
            unit = unit.substring(from: unit.characters.index(unit.startIndex, offsetBy: 1))
        }
        let intColor = UInt(unit, radix: 16)
        buildForColors = (intColor != nil)
        return buildForColors
    }
}
