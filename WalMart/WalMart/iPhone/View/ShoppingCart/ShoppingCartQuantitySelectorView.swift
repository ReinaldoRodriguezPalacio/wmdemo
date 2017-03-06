//
//  ShoppingCartQuantitySelectorView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/24/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ShoppingCartQuantitySelectorView : UIView, KeyboardViewDelegate {
    
    let ZERO_QUANTITY_STRING = "00"
    
    var lblQuantity : UILabel!
    var imageBlurView : UIVisualEffectView!
    var first : Bool = true
    var addToCartAction : ((String) -> Void)!
    var closeAction : (() -> Void)!
    var priceProduct : NSNumber!
    var upcProduct : String!
    var btnOkAdd : UIButton!
    var keyboardView : NumericKeyboardView!
    var isUpcInShoppingCart : Bool = false
    var btnDelete : UIButton!
    var startY : CGFloat! = 0
    
    
    init(frame: CGRect, priceProduct : NSNumber!,upcProduct:String,startY: CGFloat = 0 ) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.upcProduct = upcProduct
        self.startY = startY
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.startY = 0
        setup()
    }

    func setup() {
        
        let startH : CGFloat = startY //(self.bounds.height - 360) / 2
        self.backgroundColor = UIColor.clear
        
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.3
        blurEffectView.frame = self.bounds
        self.imageBlurView = blurEffectView
        self.addSubview(imageBlurView!)
        
        let bgView = UIView(frame:CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        bgView.backgroundColor = WMColor.light_blue.withAlphaComponent(0.95)
        
        
        
        
        let lblTitle = UILabel(frame:CGRect(x: (self.frame.width / 2) - 115, y: startH + 17, width: 230, height: 14))
        lblTitle.font = WMFont.fontMyriadProSemiboldSize(14)
        lblTitle.textColor = UIColor.white
        if UserCurrentSession.sharedInstance.userHasUPCShoppingCart(self.upcProduct){
            lblTitle.text = NSLocalizedString("shoppingcart.updatequantitytitle",comment:"")
        } else {
             lblTitle.text = NSLocalizedString("shoppingcart.addquantitytitle",comment:"")
        }
        lblTitle.textAlignment = NSTextAlignment.center
        
        lblQuantity = UILabel(frame:CGRect(x: (self.frame.width / 2) - (200 / 2), y: lblTitle.frame.maxY + 20 , width: 200, height: 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.white
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.center
        
     
        var closePossitionY : CGFloat = IS_IPAD ? startH - 3 :  startH - 44
        closePossitionY = closePossitionY <= 0 ? 0 : closePossitionY
        let closeButton = UIButton(frame: CGRect(x: 0, y: closePossitionY, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.closeSelectQuantity), for: UIControlEvents.touchUpInside)
        
        self.keyboardView = NumericKeyboardView(frame:CGRect(x: (self.frame.width / 2) - (160/2), y: lblQuantity.frame.maxY + 10, width: 160, height: 196))
        //289
        self.keyboardView.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        self.keyboardView.delegate = self
        
        btnOkAdd = UIButton(frame: CGRect(x: (self.frame.width / 2) - 71, y: self.keyboardView.frame.maxY + 15 , width: 142, height: 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        let strPrice = CurrencyCustomLabel.formatString(priceProduct.stringValue as NSString)
        
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        
        btnDelete = UIButton(frame:CGRect(x:btnOkAdd.frame.maxX,y:btnOkAdd.frame.minY,width:self.bounds.width - btnOkAdd.frame.maxX ,height:36))
        btnDelete.setTitle(NSLocalizedString("shoppingcart.delete", comment: ""), for: .normal)
        btnDelete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        btnDelete.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deleteItems), for: .touchUpInside)
        
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
        self.addSubview(btnDelete)
        self.addSubview(closeButton)
        self.addSubview(self.keyboardView)
        
        if isUpcInShoppingCart {
            /*let btnDelete = UIButton(frame:CGRect(x:btnOkAdd.frame.maxX,y:btnOkAdd.frame.minY,width:self.bounds.width - btnOkAdd.frame.maxX ,height:36))
            btnDelete.setTitle(NSLocalizedString("shoppingcart.delete", comment: ""), for: .normal)
            btnDelete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            btnDelete.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.deleteItems), for: .touchUpInside)
            self.addSubview(btnDelete)*/
        }
        
        
    }
    
    func deleteItems() {
        self.lblQuantity.text = ZERO_QUANTITY_STRING
         updateQuantityBtn()
    }

    func chngequantity(_ sender:Any) {
        
        if let btnSender = sender as? UIButton {
            var resultText : String = ""
            resultText = lblQuantity.text! + btnSender.titleLabel!.text!
            resultText = (resultText as NSString).substring(from: 1)
            if (resultText as NSString).integerValue > 0 && (resultText as NSString).integerValue <= 10 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : String = "0" + btnSender.titleLabel!.text!
                if (tmpResult as NSString).integerValue > 0 {
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
    
    func deletequantity(_ sender:Any) {
        
        
        
    }
    
    func addtoshoppingcart(_ sender:Any) {
        addToCartAction(lblQuantity.text!)
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
            tmpResult = (tmpResult as NSString).integerValue < 10 ? "0\(value!)" : value!
            if tmpResult != ZERO_QUANTITY_STRING{
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
        
        if lblQuantity.text != "01" {
            self.keyboardView.showDeleteBtn()
        } else {
            self.keyboardView.hideDeleteBtn()
        }
        
        updateQuantityBtn()
        
    }

    func userSelectDelete() {
        
        let resultText : String = "0" + lblQuantity.text!
        lblQuantity.text = (resultText as NSString).substring(to: 2)
        
        if lblQuantity.text == "01" {
            self.keyboardView.hideDeleteBtn()
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
        
        if lblQuantity.text == ZERO_QUANTITY_STRING {
            self.btnOkAdd.backgroundColor = WMColor.red
            self.btnOkAdd.setTitle(NSLocalizedString("shoppingcart.deleteofcart", comment: ""), for: .normal)
            self.btnOkAdd.removeTarget(self, action: #selector(ShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAdd.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnDelete?.alpha = 0.0
            if !isUpcInShoppingCart {
                self.btnOkAdd.backgroundColor = WMColor.green
                let tmpResult : NSString = "00" as NSString
                lblQuantity.text = tmpResult as String
                btnOkAdd.setTitle("\(strAdddToSC) \("0.0")", for: UIControlState())
                let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \("0")", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
                rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            }
            
        } else {
            self.btnOkAdd.backgroundColor = WMColor.green
            self.btnOkAdd.removeTarget(self, action: #selector(ShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAdd.addTarget(self, action: #selector(ShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnDelete?.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.btnOkAdd.frame =  CGRect(x: (self.frame.width / 2) - ((rectSize.width + 32) / 2),y: self.btnOkAdd.frame.minY , width: rectSize.width + 32, height: 36)
        })
    }
    
    func deletefromshoppingcart(_ sender:AnyObject) {
        addToCartAction(lblQuantity.text!)
    }
    
    
    
    
    
}
