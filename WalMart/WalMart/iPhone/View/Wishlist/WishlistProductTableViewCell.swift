//
//  WishListTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol WishlistProductTableViewCellDelegate: class {
    func deleteFromWishlist(_ UPC:String)
}

class WishlistProductTableViewCell : ProductTableViewCell {
    
    weak var delegateProduct : WishlistProductTableViewCellDelegate?
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
    var isPreorderable : String!
    
    var imagePresale : UIImageView!
    var borderViewTop : UIView!
    var iconDiscount : UIImageView!
    let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
    var presale : UILabel!
    
    override func setup() {
        super.setup()
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        
        
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        //productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        
        
        //self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
        self.productPriceLabel!.textAlignment = NSTextAlignment.left
        
        self.productPriceLabel!.isHidden = false
        
        productPriceSavingLabel = CurrencyCustomLabel(frame: CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19))
        productPriceSavingLabel!.textAlignment = NSTextAlignment.left
        
        
        btnShoppingCart = UIButton(frame: CGRect(x: self.frame.width - 16 - 32, y: productShortDescriptionLabel!.frame.maxY + 16, width: 32, height: 32))
        btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), for:UIControlState())
        btnShoppingCart.addTarget(self, action: #selector(WishlistProductTableViewCell.addToShoppingCart), for: UIControlEvents.touchUpInside)
        
        self.separatorView = UIView(frame:CGRect(x: 16, y: 108,width: self.frame.width - 16, height: 1.0))
        
        self.separatorView!.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(btnShoppingCart)
        self.contentView.addSubview(productPriceSavingLabel)
        self.contentView.addSubview(self.separatorView!)
        
        
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 16, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        
        self.productPriceLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productShortDescriptionLabel!.frame.maxY + 16 , width: 100 , height: 19)
         self.productPriceSavingLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19)
        
        
        self.btnShoppingCart.frame = CGRect(x: self.frame.width - 16 - 32, y: productShortDescriptionLabel!.frame.maxY + 16, width: 32, height: 32)
        
      
    }
    
    
    func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:String,saving:NSString,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,pesable :NSString) {
        imagePresale.isHidden = !isPreorderable

        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory) as NSString
        self.isPesable = pesable as String
        self.isPreorderable = "\(isPreorderable)"
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        if saving.doubleValue > 0 {
            let formatedSaving = CurrencyCustomLabel.formatString(saving)
            let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
            let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
            productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.green, interLine: false)
            productPriceSavingLabel.isHidden = false
        }else{
            productPriceSavingLabel.isHidden = true
        }
        
        isDisabled = false
        if isActive == false || onHandInventory == 0  {
            self.btnShoppingCart.setImage(UIImage(named: "wishlist_cart_disabled"), for: UIControlState())
            isDisabled = true
        }else{
            if isInShoppingCart {
                btnShoppingCart.setImage(UIImage(named: "wishlist_done"), for:UIControlState())
            }else {
                btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), for:UIControlState())
            }
        }
        
    }
    
    func deleteUPCWishlist() {
        delegateProduct?.deleteFromWishlist("")
    }
    
   
    
    func addToShoppingCart() {
        if !isDisabled {
            let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
            if !hasUPC {
                //Event
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CAR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CAR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: "\(self.desc) - \(self.upc)")
                
                let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String,pesable:"0", type: resultObjectType.rawValue,isPreorderable: isPreorderable)
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                
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
    func moveRightImagePresale(_ moveRight:Bool){
        if moveRight {
            UIView.animate( withDuration: 0.3 , animations: {
                self.imagePresale.frame = CGRect( x: 48, y: 0, width: 46, height: 46)
            })
        }
        else{
            self.imagePresale.frame = CGRect( x: 0, y: 0, width: 46, height: 46)
            
            
        }
    }
}
