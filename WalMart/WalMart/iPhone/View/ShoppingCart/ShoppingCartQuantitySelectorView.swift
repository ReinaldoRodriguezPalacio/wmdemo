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
        
        self.backgroundColor = UIColor.clear
        
        
        let bgView = UIView(frame:CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        bgView.backgroundColor = WMColor.light_blue.withAlphaComponent(0.93)
        
        let lblTitle = UILabel(frame:CGRect(x: (self.frame.width / 2) - 115, y: startH + 17, width: 230, height: 16))
        lblTitle.font = WMFont.fontMyriadProSemiboldSize(16)
        lblTitle.textColor = UIColor.white
        lblTitle.text = NSLocalizedString("shoppingcart.addquantitytitle",comment:"")
        lblTitle.textAlignment = NSTextAlignment.center
        
        lblQuantity = UILabel(frame:CGRect(x: (self.frame.width / 2) - (200 / 2), y: lblTitle.frame.maxY + 20 , width: 200, height: 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.white
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.center
        
     
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.closeSelectQuantity), for: UIControlEvents.touchUpInside)
        
        self.keyboardView = NumericKeyboardView(frame:CGRect(x: (self.frame.width / 2) - (160/2), y: lblQuantity.frame.maxY + 10, width: 160, height: 196))
        //289
        self.keyboardView.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        self.keyboardView.delegate = self
        
        btnOkAdd = UIButton(frame: CGRect(x: (self.frame.width / 2) - 65, y: self.keyboardView.frame.maxY + 15 , width: 130, height: 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        let strPrice = CurrencyCustomLabel.formatString(priceProduct.stringValue as NSString)
        
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        
        var rectSize = CGRect.zero
        
        if UserCurrentSession.sharedInstance.userHasUPCShoppingCart(self.upcProduct) {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            isUpcInShoppingCart = true
            
        } else {
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            isUpcInShoppingCart = false
        }
        
        
        btnOkAdd.frame =  CGRect(x: (self.frame.width / 2) - ((rectSize.width + 32) / 2), y: self.keyboardView.frame.maxY + 15 , width: rectSize.width + 32, height: 36)
        
        self.addSubview(bgView)
        self.addSubview(lblTitle)
        self.addSubview(lblQuantity)
        self.addSubview(btnOkAdd)
        self.addSubview(closeButton)
        self.addSubview(self.keyboardView)
    }
    
    
    
    
    
    func chngequantity(_ sender:AnyObject) {
        
        if let btnSender = sender as? UIButton {
            var resultText : NSString = ""
            resultText = "\(lblQuantity.text!)\(btnSender.titleLabel!.text!)" as NSString
            resultText = resultText.substring(from: 1) as NSString
            if resultText.integerValue > 0 && resultText.integerValue <= 10 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : NSString = "0\(btnSender.titleLabel!.text!)" as NSString
                if tmpResult.integerValue > 0 {
                    lblQuantity.text = tmpResult as String
                }
            }
            
            
            
            
            //btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            
            btnSender.imageView!.alpha = 0.35
            btnSender.setTitleColor(UIColor.white, for: UIControlState())
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                btnSender.imageView!.alpha = 0.1
                btnSender.setTitleColor(WMColor.light_blue, for: UIControlState())
                
            })
            
        }
    }
    
    func deletequantity(_ sender:AnyObject) {
        
        
        
    }
    
    func addtoshoppingcart(_ sender:AnyObject) {
        
        addToCartAction(lblQuantity.text!)
    }
    
    
    
    func generateBlurImage(_ viewBg:UIView,frame:CGRect) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = blurredImage
        
        self.addSubview(imageBlurView)
        self.sendSubview(toBack: imageBlurView)
    }
    
    func closeSelectQuantity() {
        if closeAction != nil {
            closeAction()
        }
    }
    
    func userSelectValue(_ value:String!) {
        var resultText : NSString = ""
        if first {
            var tmpResult : String = value as String
            tmpResult = NSString(string:tmpResult).integerValue < 10 ? "0\(value!)" : "\(value!)"
            if tmpResult != "00"{
                lblQuantity.text = tmpResult as String
                first = false
            }
        } else {
            resultText = "\(lblQuantity.text!)\(value!)" as NSString
            resultText = resultText.substring(from: 1) as NSString
            if resultText.integerValue > 0 && resultText.integerValue <= 99 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : NSString = "0\(value!)" as NSString
                if tmpResult.integerValue > 0 {
                    lblQuantity.text = tmpResult as String
                }
            }
        }
        
        updateQuantityBtn()
        
    }

    
    func userSelectDelete() {
        let resultText : NSString = "0\(lblQuantity.text!)" as NSString
        lblQuantity.text = resultText.substring(to: 2)
        if lblQuantity.text == "00" {
            lblQuantity.text = "01"
            first = true
        }
        updateQuantityBtn()
    }
    
    func updateQuantityBtn(){
        let intQuantity = Int(lblQuantity.text!)
        let result = priceProduct.doubleValue * Double(intQuantity!)
        let strPrice = CurrencyCustomLabel.formatString("\(result)" as NSString)
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        
        var rectSize = CGRect.zero
        if isUpcInShoppingCart {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
        } else {
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.btnOkAdd.frame =  CGRect(x: (self.frame.width / 2) - ((rectSize.width + 32) / 2),y: self.btnOkAdd.frame.minY , width: rectSize.width + 32, height: 36)
        })
    }
    
    
}
