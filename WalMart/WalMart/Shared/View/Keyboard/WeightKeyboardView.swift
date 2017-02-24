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
    var separatorR : CGFloat = 23.0
    
    var weightBtnSelected: UIButton?
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
        generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
    }
    
    func generateButtons(_ normal: UIColor, selected: UIColor) {
        
        let imageNotSelected = generateCircleImage(normal, size: CGSize(width: widthButton, height: widthButton))
        let imageSelected = generateCircleImage(selected, size: CGSize(width: widthButton, height: widthButton))
        let yPosition = (frame.height == 320 && !IS_IPAD) ? (frame.height - 183) / 3 : 20
        
        btngramos = UIButton(frame: CGRect(x: 1, y: yPosition, width: widthButton, height: widthButton))
        btngramos.setTitle(strTitles[0], for: UIControlState())
        btngramos.setImage(imageNotSelected, for: UIControlState())
        btngramos.setImage(imageSelected, for: UIControlState.selected)
        
        btngramos.setTitleColor(UIColor.white, for: UIControlState())
        btngramos.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        btngramos.addTarget(self, action: #selector(WeightKeyboardView.seleccionboton(_:)), for: UIControlEvents.touchUpInside)
        btngramos.titleLabel?.numberOfLines = 2
        btngramos.titleLabel?.textAlignment = .center
        btngramos.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btngramos.tag = 100
        
        let insetTitle : CGFloat = btngramos.frame.width * -1
        btngramos.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle , 0.0, 0.0);
        
        btncuarto = UIButton(frame: CGRect(x: btngramos.frame.maxX + separatorR, y: yPosition, width: widthButton, height: widthButton))
        btncuarto.setTitle(strTitles[1], for: UIControlState())
        btncuarto.setImage(imageNotSelected, for: UIControlState())
        btncuarto.setImage(imageSelected, for: UIControlState.selected)
        btncuarto.setTitleColor(UIColor.white, for: UIControlState())
        btncuarto.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        btncuarto.addTarget(self, action: #selector(WeightKeyboardView.seleccionboton(_:)), for: UIControlEvents.touchUpInside)
        btncuarto.titleLabel?.numberOfLines = 2
        btncuarto.titleLabel?.textAlignment = .center
        btncuarto.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btncuarto.tag = 250
        
        let insetTitleC : CGFloat = btncuarto.frame.width * -1
        btncuarto.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitleC , 0.0, 0.0);
        
        btmediokilo = UIButton(frame: CGRect(x: btncuarto.frame.maxX + separatorR, y: yPosition, width: widthButton, height: widthButton))
        btmediokilo.setTitle(strTitles[2], for: UIControlState())
        btmediokilo.setImage(imageNotSelected, for: UIControlState())
        btmediokilo.setImage(imageSelected, for: UIControlState.selected)
        btmediokilo.setTitleColor(UIColor.white, for: UIControlState())
        btmediokilo.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        btmediokilo.addTarget(self, action: #selector(WeightKeyboardView.seleccionboton(_:)), for: UIControlEvents.touchUpInside)
        btmediokilo.titleLabel?.numberOfLines = 2
        btmediokilo.titleLabel?.textAlignment = .center
        btmediokilo.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        btmediokilo.tag = 500
        maxButtonX = btmediokilo.frame.maxX
        
        let insetTitleM : CGFloat = btmediokilo.frame.width * -1
        btmediokilo.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitleM , 0.0, 0.0);
        
        bttrescuartos = UIButton(frame: CGRect(x: 49, y: btngramos.frame.maxY + 10, width: widthButton, height: widthButton))
        bttrescuartos.setTitle(strTitles[3], for: UIControlState())
        bttrescuartos.setImage(imageNotSelected, for: UIControlState())
        bttrescuartos.setImage(imageSelected, for: UIControlState.selected)
        bttrescuartos.setTitleColor(UIColor.white, for: UIControlState())
        bttrescuartos.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        bttrescuartos.addTarget(self, action: #selector(WeightKeyboardView.seleccionboton(_:)), for: UIControlEvents.touchUpInside)
        bttrescuartos.titleLabel?.numberOfLines = 2
        bttrescuartos.titleLabel?.textAlignment = .center
        bttrescuartos.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(18)
        bttrescuartos.tag = 750
        
        let insetTitle3 : CGFloat = bttrescuartos.frame.width * -1
        bttrescuartos.titleEdgeInsets = UIEdgeInsetsMake(2.0, insetTitle3 , 0.0, 0.0);
        
        btunkilo = UIButton(frame: CGRect(x: bttrescuartos.frame.maxX + separatorR, y: btngramos.frame.maxY+10, width: widthButton, height: widthButton))
        btunkilo.setTitle(strTitles[4], for: UIControlState())
        btunkilo.setImage(imageNotSelected, for: UIControlState())
        btunkilo.setImage(imageSelected, for: UIControlState.selected)
        btunkilo.setTitleColor(UIColor.white, for: UIControlState())
        btunkilo.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        btunkilo.addTarget(self, action: #selector(WeightKeyboardView.seleccionboton(_:)), for: UIControlEvents.touchUpInside)
        btunkilo.titleLabel?.numberOfLines = 2
        btunkilo.titleLabel?.textAlignment = .center
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
    
    func seleccionboton(_ sender:UIButton) {
        
        btngramos.isSelected = false
        btncuarto.isSelected = false
        btmediokilo.isSelected = false
        bttrescuartos.isSelected = false
        btunkilo.isSelected = false
        
        sender.isSelected = sender != weightBtnSelected ? true : false
        
        switch(sender)
        {
        case btngramos:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_100_GR.rawValue , label:"")
            break;
        case btncuarto:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_250_GR.rawValue , label:"")
            break;
            
        case btmediokilo:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_500_GR.rawValue , label:"")
            break;
            
        case bttrescuartos:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_750_GR.rawValue , label:"")
            break;
        case btunkilo:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_TAPPED_1_KG.rawValue , label:"")
            break;
            
        default:
            print("Select other Button")
            break
            
        }
        
        if delegate != nil {
            weightBtnSelected = sender
            delegate.userSelectValue(String(sender.tag))
        }

    }
    
    func generateCircleImage (_ colorImage: UIColor, size: CGSize) -> UIImage {
        var screenShot: UIImage? = nil
        autoreleasepool {
            
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            tempView.backgroundColor = colorImage
            tempView.layer.cornerRadius = size.width / 2
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
            screenShot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        return screenShot!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.superview != nil {
            let currentX  : CGFloat = (self.superview!.frame.width / 2) -  (maxButtonX / 2)
            self.frame = CGRect(x: currentX, y: self.frame.minY, width: self.frame.width,  height: self.frame.height)
            print(self.frame)
            
        }
        
    }
    
}
