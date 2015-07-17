//
//  ShoppingCartButton.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/23/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ShoppingCartButton : UIButton {
    
    var hasNote : Bool  = false
    var aviable : Bool  = false
    var pesable : Bool  = false
    var quantity : Int = 0
    
    var frameButton : CGRect? = nil
    
    var lastColor : UIColor?  = nil
    var titleString : String?  = nil
    var noteStateButton = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height / 2
    }
    
    func setValues(upc:String,quantity:Int ,hasNote: Bool, aviable:Bool, pesable:Bool){
        self.quantity = quantity
        self.hasNote = hasNote
        self.aviable = aviable
        self.pesable = pesable
        

        if aviable {
            self.backgroundColor = WMColor.productDetailShoppingCartBtnBGColor
            self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        } else {
            self.backgroundColor = WMColor.productDetailShoppingCartBtnBGColor
            self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        }
        
        if hasNote && aviable {
            self.setImage(UIImage(named: "notes_cart"), forState: UIControlState.Normal)
            self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 8.0)
        }else {
            self.setImage(UIImage(named: "notes_cart_off"), forState: UIControlState.Normal)
            self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 8.0)
        }
        
//        let rectSize = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.hasNote)
//        self.frame = CGRectMake(self.frame.minX, self.frame.minY, rectSize.width , 30)
        self.setTitle(ShoppingCartButton.quantityString(quantity,pesable:pesable), forState: UIControlState.Normal)
        
        
    }
    
    class func sizeForQuantity(quantity:Int,pesable:Bool,hasNote:Bool) -> CGSize {
        var quantityStr = ShoppingCartButton.quantityString(quantity,pesable:pesable)
        var attrStringLab : NSAttributedString = NSAttributedString(string:"\(quantityStr)", attributes: [NSFontAttributeName :WMFont.fontMyriadProSemiboldOfSize(14)])
        let rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        
        var space : CGFloat = 25
        // Note icon
        space += 20
        
        let fullSize = CGSizeMake(rectSize.size.width + space,rectSize.size.height)
        return fullSize
    }
    
    
    class func quantityString(quantity:Int,pesable:Bool) -> String! {
        var quantityStr = ""
        if !pesable {
            if quantity == 1 {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.piece", comment:""), NSNumber(integer: quantity))
            }
            else {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.pieces", comment:""), NSNumber(integer: quantity))
            }
        } else {
            if quantity < 1000 {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.gr", comment:""), NSNumber(integer: quantity))
            }
            else {
                
               var y =  Double(quantity)
                let kg = y/1000
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.kg", comment:""), NSNumber(double:  kg))
            }
        }
        return quantityStr
    }
    
    
    func setNoteState(noteState:Bool) {
        noteStateButton = noteState
        if noteState {
            
           // if frameButton == nil {
                frameButton = self.frame
                lastColor = self.backgroundColor
                titleString = self.titleLabel?.text
                
                self.setImage(UIImage(named: "notes_alert"), forState: UIControlState.Normal)
                self.backgroundColor = WMColor.shoppingCartNoteButtonBgColor
                self.setTitle(NSLocalizedString("shoppingcart.note", comment:""), forState: UIControlState.Normal)
//                self.frame = CGRectMake(frameButton!.minX - 36, frameButton!.minY, 87, frameButton!.height)
//                
               self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 12.0)
            
//            } else {
//                 self.frame = frameButton!
//            }
            
       
        } else {
            if lastColor != nil && frameButton != nil {
                self.frame = frameButton!
                self.backgroundColor = lastColor!
                self.setTitle(titleString!, forState: UIControlState.Normal)
                
                if hasNote && aviable {
                    self.setImage(UIImage(named: "notes_cart"), forState: UIControlState.Normal)
                    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 12.0)
                }else {
                    self.setImage(nil, forState: UIControlState.Normal)
                    self.imageEdgeInsets = UIEdgeInsetsZero
                }
                
                frameButton = nil
            }
        }
    }
    
}