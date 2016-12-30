//
//  GRProductShoppingCartTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/21/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol GRProductShoppingCartTableViewCellDelegate {
    func userShouldChangeQuantity(_ cell:GRProductShoppingCartTableViewCell)
}

class GRProductShoppingCartTableViewCell : ProductTableViewCell {
    
    var quantity : Int! = 0
    var orderByPieces = false
    var pieces = 0
    var productPriceSavingLabel : UILabel!
    var changeQuantity : ShoppingCartButton!
    var priceProduct : Double!
    var savingProduct : Double!
    var upc : String!
    var delegateProduct : ProductShoppingCartTableViewCellDelegate!
    var desc : String!
    var price : NSString = ""
    var imageurl : String!
    var onHandInventory : NSString = ""
    var typeProd : Int = 0
    var delegateQuantity : GRProductShoppingCartTableViewCellDelegate!
    var comments : String! = ""
    var separatorView : UIView!
    var pesable : Bool = false
    var width : CGFloat! = 0
    var equivalenceByPiece: NSNumber! = NSNumber(value: 0 as Int32)
    
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        
        self.productPriceLabel!.textAlignment = NSTextAlignment.left
        
        self.productPriceLabel!.isHidden = false
        
        productPriceSavingLabel = UILabel(frame: CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19))
        productPriceSavingLabel!.font = WMFont.fontMyriadProSemiboldSize(14)
        productPriceSavingLabel!.textColor = WMColor.green
        
        
        self.contentView.addSubview(productPriceSavingLabel)
        
        changeQuantity = ShoppingCartButton(frame: CGRect.zero)
        changeQuantity.addTarget(self, action: #selector(GRProductShoppingCartTableViewCell.choseQuantity), for: UIControlEvents.touchUpInside)
        self.contentView.addSubview(changeQuantity)

        separatorView = UIView(frame:CGRect(x: productShortDescriptionLabel!.frame.minX, y: 109,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(separatorView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 16, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        self.productPriceLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productShortDescriptionLabel!.frame.maxY + 16 , width: 100 , height: 19)
        self.separatorView.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: 109,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth())
        self.productPriceSavingLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19)
        let size = ShoppingCartButton.sizeForQuantity(quantity, pesable: pesable, hasNote: self.comments != "", orderByPieces: self.orderByPieces, pieces: self.pieces)
        changeQuantity.frame =  CGRect(x: (self.frame.width - 16) -  size.width, y: self.productPriceLabel!.frame.minY, width: size.width, height: 30)
    }
    
    func setValues(_ upc: String, productImageURL: String, productShortDescription: String, productPrice: NSString, saving:NSString,quantity:Int,onHandInventory: NSString, typeProd: Int, comments: NSString, equivalenceByPiece: NSNumber, orderByPiece: Bool, pieces: Int) {
        
        self.equivalenceByPiece = equivalenceByPiece
        self.priceProduct = productPrice.doubleValue
        self.upc = upc
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        self.typeProd = typeProd
        self.orderByPieces = orderByPiece
        self.pieces = pieces
        self.comments = comments.trimmingCharacters(in: CharacterSet.whitespaces)
        
        var totalInProducts = productPrice.doubleValue * Double(quantity)
       
        
        if self.typeProd == 1 {
            totalInProducts = (productPrice.doubleValue / 1000.0) * Double(quantity)
            if orderByPiece{
                totalInProducts = ((equivalenceByPiece.doubleValue * Double(quantity)) * productPrice.doubleValue) / 1000
            }
            pesable = true
        } else {
            pesable = false
        }
        
        let totalPrice = NSString(format: "%.2f", totalInProducts)
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: totalPrice as String)
        let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        changeQuantity.setValues(self.upc, quantity: quantity, hasNote: self.comments != "", aviable: true, pesable: typeProd == 1, orderByPieces: self.orderByPieces, pieces: self.pieces)
        
        if saving != "" {
            productPriceSavingLabel.text = saving as String
            productPriceSavingLabel.isHidden = false
        }else{
            self.savingProduct = 0
            productPriceSavingLabel.text = ""
            productPriceSavingLabel.isHidden = true
        }
        
        
//        if self.quantity != nil &&  width == 0 {
//            let sizeQ = changeQuantity.sizeForQuantity(self.quantity, pesable: self.pesable,hasNote:self.comments != "")
//            self.width = sizeQ.width
//        }

        // changeQuantity.frame =  CGRectMake((self.frame.width - 16) -  width!, self.productPriceLabel!.frame.minY, width!, 30)
        let size = ShoppingCartButton.sizeForQuantity(quantity, pesable: pesable, hasNote: self.comments != "", orderByPieces: self.orderByPieces, pieces: self.pieces)
        changeQuantity.frame =  CGRect(x: (self.frame.width - 16) -  size.width, y: self.productPriceLabel!.frame.minY, width: size.width, height: 30)
    }
    
    
    func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat {
        return 110
    }
    
    
    func choseQuantity() {
        self.delegateQuantity.userShouldChangeQuantity(self)
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_QUANTITY_KEYBOARD.rawValue, label: "")
        
    }
  
    override func showLeftUtilityButtons(animated: Bool) {
        super.showLeftUtilityButtons(animated: animated)
        if changeQuantity.frameButton == nil {
            changeQuantity.setNoteState(true)
            changeQuantity.frame =  CGRect( x: self.frame.width - 126 , y: self.productPriceLabel!.frame.minY, width: 87, height: changeQuantity.frame.height)
            //self.width = 87
        }
    }
    
    override func hideUtilityButtons(animated: Bool) {
        super.hideUtilityButtons(animated: animated)
        if self.isUtilityButtonsHidden() {
            changeQuantity.setNoteState(false)
        }
    }
    
}
