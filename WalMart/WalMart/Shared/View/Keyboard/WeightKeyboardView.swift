//
//  WeightKeyboardView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/6/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class WeightKeyboardView : UIView {
    
    var widthButton : CGFloat = 80.0
    var separatorR : CGFloat = 24.0
    
    var btngramos : UIButton!
    var btncuarto : UIButton!
    var btmediokilo : UIButton!
    var bttrescuartos : UIButton!
    var btunkilo : UIButton!
    var maxButtonX : CGFloat! = 0
    var delegate : KeyboardViewDelegate!
    
    var strTitles : [String] = ["100 gramos","un\ncuarto","medio kilo","tres cuartos","un\nkilo"]
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generateButtons(WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.35), selected: WMColor.UIColorFromRGB(0xFFFFFF, alpha: 1.0))
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        generateButtons(WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.35), selected: WMColor.UIColorFromRGB(0xFFFFFF, alpha: 1.0))
    }
    
    
    func generateButtons(normal:UIColor,selected:UIColor) {
        
        let imageNotSelected = generateCircleImage(normal, size: CGSizeMake(widthButton, widthButton))
        let imageSelected = generateCircleImage(selected, size:CGSizeMake(widthButton, widthButton))
        
        btngramos = UIButton(frame: CGRectMake(0, 0, widthButton, widthButton))
        btngramos.setTitle(strTitles[0], forState: UIControlState.Normal)
        btngramos.setImage(imageNotSelected, forState: UIControlState.Normal)
        btngramos.setImage(imageSelected, forState: UIControlState.Selected)
        
        btngramos.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btngramos.setTitleColor(WMColor.productAddToCartQuantitySelectorBgColor, forState: UIControlState.Selected)
        btngramos.addTarget(self, action: "seleccionboton:", forControlEvents: UIControlEvents.TouchUpInside)
        btngramos.titleLabel?.numberOfLines = 2
        btngramos.titleLabel?.textAlignment = .Center
        btngramos.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btngramos.tag = 100
        
        
        let insetTitle : CGFloat = btngramos.frame.width * -1
        btngramos.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle , 0.0, 0.0);
        
        btncuarto = UIButton(frame: CGRectMake(btngramos.frame.maxX + separatorR, 0, widthButton, widthButton))
        btncuarto.setTitle(strTitles[1], forState: UIControlState.Normal)
        btncuarto.setImage(imageNotSelected, forState: UIControlState.Normal)
        btncuarto.setImage(imageSelected, forState: UIControlState.Selected)
        btncuarto.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btncuarto.setTitleColor(WMColor.productAddToCartQuantitySelectorBgColor, forState: UIControlState.Selected)
        btncuarto.addTarget(self, action: "seleccionboton:", forControlEvents: UIControlEvents.TouchUpInside)
        btncuarto.titleLabel?.numberOfLines = 2
        btncuarto.titleLabel?.textAlignment = .Center
        btncuarto.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btncuarto.tag = 250

        
        let insetTitleC : CGFloat = btncuarto.frame.width * -1
        btncuarto.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitleC , 0.0, 0.0);
        
        btmediokilo = UIButton(frame: CGRectMake(btncuarto.frame.maxX + separatorR, 0, widthButton, widthButton))
        btmediokilo.setTitle(strTitles[2], forState: UIControlState.Normal)
        btmediokilo.setImage(imageNotSelected, forState: UIControlState.Normal)
        btmediokilo.setImage(imageSelected, forState: UIControlState.Selected)
        btmediokilo.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btmediokilo.setTitleColor(WMColor.productAddToCartQuantitySelectorBgColor, forState: UIControlState.Selected)
        btmediokilo.addTarget(self, action: "seleccionboton:", forControlEvents: UIControlEvents.TouchUpInside)
        btmediokilo.titleLabel?.numberOfLines = 2
        btmediokilo.titleLabel?.textAlignment = .Center
        btmediokilo.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btmediokilo.tag = 500
        maxButtonX = btmediokilo.frame.maxX


        
        let insetTitleM : CGFloat = btmediokilo.frame.width * -1
        btmediokilo.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitleM , 0.0, 0.0);
        
        bttrescuartos = UIButton(frame: CGRectMake(49, btngramos.frame.maxY+10, widthButton, widthButton))
        bttrescuartos.setTitle(strTitles[3], forState: UIControlState.Normal)
        bttrescuartos.setImage(imageNotSelected, forState: UIControlState.Normal)
        bttrescuartos.setImage(imageSelected, forState: UIControlState.Selected)
        bttrescuartos.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        bttrescuartos.setTitleColor(WMColor.productAddToCartQuantitySelectorBgColor, forState: UIControlState.Selected)
        bttrescuartos.addTarget(self, action: "seleccionboton:", forControlEvents: UIControlEvents.TouchUpInside)
        bttrescuartos.titleLabel?.numberOfLines = 2
        bttrescuartos.titleLabel?.textAlignment = .Center
        bttrescuartos.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        bttrescuartos.tag = 750



        
        let insetTitle3 : CGFloat = bttrescuartos.frame.width * -1
        bttrescuartos.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle3 , 0.0, 0.0);
        
        btunkilo = UIButton(frame: CGRectMake(bttrescuartos.frame.maxX + separatorR, btngramos.frame.maxY+10, widthButton, widthButton))
        btunkilo.setTitle(strTitles[4], forState: UIControlState.Normal)
        btunkilo.setImage(imageNotSelected, forState: UIControlState.Normal)
        btunkilo.setImage(imageSelected, forState: UIControlState.Selected)
        btunkilo.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btunkilo.setTitleColor(WMColor.productAddToCartQuantitySelectorBgColor, forState: UIControlState.Selected)
        btunkilo.addTarget(self, action: "seleccionboton:", forControlEvents: UIControlEvents.TouchUpInside)
        btunkilo.titleLabel?.numberOfLines = 2
        btunkilo.titleLabel?.textAlignment = .Center
        btunkilo.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btunkilo.tag = 1000


        
        let insetTitle1 : CGFloat = btunkilo.frame.width * -1
        btunkilo.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle1 , 0.0, 0.0);
        
        self.addSubview(btngramos)
        self.addSubview(btncuarto)
        self.addSubview(btmediokilo)
        self.addSubview(bttrescuartos)
        self.addSubview(btunkilo)
        
    }
    
    func seleccionboton(sender:UIButton) {
        
        btngramos.selected = false
        btncuarto.selected = false
        btmediokilo.selected = false
        bttrescuartos.selected = false
        btunkilo.selected = false
        
        sender.selected = true
        
        switch(sender)
        {
        case btngramos:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_100_GR.rawValue , label:"")
            break;
        case btncuarto:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_250_GR.rawValue , label:"")
            break;
            
        case btmediokilo:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_500_GR.rawValue , label:"")
            break;
            
        case bttrescuartos:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_750_GR.rawValue , label:"")
            break;
        case btunkilo:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_1_KG.rawValue , label:"")
            break;
            
        default:
            print("Select other Button")
            break
            
        }
        
        if delegate != nil {
            delegate.userSelectValue(String(sender.tag))
        }

    }
    
    
    func generateCircleImage (colorImage:UIColor,size:CGSize) -> UIImage {
        var screenShot : UIImage? = nil
        autoreleasepool {
            let tempView = UIView(frame: CGRectMake(0, 0, size.width, size.height))
            tempView.backgroundColor = colorImage
            tempView.layer.cornerRadius = size.width / 2
            
            UIGraphicsBeginImageContext(size);
            tempView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        return screenShot!
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.superview != nil {
            let currentX  : CGFloat = (self.superview!.frame.width / 2) -  (maxButtonX / 2)
            self.frame = CGRectMake(currentX, self.frame.minY, self.frame.width,  self.frame.height)
            print(self.frame)
            
        }
        
    }
    
}