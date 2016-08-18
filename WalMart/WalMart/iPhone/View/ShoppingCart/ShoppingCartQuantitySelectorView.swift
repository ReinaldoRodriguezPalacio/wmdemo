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
    var upcProduct : String!
    var btnOkAdd : UIButton!
    var keyboardView : NumericKeyboardView!
    var isUpcInShoppingCart : Bool = false
    var pickBar: ProductDetailPickBar!
    
    init(frame: CGRect, priceProduct : NSNumber!,upcProduct:String) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.upcProduct = upcProduct
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    func setup() {
        
        let startH : CGFloat = 0 //(self.bounds.height - 360) / 2
        
        self.backgroundColor = UIColor.clearColor()
        
        
        let bgView = UIView(frame:CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        bgView.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.93)
        
        let lblTitle = UILabel(frame:CGRectMake((self.frame.width / 2) - 115, startH + 10, 230, 14))
        lblTitle.font = WMFont.fontMyriadProSemiboldSize(12)
        lblTitle.textColor = UIColor.whiteColor()
        lblTitle.text = NSLocalizedString("shoppingcart.addquantitytitle",comment:"")
        lblTitle.textAlignment = NSTextAlignment.Center
        
        lblQuantity = UILabel(frame:CGRectMake((self.frame.width / 2) - (200 / 2), lblTitle.frame.maxY + 8 , 200, 26))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(32)
        lblQuantity.textColor = UIColor.whiteColor()
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.Center
        
     
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 24, 24))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.closeSelectQuantity), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.keyboardView = NumericKeyboardView(frame:CGRectMake((self.frame.width / 2) - (160/2), lblQuantity.frame.maxY + 8, 160, 190))
        //289
        self.keyboardView.generateButtons(UIColor.whiteColor().colorWithAlphaComponent(0.35), selected: UIColor.whiteColor())
        self.keyboardView.delegate = self
        
        btnOkAdd = UIButton(frame: CGRectMake((self.frame.width / 2) - 65, self.keyboardView.frame.maxY + 10 , 130, 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        let strPrice = CurrencyCustomLabel.formatString(priceProduct.stringValue)
        
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        var rectSize = CGRectZero
        
        if UserCurrentSession.sharedInstance().userHasUPCShoppingCart(self.upcProduct) {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            isUpcInShoppingCart = true
            
        } else {
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            isUpcInShoppingCart = false
        }
        
        
        btnOkAdd.frame =  CGRectMake((self.frame.width / 2) - ((rectSize.width + 32) / 2), self.keyboardView.frame.maxY + 15 , rectSize.width + 32, 36)
        if self.frame.height > 389 && !TabBarHidden.isTabBarHidden {
            self.pickBar = ProductDetailPickBar.initDefault(CGPointMake(0,self.frame.height - 92), width: self.frame.width)
        }else{
            self.pickBar = ProductDetailPickBar.initDefault(CGPointMake(0,self.frame.height - 46), width: self.frame.width)
        }
        self.pickBar.showHeader = false
        
        self.addSubview(bgView)
        self.addSubview(lblTitle)
        self.addSubview(lblQuantity)
        self.addSubview(btnOkAdd)
        self.addSubview(closeButton)
        self.addSubview(self.keyboardView)
        self.addSubview(self.pickBar)
        
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
            
            
            
            
            //btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            
            btnSender.imageView!.alpha = 0.35
            btnSender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                btnSender.imageView!.alpha = 0.1
                btnSender.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
                
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
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
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
        if first {
            var tmpResult : NSString = value
            tmpResult = tmpResult.integerValue < 10 ? "0\(value)" : value
            if tmpResult != "00"{
                lblQuantity.text = tmpResult as String
                first = false
            }
        } else {
            resultText = "\(lblQuantity.text!)\(value)"
            resultText = resultText.substringFromIndex(1)
            if resultText.integerValue > 0 && resultText.integerValue <= 99 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : NSString = "0\(value)"
                if tmpResult.integerValue > 0 {
                    lblQuantity.text = tmpResult as String
                }
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
        let intQuantity = Int(lblQuantity.text!)
        let result = priceProduct.doubleValue * Double(intQuantity!)
        let strPrice = CurrencyCustomLabel.formatString("\(result)")
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        
        var rectSize = CGRectZero
        if isUpcInShoppingCart {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            
        } else {
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.btnOkAdd.frame =  CGRectMake((self.frame.width / 2) - ((rectSize.width + 32) / 2),self.btnOkAdd.frame.minY , rectSize.width + 32, 36)
        })
    }
    
    
}