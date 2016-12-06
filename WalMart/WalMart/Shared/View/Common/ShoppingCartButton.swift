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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height / 2
    }
    
    func setValues(_ upc:String,quantity:Int ,hasNote: Bool, aviable:Bool, pesable:Bool){
        self.quantity = quantity
        self.hasNote = hasNote
        self.aviable = aviable
        self.pesable = pesable
        

        if aviable {
            self.backgroundColor = WMColor.yellow
            self.setTitleColor(UIColor.white, for: UIControlState())
            self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        } else {
            self.backgroundColor = WMColor.yellow
            self.setTitleColor(UIColor.white, for: UIControlState())
            self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        }
        
        if hasNote && aviable {
            self.setImage(UIImage(named: "notes_cart"), for: UIControlState())
            self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 8.0)
        }else {
            self.setImage(UIImage(named: "notes_cart_off"), for: UIControlState())
            self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 8.0)
        }
        
//        let rectSize = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.hasNote)
//        self.frame = CGRectMake(self.frame.minX, self.frame.minY, rectSize.width , 30)
        self.setTitle(ShoppingCartButton.quantityString(quantity,pesable:pesable), for: UIControlState())
        
        
    }
    
    func setValuesMg(_ upc:String,quantity:Int, aviable:Bool){
        self.quantity = quantity
        self.hasNote = false
        self.aviable = aviable
        self.pesable = false
        
        
        if aviable {
            self.backgroundColor = WMColor.yellow
            self.setTitleColor(UIColor.white, for: UIControlState())
            self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        } else {
            self.backgroundColor = WMColor.yellow
            self.setTitleColor(UIColor.white, for: UIControlState())
            self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        }
        
        self.setTitle(ShoppingCartButton.quantityStringMg(quantity), for: UIControlState())
    }
    
    class func sizeForQuantity(_ quantity:Int,pesable:Bool,hasNote:Bool) -> CGSize {
        let quantityStr = ShoppingCartButton.quantityString(quantity,pesable:pesable)
        let attrStringLab : NSAttributedString = NSAttributedString(string:"\(quantityStr)", attributes: [NSFontAttributeName :WMFont.fontMyriadProSemiboldOfSize(14)])
        let rectSize = attrStringLab.boundingRect(with: CGSize(width: IS_IPAD ? 70.0 : 45.0, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        
        var space : CGFloat = 25
        // Note icon
        space += 20
        
        let fullSize = CGSize(width: rectSize.size.width + space,height: rectSize.size.height)
        return fullSize
    }
    
    class func sizeForQuantityWithoutIcon(_ quantity:Int,pesable:Bool,hasNote:Bool) -> CGSize {
        let quantityStr = ShoppingCartButton.quantityString(quantity,pesable:pesable)
        let attrStringLab : NSAttributedString = NSAttributedString(string:"\(quantityStr)", attributes: [NSFontAttributeName :WMFont.fontMyriadProSemiboldOfSize(14)])
        let rectSize = attrStringLab.boundingRect(with: CGSize(width: IS_IPAD ? 70.0 : 40.0, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let fullSize = CGSize(width: rectSize.size.width + 25,height: rectSize.size.height)
        return fullSize
    }
    
    
    class func quantityString(_ quantity:Int,pesable:Bool) -> String! {
        var quantityStr = ""
        if !pesable {
            if quantity == 1 {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.piece", comment:""), NSNumber(value: quantity as Int))
            }
            else {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.pieces", comment:""), NSNumber(value: quantity as Int))
            }
        } else {
            if quantity < 1000 {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.gr", comment:""), NSNumber(value: quantity as Int))
            }
            else {
                
               let y =  Double(quantity)
                let kg = y/1000
                let value  = String(format:"%.2f",kg)
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.kg", comment:""),value)
            }
        }
  
        return quantityStr
    }
    
    class func quantityStringMg(_ quantity:Int) -> String! {
        var quantityStr = ""
        if quantity == 1 {
            quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.article", comment:""), NSNumber(value: quantity as Int))
        }
        else {
            quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.articles", comment:""), NSNumber(value: quantity as Int))
        }
        return quantityStr
    }
    
    
    func setNoteState(_ noteState:Bool) {
        noteStateButton = noteState
        if noteState {
            
           // if frameButton == nil {
                frameButton = self.frame
                lastColor = self.backgroundColor
                titleString = self.titleLabel?.text
                
                self.setImage(UIImage(named: "notes_alert"), for: UIControlState())
                self.backgroundColor = WMColor.light_blue
                self.setTitle(NSLocalizedString("shoppingcart.note", comment:""), for: UIControlState())
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
                self.setTitle(titleString!, for: UIControlState())
                
                if hasNote && aviable {
                    self.setImage(UIImage(named: "notes_cart"), for: UIControlState())
                    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 12.0)
                }else {
                    self.setImage(nil, for: UIControlState())
                    self.imageEdgeInsets = UIEdgeInsets.zero
                }
                
                frameButton = nil
            }
        }
    }
    
}
