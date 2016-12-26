//
//  NumericKeyboardView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/6/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol KeyboardViewDelegate {
    func userSelectValue(_ value:String!)
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
    
    var btnDelete = UIButton()
    
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

    
    func changeType(_ typeKeyboard:NumericKeyboardViewType) {
        for viewChild in self.subviews {
            viewChild.removeFromSuperview()
        }
        self.typeKeyboard = typeKeyboard
        self.generateButtons(normal, selected: selected)
    }
    
    func generateButtons(_ normal:UIColor,selected:UIColor,numberOfButtons: Int) {
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
        
        let imageNotSelected = generateCircleImage(normal, size: CGSize(width: widthButton, height: widthButton))
        let imageSelected = generateCircleImage(selected, size:CGSize(width: widthButton, height: widthButton))
        
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
            
            let btnNumber = UIButton(frame: CGRect(x: currentX, y: currentY, width: widthButton, height: widthButton))
            btnNumber.setTitle(txtButton, for: UIControlState())
            
            btnNumber.setTitleColor(UIColor.white, for: UIControlState())
            btnNumber.setTitleColor(WMColor.light_blue, for: UIControlState.highlighted)
            
            btnNumber.setImage(imageNotSelected, for: UIControlState())
            btnNumber.setImage(imageSelected, for: UIControlState.highlighted)
            
            let insetTitle : CGFloat = btnNumber.frame.width * -1
            
            btnNumber.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle , 0.0, 0.0);
            
            let titleSize = btnNumber.titleLabel!.frame.size
            let insetImage2 : CGFloat = titleSize.width * -1
            
            btnNumber.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, insetImage2);
            let buttonFontSize: CGFloat = self.widthButton <= 40 ? 18.0 : 30.0
            btnNumber.titleLabel!.font = WMFont.fontMyriadProSemiboldSize(buttonFontSize)
            btnNumber.titleLabel!.textAlignment = NSTextAlignment.center
            btnNumber.addTarget(self, action: #selector(NumericKeyboardView.chngequantity(_:)), for: UIControlEvents.touchUpInside)
            
            self.addSubview(btnNumber)
            
            currentX = btnNumber.frame.maxX +  widthBetweenButtons
            if index % 3 == 0 {
                currentX =  0
                currentY += 12 + widthButton
            }
            
        }
        
        btnDelete = UIButton(frame: CGRect(x: currentX, y: currentY, width: self.widthButton, height: self.widthButton))
        btnDelete.setTitle("Borrar", for: UIControlState())
        let buttonFontSize: CGFloat = self.widthButton <= 40 ? 12.0 : 18.0
        btnDelete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(buttonFontSize)
        btnDelete.addTarget(self, action: #selector(NumericKeyboardView.deletequantity(_:)), for: UIControlEvents.touchUpInside)
        btnDelete.tag = 999
        hideDeleteBtn()
        self.addSubview(btnDelete)
    
    }
    
    func generateButtons(_ normal:UIColor,selected:UIColor) {
        var nomberOfButtons = 10
        if typeKeyboard == NumericKeyboardViewType.Decimal {
            nomberOfButtons = 11
        }
        self.generateButtons(normal, selected: selected, numberOfButtons: nomberOfButtons)
    }
    
    func generateCircleImage (_ colorImage:UIColor,size:CGSize) -> UIImage {
        var screenShot : UIImage? = nil
        autoreleasepool {
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            tempView.backgroundColor = colorImage
            tempView.layer.cornerRadius = size.width / 2
            
            //UIGraphicsBeginImageContext(size);
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
            screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        return screenShot!
    }
    
    func hideDeleteBtn() {
        btnDelete.isEnabled = false
        btnDelete.isHidden = true
    }
    
    func showDeleteBtn() {
        btnDelete.isEnabled = true
        btnDelete.isHidden = false
    }
    
    func chngequantity(_ sender:UIButton) {
        if delegate != nil {
            self.delegate.userSelectValue("\(sender.titleLabel!.text!)")
        }
    }
    
    func deletequantity(_ sender:UIButton) {
        if delegate != nil {
            //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ERASE_QUANTITY.rawValue, label: "")
            self.delegate.userSelectDelete()
        }
    }
    
}
