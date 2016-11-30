//
//  IPAWishListProductCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol IPAWishListProductCollectionViewCellDelegate {
    func deleteProductWishList(_ cell:IPAWishListProductCollectionViewCell)
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
    
    var imagePresale : UIImageView!
    var borderViewTop : UIView!
    var iconDiscount : UIImageView!
    let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
    var presale : UILabel!
    override func setup() {
        super.setup()
        
        self.productPriceThroughLabel = CurrencyCustomLabel(frame: CGRect.zero)
        self.productPriceThroughLabel?.textAlignment = .center
        
        self.productShortDescriptionLabel!.textColor = WMColor.gray
        self.productShortDescriptionLabel?.textAlignment = NSTextAlignment.center
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        self.addProductToShopingCart = UIButton()
        self.addProductToShopingCart!.setImage(UIImage(named: "wishlist_cart"), for: UIControlState())
        self.addProductToShopingCart!.addTarget(self, action: #selector(IPAWishListProductCollectionViewCell.addProductToShoping), for: UIControlEvents.touchUpInside)
        
        self.deleteProduct = UIButton()
        self.deleteProduct.setImage(UIImage(named:"wishlist_delete"), for: UIControlState())
        self.deleteProduct.addTarget(self, action: #selector(IPAWishListProductCollectionViewCell.deleteProductWishList), for: UIControlEvents.touchUpInside)
        
        
        let borderView = UIView(frame: CGRect(x: self.frame.width - AppDelegate.separatorHeigth(), y: 0,width: AppDelegate.separatorHeigth(), height: self.frame.height ))
        borderView.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderView)
        self.contentView.addSubview(addProductToShopingCart!)
        self.contentView.addSubview(productPriceThroughLabel!)
        
        //Ale
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        self.contentView.addSubview(imagePresale)
        self.contentView.addSubview(self.deleteProduct)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.deleteProduct.frame = CGRect(x: 0, y: 0 , width: 60 , height: 60)
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (162 / 2),y: 22, width: 162, height: 114)
        self.addProductToShopingCart!.frame = CGRect(x: self.bounds.maxX - 52, y: 8, width: 44 , height: 44)
        self.productPriceLabel!.frame = CGRect(x: 8, y: self.productImage!.frame.maxY + 6, width: self.bounds.width - 16 , height: 16)
        self.productPriceThroughLabel!.frame = CGRect(x: 8, y: self.productPriceLabel!.frame.maxY, width: self.bounds.width - 16 , height: 16)
        self.productShortDescriptionLabel!.frame = CGRect(x: 50,  y: self.productPriceThroughLabel!.frame.maxY + 6, width: self.frame.width - 100 , height: 28)
    }


    func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String,isEditting:Bool,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool ) {
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        
        if (productPriceThrough as NSString).doubleValue > 0 {
            let formatedSaving = CurrencyCustomLabel.formatString(productPriceThrough as NSString)
            let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
            let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
            productPriceThroughLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.green, interLine: false)
            productPriceThroughLabel!.isHidden = false
        }else{
            productPriceThroughLabel!.isHidden = true
        }
        
        imagePresale.isHidden = !isPreorderable

        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.deleteProduct.isHidden = !isEditting
        self.onHandInventory = String(onHandInventory) as NSString
        self.isPreorderable = "\(isPreorderable)"
        
        isDisabled = false
        if isActive == false || onHandInventory == 0  {
            self.addProductToShopingCart!.setImage(UIImage(named: "wishlist_cart_disabled"), for: UIControlState())
            isDisabled = true
        }else{
            if isInShoppingCart {
                addProductToShopingCart!.setImage(UIImage(named: "wishlist_done"), for:UIControlState())
            }else {
                addProductToShopingCart!.setImage(UIImage(named: "wishlist_cart"), for:UIControlState())
            }
        }
    }
    
    
    func addProductToShoping(){
        if !isDisabled {
            let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
            if !hasUPC {
                let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String,pesable:"0",isPreorderable:isPreorderable)
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
