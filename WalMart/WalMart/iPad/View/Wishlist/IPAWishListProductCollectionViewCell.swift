//
//  IPAWishListProductCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol IPAWishListProductCollectionViewCellDelegate {
    func deleteProductWishList(cell:IPAWishListProductCollectionViewCell)
}

class IPAWishListProductCollectionViewCell : ProductCollectionViewCell {
    
    
    var delegate : IPAWishListProductCollectionViewCellDelegate!
    var addProductToShopingCart : UIButton? = nil
    var deleteProduct : UIButton!
    var productPriceThroughLabel : CurrencyCustomLabel? = nil
    var upc : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    var isDisabled : Bool = false
    var onHandInventory : NSString = "0"
    var isPreorderable : String! = "false"
    
    override func setup() {
        super.setup()
        
        self.productPriceThroughLabel = CurrencyCustomLabel(frame: CGRectZero)
        
        self.productShortDescriptionLabel!.textColor = WMColor.gray
        self.productShortDescriptionLabel?.textAlignment = NSTextAlignment.Center
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        self.addProductToShopingCart = UIButton()
        self.addProductToShopingCart!.setImage(UIImage(named: "wishlist_cart"), forState: UIControlState.Normal)
        self.addProductToShopingCart!.addTarget(self, action: "addProductToShoping", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.deleteProduct = UIButton()
        self.deleteProduct.setImage(UIImage(named:"wishlist_delete"), forState: UIControlState.Normal)
        self.deleteProduct.addTarget(self, action: "deleteProductWishList", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.contentView.addSubview(self.deleteProduct)
        
        let borderView = UIView(frame: CGRectMake(self.frame.width - AppDelegate.separatorHeigth(), 0,AppDelegate.separatorHeigth(), self.frame.height ))
        borderView.backgroundColor = WMColor.lineSaparatorColor
        self.contentView.addSubview(borderView)
        self.contentView.addSubview(addProductToShopingCart!)
        self.contentView.addSubview(productPriceThroughLabel!)
        
        self.deleteProduct.frame = CGRectMake(0, 0 , 60 , 60)
        self.productShortDescriptionLabel!.frame = CGRectMake(50, 16, self.frame.width - 100 , 28)
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (162 / 2), self.productShortDescriptionLabel!.frame.maxY + 8 , 162, 114)
        self.productPriceLabel!.frame = CGRectMake(0, self.productImage!.frame.maxY + 8, self.bounds.width , 16)
        self.productPriceThroughLabel!.frame = CGRectMake(0, self.productPriceThroughLabel!.frame.maxY , self.bounds.width , 16)
        self.addProductToShopingCart!.frame = CGRectMake(self.bounds.maxX - 66,self.productImage!.frame.maxY + 8 , 66 , 34)
    }

    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String,isEditting:Bool,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool ) {
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        //let formatedPrice = CurrencyCustomLabel.formatString(productPriceThrough)
        //productPriceThroughLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.priceProductTextColor, interLine: false)
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.deleteProduct.hidden = !isEditting
        self.onHandInventory = String(onHandInventory)
        self.isPreorderable = "\(isPreorderable)"
        
        isDisabled = false
        if isActive == false || onHandInventory == 0  {
            self.addProductToShopingCart!.setImage(UIImage(named: "wishlist_cart_disabled"), forState: UIControlState.Normal)
            isDisabled = true
        }else{
            if isInShoppingCart {
                addProductToShopingCart!.setImage(UIImage(named: "wishlist_done"), forState:UIControlState.Normal)
            }else {
                addProductToShopingCart!.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
            }
        }
    }
    
    
    func addProductToShoping(){
        if !isDisabled {
            let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
            if !hasUPC {
                let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String,pesable:"0",isPreorderable:isPreorderable)
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
            }else{
                let alert = IPAWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                alert!.setMessage(NSLocalizedString("shoppingcart.isincart",comment:""))
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        } else {
            let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            
        }
        //TODO: Change value self.onHandInventory
        /*let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:"0")
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)*/
    }
    
    func deleteProductWishList() {
        if delegate != nil {
            delegate.deleteProductWishList(self)
        }
    }
    
}