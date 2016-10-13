//
//  RecentProducts .swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class RecentProductsTableViewCell : WishlistProductTableViewCell {
    
    var emptyView : IPOWishlistEmptyView!
    var productPriceSavingLabelGR : UILabel!
    
    override func setup() {
        super.setup()
        
        productPriceSavingLabelGR = UILabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19))
        productPriceSavingLabelGR!.font = WMFont.fontMyriadProSemiboldSize(14)
        productPriceSavingLabelGR!.textColor = WMColor.green
        self.contentView.addSubview(productPriceSavingLabelGR)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.separatorView!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 108,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth())
        self.productPriceSavingLabelGR!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19)
    }
    
    
    override func addToShoppingCart() {
        if !isDisabled {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue , label:"\(self.desc)\(self.upc)")
            
            let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
            if !hasUPC {
                
                var quanty = "1"
                if self.isPesable == "true"  {
                    quanty = "50"
                }
               
                let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: quanty,onHandInventory:self.onHandInventory as String,pesable:"0", type: resultObjectType.rawValue,isPreorderable:self.isPreorderable)
                btnShoppingCart.setImage(UIImage(named: "wishlist_done"), forState:UIControlState.Normal)
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
    
    override func setValues(upc: String, productImageURL: String, productShortDescription: String, productPrice: String, saving: NSString, isActive: Bool, onHandInventory: Int, isPreorderable: Bool, isInShoppingCart: Bool, pesable: NSString) {
        super.setValues(upc, productImageURL: productImageURL, productShortDescription: productShortDescription, productPrice: productPrice, saving: "", isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable, isInShoppingCart: isInShoppingCart, pesable: pesable)
        
        if saving != "" {
            productPriceSavingLabelGR.text = saving as String
            productPriceSavingLabelGR.hidden = false
        }else{
            productPriceSavingLabelGR.text = ""
            productPriceSavingLabelGR.hidden = true
        }
    }
    
    
    
}