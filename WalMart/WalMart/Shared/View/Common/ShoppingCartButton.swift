//
//  ShoppingCartButton.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/23/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ShoppingCartButton : UIButton {
    
    var orderByPieces: Bool = false
    var pieces: Int = 0
    var hasNote: Bool  = false
    var aviable: Bool  = false
    var pesable: Bool  = false
    var quantity: Int = 0
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
        
        
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        
        self.quantity = quantity
        self.hasNote = hasNote
        self.aviable = aviable
        self.pesable = pesable
        self.orderByPieces = orderByPieces
        self.pieces = pieces
    
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
        self.setTitle(ShoppingCartButton.quantityString(quantity, pesable: pesable, orderByPieces: self.orderByPieces, pieces: self.pieces), for: UIControlState())
        
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
    
    class func sizeForQuantity(_ quantity:Int, pesable:Bool, hasNote:Bool, orderByPieces: Bool, pieces: Int) -> CGSize {
        let quantityStr = ShoppingCartButton.quantityString(quantity, pesable: pesable, orderByPieces: orderByPieces, pieces: pieces)
        let attrStringLab : NSAttributedString = NSAttributedString(string:"\(quantityStr)", attributes: [NSFontAttributeName :WMFont.fontMyriadProSemiboldOfSize(14)])
        let rectSize = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)

        let fullSize = CGSize(width: ceil(rectSize.size.width - 25), height: ceil(rectSize.size.height))
        return fullSize
    }
    
    class func sizeForQuantityWithoutIcon(_ quantity:Int, pesable:Bool, hasNote:Bool, orderByPieces: Bool, pieces: Int) -> CGSize {
        let quantityStr = ShoppingCartButton.quantityString(quantity, pesable: pesable, orderByPieces: orderByPieces, pieces: pieces)
        let attrStringLab : NSAttributedString = NSAttributedString(string:"\(quantityStr)", attributes: [NSFontAttributeName :WMFont.fontMyriadProSemiboldOfSize(14)])
        let rectSize = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let fullSize = CGSize(width: ceil(rectSize.size.width - 50), height: ceil(rectSize.size.height))
        return fullSize
    }
    
    
    class func quantityString(_ quantity:Int, pesable:Bool, orderByPieces: Bool, pieces: Int) -> String! {
        var quantityStr = ""
        if !pesable {
            if quantity == 1 {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.piece", comment:""), NSNumber(value: quantity as Int))
            }
            else {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.pieces", comment:""), NSNumber(value: quantity as Int))
            }
        } else if orderByPieces { // Gramos pero se ordena por pieza
            
            if pieces == 1 {
                quantityStr = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), NSNumber(value: pieces))
            } else {
                quantityStr = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), NSNumber(value: pieces))
            }
            
        } else {
            //--
            let q = Double(quantity)
            if q < 1000.0 {
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.gr", comment:""), NSNumber(value: quantity as Int))
            }
            else {
                let kg = q/1000.0
                quantityStr = String(format: NSLocalizedString("shoppingcart.quantity.kg", comment:""), NSNumber(value: kg as Double))
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
