//
//  ProductShoppingCartTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductShoppingCartTableViewCellDelegate {
    func endUpdatingShoppingCart(cell:ProductShoppingCartTableViewCell)
    func deleteProduct(cell:ProductShoppingCartTableViewCell)
    func userShouldChangeQuantity(cell:ProductShoppingCartTableViewCell)
    
}


class ProductShoppingCartTableViewCell : ProductTableViewCell,SelectorBandDelegate {
    
    var quantity : Int!
    var productPriceSavingLabel : CurrencyCustomLabel!
    var priceSelector : ShoppingCartButton!
    var priceProduct : Double!
    var savingProduct : Double!
    var upc : String!
    var delegateProduct : ProductShoppingCartTableViewCellDelegate!
    var desc : String!
    var price : NSString = ""
    var imageurl : String!
    var separatorView : UIView!
    var onHandInventory : NSString = ""
    var isPreorderable : String = ""
    var imagePresale : UIImageView!
    var productDeparment: String = ""
    
    override func setup() {
        super.setup()
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.hidden =  true
        self.addSubview(imagePresale)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        
        self.productPriceLabel!.textAlignment = NSTextAlignment.Left
        
        self.productPriceLabel!.hidden = false
        
        productPriceSavingLabel = CurrencyCustomLabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19))
        productPriceSavingLabel!.textAlignment = NSTextAlignment.Left
        
        priceSelector = ShoppingCartButton(frame: CGRectZero)
        priceSelector.addTarget(self, action: #selector(ProductShoppingCartTableViewCell.choseQuantity), forControlEvents: UIControlEvents.TouchUpInside)
        
        separatorView = UIView(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(productPriceSavingLabel)
        self.contentView.addSubview(priceSelector)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
        self.separatorView.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth())
        self.productPriceSavingLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19)
        
    }
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:NSString,saving:NSString,quantity:Int,onHandInventory:NSString,isPreorderable:String, category: String) {
        imagePresale.hidden = isPreorderable == "true" ? false : true
        self.priceProduct = productPrice.doubleValue
        self.upc = upc
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        self.productDeparment = category
        
        priceSelector.setValuesMg(self.upc, quantity: quantity, aviable: true)
        
        let totalInProducts = productPrice.doubleValue * Double(quantity)
        let totalPrice = NSString(format: "%.2f", totalInProducts)
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: totalPrice as String)
        let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        if saving.doubleValue > 0 {
            
            self.savingProduct = saving.doubleValue
            
            let totalInSavings = saving.doubleValue * Double(quantity)
            let totalSavings = NSString(format: "%.2f", totalInSavings)
            
            let formatedSaving = CurrencyCustomLabel.formatString(totalSavings)
            let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
            let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
            productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.green, interLine: false)
            productPriceSavingLabel.hidden = false
        }else{
            self.savingProduct = 0
            productPriceSavingLabel.hidden = true
        }
        let size = ShoppingCartButton.sizeForQuantityWithoutIcon(quantity,pesable:false,hasNote:false)
        self.priceSelector.frame = CGRectMake((self.frame.width - 16) -  size.width, self.productPriceLabel!.frame.minY, size.width, 30)
    }
    
    func addProductQuantity(quantity:Int) {
        let maxProduct = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
        if maxProduct < quantity {
            priceSelector.setValues(self.upc, quantity: quantity, hasNote: false, aviable: true, pesable: false)
            
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            
            let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
            let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
            let msgInventory = "\(firstMessage)\(maxProduct) \(secondMessage)"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            
            
            
        }else {
            self.quantity = quantity
            let updateService = ShoppingCartUpdateProductsService()
            
            updateService.callCoreDataService(upc, quantity: String(quantity), comments: "", desc:desc,price:price as String,imageURL:imageurl,onHandInventory:self.onHandInventory,isPreorderable:isPreorderable,successBlock: { (result:NSDictionary) -> Void in
                
                let totalInProducts = self.priceProduct * Double(quantity)
                let totalPrice = NSString(format: "%.2f", totalInProducts)
                
                let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
                self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
                
                if self.savingProduct > 0 {
                    
                    let totalInSavings = self.savingProduct * Double(quantity)
                    let totalSavings = NSString(format: "%.2f", totalInSavings)
                    
                    let formatedSaving = CurrencyCustomLabel.formatString(totalSavings)
                    let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
                    let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
                    self.productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.gray, interLine: false)
                    self.productPriceSavingLabel.hidden = false
                    
                    
                }
                self.delegateProduct.endUpdatingShoppingCart(self)
                
                }) { (error:NSError) -> Void in
                    
                    self.delegateProduct.endUpdatingShoppingCart(self)
                    
            }

        }

        
    }

    func deleteProduct() {
        self.delegateProduct.deleteProduct(self)
    }
    
    func tapInPrice(quantity:Int,total:String) {
        
    }
    
    func startEdditingQuantity() {
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "\(desc) - \(upc)")
        UIView.animateWithDuration(0.01, animations: { () -> Void in
            self.productPriceLabel?.alpha = 0.0
            self.productPriceSavingLabel!.alpha = 0.0
        })
    }
    func endEdditingQuantity() {
        UIView.animateWithDuration(0.01, animations: { () -> Void in
            self.productPriceLabel!.alpha = 1.0
            self.productPriceSavingLabel!.alpha = 1.0
        })
    }
    func moveRightImagePresale(moveRight:Bool){
        if moveRight {
            UIView.animateWithDuration( 0.3 , animations: {
                self.imagePresale.frame = CGRectMake( 36, 0, 46, 46)
            })
        }
        else{
            self.imagePresale.frame = CGRectMake( 0, 0, 46, 46)
        }
    }
    
    func choseQuantity() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_QUANTITY_KEYBOARD.rawValue, label: "")
        self.delegateProduct?.userShouldChangeQuantity(self)
    }
}