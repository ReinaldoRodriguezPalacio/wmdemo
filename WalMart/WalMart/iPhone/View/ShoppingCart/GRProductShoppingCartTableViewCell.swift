//
//  GRProductShoppingCartTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/21/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol GRProductShoppingCartTableViewCellDelegate {
    func userShouldChangeQuantity(cell:GRProductShoppingCartTableViewCell)
}

class GRProductShoppingCartTableViewCell : ProductTableViewCell {
    
    var quantity : Int! = 0
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
    var equivalenceByPiece: NSNumber! = NSNumber(int:0)
    
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        
        self.productPriceLabel!.textAlignment = NSTextAlignment.Left
        
        self.productPriceLabel!.hidden = false
        
        productPriceSavingLabel = UILabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19))
        productPriceSavingLabel!.font = WMFont.fontMyriadProSemiboldSize(14)
        productPriceSavingLabel!.textColor = WMColor.green
        
        
        self.contentView.addSubview(productPriceSavingLabel)
        
        changeQuantity = ShoppingCartButton(frame: CGRectZero)
        changeQuantity.addTarget(self, action: "choseQuantity", forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(changeQuantity)

        separatorView = UIView(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(separatorView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
        self.separatorView.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth())
        self.productPriceSavingLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19)
        let size = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.comments != "")
        changeQuantity.frame =  CGRectMake((self.frame.width - 16) -  size.width, self.productPriceLabel!.frame.minY, size.width, 30)
    }
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:NSString,saving:NSString,quantity:Int,onHandInventory:NSString,typeProd:Int, comments:NSString,equivalenceByPiece:NSNumber) {
        
        self.equivalenceByPiece = equivalenceByPiece
        self.priceProduct = productPrice.doubleValue
        self.upc = upc
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        self.typeProd = typeProd
        self.comments = comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var totalInProducts = productPrice.doubleValue * Double(quantity)
        if self.typeProd == 1 {
            totalInProducts = (productPrice.doubleValue / 1000.0) * Double(quantity)
            pesable = true
        } else {
            pesable = false
        }
        
        let totalPrice = NSString(format: "%.2f", totalInProducts)
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: totalPrice as String)
        let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)

        changeQuantity.setValues(self.upc, quantity: quantity, hasNote: self.comments != "", aviable: true, pesable: typeProd == 1)
        
        
        if saving != "" {
            productPriceSavingLabel.text = saving as String
            productPriceSavingLabel.hidden = false
        }else{
            self.savingProduct = 0
            productPriceSavingLabel.text = ""
            productPriceSavingLabel.hidden = true
        }
        
        
//        if self.quantity != nil &&  width == 0 {
//            let sizeQ = changeQuantity.sizeForQuantity(self.quantity, pesable: self.pesable,hasNote:self.comments != "")
//            self.width = sizeQ.width
//        }

        // changeQuantity.frame =  CGRectMake((self.frame.width - 16) -  width!, self.productPriceLabel!.frame.minY, width!, 30)
        let size = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.comments != "")
        changeQuantity.frame =  CGRectMake((self.frame.width - 16) -  size.width, self.productPriceLabel!.frame.minY, size.width, 30)
    }
    
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 110
    }
    
    
    func choseQuantity() {
        self.delegateQuantity.userShouldChangeQuantity(self)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_QUANTITY_KEYBOARD.rawValue, label: "")
        
    }
  
    override func showLeftUtilityButtonsAnimated(animated: Bool) {
        super.showLeftUtilityButtonsAnimated(animated)
        if changeQuantity.frameButton == nil {
            changeQuantity.setNoteState(true)
            changeQuantity.frame =  CGRectMake( self.frame.width - 126 , self.productPriceLabel!.frame.minY, 87, changeQuantity.frame.height)
            //self.width = 87
        }
    }
    
    override func hideUtilityButtonsAnimated(animated: Bool) {
        super.hideUtilityButtonsAnimated(animated)
        if self.isUtilityButtonsHidden() {
            changeQuantity.setNoteState(false)
        }
    }
    
}