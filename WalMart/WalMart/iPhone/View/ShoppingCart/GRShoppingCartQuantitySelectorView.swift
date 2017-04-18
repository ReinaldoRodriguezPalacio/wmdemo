//
//  GRShoppingCartQuantitySelectorView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/12/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRShoppingCartQuantitySelectorView : UIView, KeyboardViewDelegate {

    let ZERO_QUANTITY_STRING = "00"
    
    var isPush = false
    var executeClose = true
    var numericKeyboard = NumericKeyboardView()
    var lblQuantity : UILabel!
    var lblTitle : UILabel!
    var imageBlurView : UIImageView!
    var first : Bool = true
    var isFromList : Bool = false {
        didSet {
            if isFromList {
                self.btnNoteQuantity?.alpha = 0
                self.btnNoteN?.alpha = 0

            }
            self.lblTitle?.text = self.isFromList ? NSLocalizedString("shoppingcart.updatequantitytitle.list",comment:"") : NSLocalizedString("shoppingcart.updatequantitytitle",comment:"")
            self.updateQuantityBtn()
        }
    }
    var isUpcInList: Bool = false
    var addToCartAction : ((String) -> Void)!
    var addUpdateNote : (() -> Void)!
    var closeAction : (() -> Void)!
    var priceProduct : NSNumber!
    var upcProduct : String!
    var btnOkAdd : UIButton!
    var btnNoteQuantity : UIButton!
    var btnNoteComplete : UIButton!
    var btnNoteN : UIButton!
    var closeButton : UIButton!
    var btnDelete : UIButton!
    var isUpcInShoppingCart : Bool = false
    var orderByPiece = true
    var backgroundView: UIView?
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    var startY:CGFloat = 0
    var isFullView = false
    
    init(frame: CGRect,equivalenceByPiece:NSNumber) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, priceProduct : NSNumber!,upcProduct:String,startY:CGFloat = 0) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.upcProduct = upcProduct
        self.startY = startY
        self.setup()
    }
    
    init(frame: CGRect,priceProduct:NSNumber!,quantity:Int!,upcProduct:String,startY:CGFloat = 0 ) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.upcProduct = upcProduct
        self.startY = startY
        self.setup()
        let text = String(quantity).characters.count < 2 ? "0" : ""
        lblQuantity.text = "\(text)"+"\(quantity!)"
        
        self.updateQuantityBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func layoutSubviews() {
        if isPush {
            closeButton.setImage(UIImage(named: "search_back"), for: UIControlState())
        }
    }
    
    func setup() {
        
        backgroundColor = UIColor.clear
        
        let startH: CGFloat = startY
        
        isFullView = (frame.height > 600) && !IS_IPAD
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: self.bounds.height))
        backgroundView!.backgroundColor = WMColor.light_blue.withAlphaComponent(0.93)
        
        self.lblTitle = UILabel(frame: CGRect(x: (self.frame.width / 2) - 115, y: startH + 18, width: 230, height: isFullView && startH != 0 ? 48 : 14))
        self.lblTitle.font = WMFont.fontMyriadProSemiboldSize(14)
        self.lblTitle.textColor = UIColor.white
        
        var titleView = "shoppingcart.updatequantitytitle"
        if self.isFromList {
            titleView = "shoppingcart.updatequantitytitle.list"
        }
        
        self.lblTitle.text = NSLocalizedString(titleView ,comment:"")
        self.lblTitle.textAlignment = NSTextAlignment.center
        
        lblQuantity = UILabel(frame: CGRect(x: (self.frame.width / 2) - (200 / 2), y: isFullView && startH != 0 ? lblTitle.frame.maxY : (lblTitle.frame.maxY + 20), width: 200, height: 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.white
        lblQuantity.text = "01"
        lblQuantity.textAlignment = NSTextAlignment.center
        
        var closePossitionY: CGFloat = IS_IPAD ? startH - 3 : startH - 26
        closePossitionY = closePossitionY <= 0 ? 0 : closePossitionY
        closeButton = UIButton(frame: CGRect(x: 0, y: closePossitionY, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.closeSelectQuantity), for: UIControlEvents.touchUpInside)
        
        let adjustY: CGFloat = frame.height > 380 ? 14 : 0
        let separationY: CGFloat = 12 + adjustY
        let margin: CGFloat = isFullView ? ((self.frame.width - 220) / 2) : ((self.frame.width / 2) - 80)
        let keyboardHeight: CGFloat = isFullView ? 288 : 200
        let keyboardWidth: CGFloat = isFullView ? 220 : (frame.width - (margin * 2))
        let keyboardYPosition: CGFloat = isFullView ? lblQuantity.frame.maxY + 28 : lblQuantity.frame.maxY + separationY
        
        numericKeyboard = NumericKeyboardView(frame: CGRect(x: margin, y: keyboardYPosition, width: keyboardWidth, height: keyboardHeight), typeKeyboard: NumericKeyboardViewType.Integer)
        numericKeyboard.widthButton = isFullView ? 60 : 40
        numericKeyboard.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        numericKeyboard.delegate = self
        
        btnOkAdd = UIButton(frame: CGRect(x: (self.frame.width / 2) - 73, y: numericKeyboard.frame.maxY + 15 , width: 146, height: 36))
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let botomMargin: CGFloat = isFullView ? 28 : separationY
        
        btnOkAdd = UIButton(frame: CGRect(x: (frame.width - 142) / 2, y: numericKeyboard.frame.maxY + botomMargin, width: 142, height: 36))
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
        
        
        btnDelete = UIButton(frame:CGRect(x:btnOkAdd.frame.maxX,y:btnOkAdd.frame.minY,width:self.bounds.width - btnOkAdd.frame.maxX ,height:36))
        btnDelete.setTitle(NSLocalizedString("shoppingcart.delete", comment: ""), for: .normal)
        btnDelete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        btnDelete.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deleteItems), for: .touchUpInside)
        
        btnNoteQuantity = UIButton(frame:CGRect(x:0,y:btnOkAdd.frame.minY,width:btnOkAdd.frame.minX ,height:36))
        btnNoteQuantity.setTitle(NSLocalizedString("shoppingcart.addnotebtn", comment: ""), for: .normal)
        btnNoteQuantity.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        btnNoteQuantity.alpha = 0
        btnNoteQuantity.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.updateOrAddNote), for: .touchUpInside)
        
        self.addSubview(self.backgroundView!)
        self.addSubview(lblTitle)
        self.addSubview(lblQuantity)
        self.addSubview(numericKeyboard)
        self.addSubview(btnOkAdd)
        self.addSubview(closeButton)
        self.addSubview(numericKeyboard)
        self.addSubview(btnNoteQuantity)
        self.addSubview(btnDelete)
        
        if isUpcInShoppingCart  {
            self.showNoteButton()
            

        }

    }
    
    func deleteItems() {
        self.lblQuantity.text = ZERO_QUANTITY_STRING
        updateQuantityBtn()
    }

    func updateOrAddNote() {
        
        if (addUpdateNote != nil) {
            addUpdateNote()
        }
    }
    
    func chngequantity(_ sender:AnyObject) {
        
        if let btnSender = sender as? UIButton {
            
            var resultText : String = ""
            
            resultText = lblQuantity.text! + btnSender.titleLabel!.text!
            resultText = (resultText as NSString).substring(from: 1) as String
            if (resultText as NSString).integerValue > 0 && (resultText as NSString).integerValue <= 10 {
                lblQuantity.text = resultText as String
            } else {
                let tmpResult : String = "0" + btnSender.titleLabel!.text!
                if (tmpResult as NSString).integerValue > 0 {
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
    
    func deletefromshoppingcart(_ sender:AnyObject) {
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
            var tmpResult : String = value!
            tmpResult = (tmpResult as NSString).integerValue < 10 ? "0\(value!)" : value!
            if tmpResult != "00" {
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
            numericKeyboard.showDeleteBtn()
        } else {
            numericKeyboard.hideDeleteBtn()
        }
        
        updateQuantityBtn()
        
    }

    func userSelectDelete() {
        let resultText : String = "0" + lblQuantity.text!
        lblQuantity.text = (resultText as NSString).substring(to: 2)
        
        if lblQuantity.text == "00" {
            lblQuantity.text = "01"
            first = true
        }
        
        if lblQuantity.text == "01" {
            numericKeyboard.hideDeleteBtn()
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
        if  (!isUpcInShoppingCart && !isFromList ) || (isFromList && !isUpcInList) {
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        } else {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        }
        
        if lblQuantity.text == ZERO_QUANTITY_STRING {
            self.btnOkAdd.backgroundColor = WMColor.red
            if isFromList {
                self.btnOkAdd.setTitle(NSLocalizedString("shoppingcart.deleteoflist", comment: ""), for: .normal)
            } else {
                self.btnOkAdd.setTitle(NSLocalizedString("shoppingcart.deleteofcart", comment: ""), for: .normal)
                if (self.btnNoteQuantity != nil) && !isFromList {
                    self.btnNoteQuantity.alpha = 0
                }
            }
            self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAdd.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnDelete?.alpha = 0.0

            if !isUpcInShoppingCart &&  !isFromList || (isFromList && !isUpcInList){
                let tmpResult : NSString = "00" as NSString
                lblQuantity.text = tmpResult as String
                btnOkAdd?.backgroundColor = WMColor.green
                btnOkAdd.setTitle("\(strAdddToSC) \("0.0")", for: UIControlState())
                let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \("0")", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
                rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            }
        } else {
            self.btnOkAdd.backgroundColor = WMColor.green
            
            if (self.btnNoteQuantity != nil) && !isFromList {
                self.btnNoteQuantity.alpha = 1
            }
            self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAdd.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnDelete?.alpha = 1.0
            
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
    
    func setQuantity(quantity: Int) {

        if quantity == 0 {
            return
        }
        
        let text = String(quantity).characters.count < 2 ? "0" : ""
        lblQuantity.text = "\(text)"+"\(quantity)"
        
        self.updateQuantityBtn()
    }
    
    func showNoteButton() {
        self.btnNoteQuantity.alpha = 1
    }
    
    func showNoteButtonComplete() {
        self.btnNoteComplete.alpha = 1
    }
    
    func setTitleCompleteButton(_ title:String) {
        self.btnNoteComplete.setTitle(title,for: UIControlState())
    }
    
    func validateOrderByPiece(orderByPiece: Bool, quantity: Double, pieces: Int) {
        self.orderByPiece = orderByPiece
    }

}
