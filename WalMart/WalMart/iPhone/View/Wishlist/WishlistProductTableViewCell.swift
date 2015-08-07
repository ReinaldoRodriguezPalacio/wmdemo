//
//  WishListTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol WishlistProductTableViewCellDelegate {
    func deleteFromWishlist(UPC:String)
}

class WishlistProductTableViewCell : ProductTableViewCell {
    
    var delegateProduct : WishlistProductTableViewCellDelegate!
    var resultObjectType : ResultObjectType! = ResultObjectType.Mg
    var productPriceSavingLabel : CurrencyCustomLabel!
    var separatorView : UIView?
    var btnShoppingCart : UIButton!
    var upc : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    var isDisabled : Bool = false
    var onHandInventory : NSString = "0"
    var isPesable : String!
    
    
    override func setup() {
        super.setup()
        
        productShortDescriptionLabel!.textColor = WMColor.shoppingCartProductTextColor
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        //productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        
        
        //self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
        self.productPriceLabel!.textAlignment = NSTextAlignment.Left
        
        self.productPriceLabel!.hidden = false
        
        productPriceSavingLabel = CurrencyCustomLabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19))
        productPriceSavingLabel!.textAlignment = NSTextAlignment.Left
        
        
        btnShoppingCart = UIButton(frame: CGRectMake(self.frame.width - 16 - 32, productShortDescriptionLabel!.frame.maxY + 16, 32, 32))
        btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
        btnShoppingCart.addTarget(self, action: "addToShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.separatorView = UIView(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, 108,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth()))
        self.separatorView!.backgroundColor = WMColor.lineSaparatorColor
        
        self.contentView.addSubview(btnShoppingCart)
        self.contentView.addSubview(productPriceSavingLabel)
        self.contentView.addSubview(self.separatorView!)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        
        self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
         self.productPriceSavingLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19)
        
        
        self.btnShoppingCart.frame = CGRectMake(self.frame.width - 16 - 32, productShortDescriptionLabel!.frame.maxY + 16, 32, 32)
        
      
    }
    
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:String,saving:NSString,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,pesable :NSString) {
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory)
        self.isPesable = pesable as String

        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.priceProductTextColor, interLine: false)
        
        if saving.doubleValue > 0 {
            let formatedSaving = CurrencyCustomLabel.formatString(saving)
            let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
            let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
            productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.productDetailPriceText, interLine: false)
            productPriceSavingLabel.hidden = false
        }else{
            productPriceSavingLabel.hidden = true
        }
        
        isDisabled = false
        if isActive == false || onHandInventory == 0 || isPreorderable == true {
            self.btnShoppingCart.setImage(UIImage(named: "wishlist_cart_disabled"), forState: UIControlState.Normal)
            isDisabled = true
        }else{
            if isInShoppingCart {
                btnShoppingCart.setImage(UIImage(named: "wishlist_done"), forState:UIControlState.Normal)
            }else {
                btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
            }
        }
        
    }
    
    func deleteUPCWishlist() {
        delegateProduct.deleteFromWishlist("")
    }
    
   
    
    func addToShoppingCart() {
        if !isDisabled {
            let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
            if !hasUPC {
                let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String,pesable:"0", type: resultObjectType.rawValue)
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                
            }else{
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                alert!.setMessage(NSLocalizedString("shoppingcart.isincart",comment:""))
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        } else {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
          
        }
    }

    
}