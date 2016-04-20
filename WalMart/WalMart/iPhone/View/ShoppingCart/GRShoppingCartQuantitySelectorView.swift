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
        lblQuantity.text = "\(text)"+"\(quantity)"
        self.updateQuantityBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        
        let startH : CGFloat = 0
        
        self.backgroundColor = UIColor.clearColor()
        
        
        self.backgroundView = UIView(frame:CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        self.backgroundView!.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.9)
        
        let lblTitle = UILabel(frame:CGRectMake((self.frame.width / 2) - 115, startH + 17, 230, 14))
        lblTitle.font = WMFont.fontMyriadProSemiboldSize(14)
        lblTitle.textColor = UIColor.whiteColor()
        lblTitle.text = NSLocalizedString("shoppingcart.addweighttitle",comment:"")
        lblTitle.textAlignment = NSTextAlignment.Center
        
        lblQuantity = UILabel(frame:CGRectMake((self.frame.width / 2) - (200 / 2), lblTitle.frame.maxY + 20 , 200, 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.whiteColor()
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.Center
        
        
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeSelectQuantity", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        let keyboard = NumericKeyboardView(frame:CGRectMake((self.frame.width / 2) - (160/2), lblQuantity.frame.maxY + 10, 160, 196),typeKeyboard:NumericKeyboardViewType.Integer)
        //289
        keyboard.generateButtons(UIColor.whiteColor().colorWithAlphaComponent(0.35), selected: UIColor.whiteColor())
        keyboard.delegate = self
        
        btnOkAdd = UIButton(frame: CGRectMake((self.frame.width / 2) - 71, keyboard.frame.maxY + 15 , 142, 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        btnOkAdd.setTitle("\(strAdddToSC) $0.00", forState: UIControlState.Normal)
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: "addtoshoppingcart:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        if UserCurrentSession.sharedInstance().userHasUPCShoppingCart(self.upcProduct) {
            isUpcInShoppingCart = true
        } else {
            isUpcInShoppingCart = false
        }

        
        
        updateQuantityBtn()
        
        
        
        btnNote = UIButton(frame: CGRectMake((self.frame.width) - 48, keyboard.frame.maxY + 15 , 40, 40))
        btnNote.setImage(UIImage(named:"notes_keyboard"), forState: UIControlState.Normal)
        btnNote.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNote.alpha = 0
        self.addSubview(btnNote)
        
        
        btnNoteComplete = UIButton(frame: CGRectMake(0, btnOkAdd.frame.maxY + 10, self.frame.width, 40))
        btnNoteComplete.setImage(UIImage(named: "notes_alert"), forState: UIControlState.Normal)
        self.btnNoteComplete!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
        btnNoteComplete.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTE_IN_KEY_BOARD.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_NOTE_IN_KEY_BOARD.rawValue, action:WMGAIUtils.ACTION_OPEN_NOTE.rawValue, label: self.upcProduct)
            addUpdateNote()
        }
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_QUANTITY_KEYBOARD_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_QUANTITY_KEYBOARD_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_CLOSE_KEYBOARD.rawValue , label:"")
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
    
    func setTitleCompleteButton(title:String) {
        self.btnNoteComplete.setTitle(title,forState: UIControlState.Normal)
    }

}