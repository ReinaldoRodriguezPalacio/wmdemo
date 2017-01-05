//
//  GRShoppingCartQuantitySelectorView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/12/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRShoppingCartQuantitySelectorView : UIView, KeyboardViewDelegate {

    var lblQuantity : UILabel!
    var imageBlurView : UIImageView!
    var first : Bool = true
    var addToCartAction : ((String) -> Void)!
    var addUpdateNote : (() -> Void)!
    var closeAction : (() -> Void)!
    var priceProduct : NSNumber!
    var upcProduct : String!
    var btnOkAdd : UIButton!
    var btnNote : UIButton!
    var btnNoteComplete : UIButton!
    var isUpcInShoppingCart : Bool = false
    
    
    var backgroundView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
   init(frame: CGRect, priceProduct : NSNumber!,upcProduct:String) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.upcProduct = upcProduct
        setup()
    }
    
    
    init(frame: CGRect,priceProduct:NSNumber!,quantity:Int!,upcProduct:String) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.upcProduct = upcProduct
        setup()
        let text = String(quantity).characters.count < 2 ? "0" : ""
        lblQuantity.text = "\(text)"+"\(quantity!)"
        self.updateQuantityBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        
        let startH : CGFloat = 0
        
        self.backgroundColor = UIColor.clear
        
        
        self.backgroundView = UIView(frame:CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        self.backgroundView!.backgroundColor = WMColor.light_blue.withAlphaComponent(0.93)
        
        let lblTitle = UILabel(frame:CGRect(x: (self.frame.width / 2) - 115, y: startH + 17, width: 230, height: 14))
        lblTitle.font = WMFont.fontMyriadProSemiboldSize(14)
        lblTitle.textColor = UIColor.white
        lblTitle.text = NSLocalizedString("shoppingcart.addweighttitle",comment:"")
        lblTitle.textAlignment = NSTextAlignment.center
        
        lblQuantity = UILabel(frame:CGRect(x: (self.frame.width / 2) - (200 / 2), y: lblTitle.frame.maxY + 20 , width: 200, height: 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.white
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.center
        
        
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.closeSelectQuantity), for: UIControlEvents.touchUpInside)
        
        
        
        let keyboard = NumericKeyboardView(frame:CGRect(x: (self.frame.width / 2) - (160/2), y: lblQuantity.frame.maxY + 10, width: 160, height: 196),typeKeyboard:NumericKeyboardViewType.Integer)
        //289
        keyboard.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        keyboard.delegate = self
        
        btnOkAdd = UIButton(frame: CGRect(x: (self.frame.width / 2) - 71, y: keyboard.frame.maxY + 15 , width: 142, height: 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        btnOkAdd.setTitle("\(strAdddToSC) $0.00", for: UIControlState())
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        
        
        if UserCurrentSession.sharedInstance.userHasUPCShoppingCart(self.upcProduct) {
            isUpcInShoppingCart = true
        } else {
            isUpcInShoppingCart = false
        }

        
        
        updateQuantityBtn()
        
        
        
        btnNote = UIButton(frame: CGRect(x: (self.frame.width) - 48, y: keyboard.frame.maxY + 15 , width: 40, height: 40))
        btnNote.setImage(UIImage(named:"notes_keyboard"), for: UIControlState())
        btnNote.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.updateOrAddNote), for: UIControlEvents.touchUpInside)
        btnNote.alpha = 0
        self.addSubview(btnNote)
        
        
        btnNoteComplete = UIButton(frame: CGRect(x: 0, y: btnOkAdd.frame.maxY + 10, width: self.frame.width, height: 40))
        btnNoteComplete.setImage(UIImage(named: "notes_alert"), for: UIControlState())
        self.btnNoteComplete!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
        btnNoteComplete.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.updateOrAddNote), for: UIControlEvents.touchUpInside)
        btnNoteComplete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNoteComplete.alpha = 0
        
        self.addSubview(self.backgroundView!)
        self.addSubview(lblTitle)
        self.addSubview(lblQuantity)
        self.addSubview(btnOkAdd)
        self.addSubview(closeButton)
        self.addSubview(keyboard)
        self.addSubview(btnNote)
        self.addSubview(btnNoteComplete)
    }
    
    func updateOrAddNote() {
        
        if (addUpdateNote != nil) {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTE_IN_KEY_BOARD.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_NOTE_IN_KEY_BOARD.rawValue, action:WMGAIUtils.ACTION_OPEN_NOTE.rawValue, label: self.upcProduct)
            addUpdateNote()
        }
    }
    
    func chngequantity(_ sender:AnyObject) {
        
        if let btnSender = sender as? UIButton {
            var resultText : NSString = ""
            
            
            resultText = "\(lblQuantity!.text!)\(btnSender.titleLabel!.text!)" as NSString
            resultText = resultText.substring(from: 1) as NSString
            if resultText.integerValue > 0 && resultText.integerValue <= 10 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : NSString = "0\(btnSender.titleLabel!.text!)" as NSString
                if tmpResult.integerValue > 0 {
                    lblQuantity.text = tmpResult as String
                }
            }
            
            
            
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
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_QUANTITY_KEYBOARD_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_QUANTITY_KEYBOARD_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_CLOSE_KEYBOARD.rawValue , label:"")
            closeAction()
        }
    }
    
    func userSelectValue(_ value:String!) {
        var resultText : NSString = ""
        
        if first {
            var tmpResult : NSString = value as NSString
            tmpResult = tmpResult.integerValue < 10 ? "0\(value)" as NSString : "\(value)" as NSString
            if tmpResult != "00"{
            lblQuantity.text = tmpResult as String
                first = false
            }
        } else {
            resultText = "\(lblQuantity!.text!)\(value)" as NSString
            resultText = resultText.substring(from: 1) as NSString
            if resultText.integerValue > 0 && resultText.integerValue <= 99 {
                lblQuantity.text = resultText as String
            }else {
                let tmpResult : NSString = "0\(value)" as NSString
                if tmpResult.integerValue > 0 {
                    lblQuantity.text = tmpResult as String
                }
            }
        }
        
        updateQuantityBtn()
        
    }

    
    func userSelectDelete() {
        let resultText : NSString = "0\(lblQuantity!.text!)" as NSString
        lblQuantity.text = resultText.substring(to: 2)
        if lblQuantity.text == "00" {
            lblQuantity.text = "01"
            first = true
        }
        updateQuantityBtn()
    }
    
    func updateQuantityBtn(){
            let intQuantity = Int(lblQuantity!.text!)
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
        
//        let intQuantity = lblQuantity.text?.toInt()
//        var result = priceProduct.doubleValue * Double(intQuantity!)
//        let strPrice = CurrencyCustomLabel.formatString("\(result)")
//        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
//        btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
    }
    
    func showNoteButton() {
        self.btnNote.alpha = 1
    }
    
    func showNoteButtonComplete() {
        self.btnNoteComplete.alpha = 1
    }
    
    func setTitleCompleteButton(_ title:String) {
        self.btnNoteComplete.setTitle(title,for: UIControlState())
    }

}
