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
        
        productPriceSavingLabelGR = UILabel(frame: CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19))
        productPriceSavingLabelGR!.font = WMFont.fontMyriadProSemiboldSize(14)
        productPriceSavingLabelGR!.textColor = WMColor.green
        self.contentView.addSubview(productPriceSavingLabelGR)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.separatorView!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: 108,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth())
        self.productPriceSavingLabelGR!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19)
    }
    
    
    override func addToShoppingCart() {
        if !isDisabled {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue , label:"\(self.desc)\(self.upc)")
            
            let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
            if !hasUPC {
                
                var quanty = "1"
                if self.isPesable == "true"  {
                    quanty = "50"
                }
               
                let newParams = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc,desc:self.desc,imageURL:imageURL,price:self.price,quantity:quanty,comments:"",onHandInventory:self.onHandInventory as String,type:ResultObjectType.Groceries.rawValue,pesable:self.isPesable,isPreorderable:self.isPreorderable,orderByPieces: !(self.isPesable == "true"))
                btnShoppingCart.setImage(UIImage(named: "products_done"), for:UIControlState())
                NotificationCenter.default.post(name:  .addUPCToShopingCart, object: self, userInfo: newParams)
                
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
    
    override func setValues(_ upc: String, productImageURL: String, productShortDescription: String, productPrice: String, saving: NSString, isActive: Bool, onHandInventory: Int, isPreorderable: Bool, isInShoppingCart: Bool, pesable: NSString) {
        super.setValues(upc, productImageURL: productImageURL, productShortDescription: productShortDescription, productPrice: productPrice, saving: "", isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable, isInShoppingCart: isInShoppingCart, pesable: pesable)
        
        if saving != "" {
            productPriceSavingLabelGR.text = saving as String
            productPriceSavingLabelGR.isHidden = false
        }else{
            productPriceSavingLabelGR.text = ""
            productPriceSavingLabelGR.isHidden = true
        }
    }
    
    
    
}
