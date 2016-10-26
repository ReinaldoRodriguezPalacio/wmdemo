//
//  NumericKeyboardView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/6/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol KeyboardViewDelegate {
    func userSelectValue(value:String!)
    func userSelectDelete()
}

enum NumericKeyboardViewType : String {
    case Integer = "Int"
    case Decimal = "Decimal"
}

class NumericKeyboardView : UIView {
    
    
    var widthButton : CGFloat = 40.0
    var delegate : KeyboardViewDelegate!
    var typeKeyboard : NumericKeyboardViewType! = NumericKeyboardViewType.Integer
    
    var normal : UIColor!
    var selected : UIColor!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.typeKeyboard = NumericKeyboardViewType.Integer
    }
    
    init(frame: CGRect, typeKeyboard:NumericKeyboardViewType) {
        super.init(frame: frame)
        self.typeKeyboard = typeKeyboard
    }

    
    func changeType(typeKeyboard:NumericKeyboardViewType) {
        for viewChild in self.subviews {
            viewChild.removeFromSuperview()
        }
        self.typeKeyboard = typeKeyboard
        self.generateButtons(normal, selected: selected)
    }
    
    func generateButtons(normal:UIColor,selected:UIColor,numberOfButtons: Int) {
        self.normal = normal
        self.selected = selected
        
        var currentX : CGFloat = 0
        var currentY : CGFloat = 0
        var widthBetweenButtons : CGFloat = 0
        if self.frame.width > (widthButton * 3) {
            widthBetweenButtons = (self.frame.width - (widthButton * 3)) / 2
        }
        
        if widthButton > 40 {
            widthBetweenButtons = 24
        }
        
        let imageNotSelected = generateCircleImage(normal, size: CGSizeMake(widthButton, widthButton))
        let imageSelected = generateCircleImage(selected, size:CGSizeMake(widthButton, widthButton))
        
        for index in 1...numberOfButtons {
            
            var txtButton = "\(index)"
            if typeKeyboard == NumericKeyboardViewType.Integer {
                if index == 10 {
                    currentX += widthButton + widthBetweenButtons
                    txtButton = "0"
                }
            } else {
                if index == 10 {
                    txtButton = "."
                }
                if index == 11 {
                    txtButton = "0"
                }
            }
            
            let btnNumber = UIButton(frame: CGRectMake(currentX, currentY, widthButton, widthButton))
            btnNumber.setTitle(txtButton, forState: UIControlState.Normal)
            
            btnNumber.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btnNumber.setTitleColor(WMColor.light_blue, forState: UIControlState.Highlighted)
            
            btnNumber.setImage(imageNotSelected, forState: UIControlState.Normal)
            btnNumber.setImage(imageSelected, forState: UIControlState.Highlighted)
            
            
            let insetTitle : CGFloat = btnNumber.frame.width * -1
            
            btnNumber.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle , 0.0, 0.0);
            
            let titleSize = btnNumber.titleLabel!.frame.size
            let insetImage2 : CGFloat = titleSize.width * -1
            
            btnNumber.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, insetImage2);
            let buttonFontSize: CGFloat = self.widthButton <= 40 ? 18.0 : 30.0
            btnNumber.titleLabel!.font = WMFont.fontMyriadProSemiboldSize(buttonFontSize)
            btnNumber.titleLabel!.textAlignment = NSTextAlignment.Center
            btnNumber.addTarget(self, action: #selector(NumericKeyboardView.chngequantity(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            
            
            self.addSubview(btnNumber)
            
            currentX = btnNumber.frame.maxX +  widthBetweenButtons
            if index % 3 == 0 {
                currentX =  0
                currentY += 12 + widthButton
            }
            
        }
        
        let btnDelete = UIButton(frame: CGRectMake(currentX, currentY, self.widthButton, self.widthButton))
        btnDelete.setTitle("Borrar", forState: UIControlState.Normal)
        let buttonFontSize: CGFloat = self.widthButton <= 40 ? 12.0 : 18.0
        btnDelete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(buttonFontSize)
        btnDelete.addTarget(self, action: #selector(NumericKeyboardView.deletequantity(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnDelete.tag = 999
        self.addSubview(btnDelete)
    
    }
    
    
    func generateButtons(normal:UIColor,selected:UIColor) {
        var nomberOfButtons = 10
        if typeKeyboard == NumericKeyboardViewType.Decimal {
            nomberOfButtons = 11
        }
        self.generateButtons(normal, selected: selected, numberOfButtons: nomberOfButtons)
    }
    
    func generateCircleImage (colorImage:UIColor,size:CGSize) -> UIImage {
        var screenShot : UIImage? = nil
        autoreleasepool {
            let tempView = UIView(frame: CGRectMake(0, 0, size.width, size.height))
            tempView.backgroundColor = colorImage
            tempView.layer.cornerRadius = size.width / 2
            
            //UIGraphicsBeginImageContext(size);
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            tempView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        return screenShot!
    }
    
    func chngequantity(sender:UIButton) {
        if delegate != nil {
            self.delegate.userSelectValue("\(sender.titleLabel!.text!)")
        }
    }
    
    
    func deletequantity(sender:UIButton) {
        if delegate != nil {
            //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ERASE_QUANTITY.rawValue, label: "")
            self.delegate.userSelectDelete()
        }
    }
    
    
}