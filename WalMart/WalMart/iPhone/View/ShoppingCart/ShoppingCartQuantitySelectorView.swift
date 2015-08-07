//
//  ShoppingCartQuantitySelectorView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/24/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ShoppingCartQuantitySelectorView : UIView, KeyboardViewDelegate {
    
    var lblQuantity : UILabel!
    var imageBlurView : UIImageView!
    var first : Bool = true
    var addToCartAction : ((String) -> Void)!
    var closeAction : (() -> Void)!
    var priceProduct : NSNumber!
    var btnOkAdd : UIButton!
    
    
    
    init(frame: CGRect, priceProduct : NSNumber!) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    func setup() {
        
        let startH = (self.bounds.height - 360) / 2
        
        self.backgroundColor = UIColor.clearColor()
        
        
        let bgView = UIView(frame:CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        bgView.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        
        let lblTitle = UILabel(frame:CGRectMake((self.frame.width / 2) - 115, startH + 17, 230, 14))
        lblTitle.font = WMFont.fontMyriadProSemiboldSize(14)
        lblTitle.textColor = UIColor.whiteColor()
        lblTitle.text = NSLocalizedString("shoppingcart.addquantitytitle",comment:"")
        lblTitle.textAlignment = NSTextAlignment.Center
        
        lblQuantity = UILabel(frame:CGRectMake((self.frame.width / 2) - (200 / 2), lblTitle.frame.maxY + 20 , 200, 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.whiteColor()
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.Center
        
     
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeSelectQuantity", forControlEvents: UIControlEvents.TouchUpInside)
       
        
        var keyboard = NumericKeyboardView(frame:CGRectMake((self.frame.width / 2) - (160/2), lblQuantity.frame.maxY + 10, 160, 196))
        //289
        keyboard.generateButtons(WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.35), selected: WMColor.UIColorFromRGB(0xFFFFFF, alpha: 1.0))
        keyboard.delegate = self
        
        btnOkAdd = UIButton(frame: CGRectMake((self.frame.width / 2) - 71, keyboard.frame.maxY + 15 , 142, 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strPrice = CurrencyCustomLabel.formatString(priceProduct.stringValue)
        btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.productAddToCartPriceSelect
        btnOkAdd.addTarget(self, action: "addtoshoppingcart:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        self.addSubview(bgView)
        self.addSubview(lblTitle)
        self.addSubview(lblQuantity)
        self.addSubview(btnOkAdd)
        self.addSubview(closeButton)
        self.addSubview(keyboard)
    
     

        
    }
    
    
    
    
    
    func chngequantity(sender:AnyObject) {
        
        if let btnSender = sender as? UIButton {
            var resultText : NSString = ""
            
            
            resultText = lblQuantity.text! + btnSender.titleLabel!.text!
            resultText = resultText.substringFromIndex(1)
            if resultText.integerValue > 0 && resultText.integerValue <= 10 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : NSString = "0" + btnSender.titleLabel!.text!
                if tmpResult.integerValue > 0 {
                    lblQuantity.text = tmpResult as String
                }
            }
            
            let intQuantity = lblQuantity.text?.toInt()
            var result = priceProduct.doubleValue * Double(intQuantity!)
            let strPrice = CurrencyCustomLabel.formatString("\(result)")
            let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            
            btnSender.imageView!.alpha = 0.35
            btnSender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                btnSender.imageView!.alpha = 0.1
                btnSender.setTitleColor(WMColor.productAddToCartQuantitySelectorBgColor, forState: UIControlState.Normal)
            })
            
        }
        

        
        
    }
    
    func deletequantity(sender:AnyObject) {
        
        
        
    }
    
    func addtoshoppingcart(sender:AnyObject) {
        addToCartAction(lblQuantity.text!)
    }
    
    
    
    func generateBlurImage(viewBg:UIView,frame:CGRect) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = blurredImage
        
        self.addSubview(imageBlurView)
        self.sendSubviewToBack(imageBlurView)
    }
    
    func closeSelectQuantity() {
        if closeAction != nil {
            closeAction()
        }
    }
    
    func userSelectValue(value:String!) {
        var resultText : NSString = ""
        
        resultText = "\(lblQuantity.text!)\(value)"
        resultText = resultText.substringFromIndex(1)
        if resultText.integerValue > 0 && resultText.integerValue <= 10 {
            lblQuantity.text = resultText as String
        }else {
            let tmpResult : NSString = "0\(value)"
            if tmpResult.integerValue > 0 {
                lblQuantity.text = tmpResult as String
            }
        }
      
        updateQuantityBtn()
       
    }
    
    func userSelectDelete() {
        let resultText : NSString = "0" + lblQuantity.text!
        lblQuantity.text = resultText.substringToIndex(2)
        if lblQuantity.text == "00" {
            lblQuantity.text = "01"
            first = true
        }
        updateQuantityBtn()
    }
    
    func updateQuantityBtn(){
        let intQuantity = lblQuantity.text?.toInt()
        var result = priceProduct.doubleValue * Double(intQuantity!)
        let strPrice = CurrencyCustomLabel.formatString("\(result)")
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
    }
    
    
}