//
//  ProductShoppingCartTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductShoppingCartTableViewCellDelegate {
    
    
    func startUpdatingShoppingCart()
    func endUpdatingShoppingCart(cell:ProductShoppingCartTableViewCell)
    
    func deleteProduct(cell:ProductShoppingCartTableViewCell)
    
    func startEdditingQuantity()
    func endEdditingQuantity()
    
}


class ProductShoppingCartTableViewCell : ProductTableViewCell,SelectorBandDelegate {
    
    var quantity : Int!
    var productPriceSavingLabel : CurrencyCustomLabel!
    var priceSelector : PriceSelectorBandHandler!
    var priceProduct : Double!
    var savingProduct : Double!
    var upc : String!
    var delegateProduct : ProductShoppingCartTableViewCellDelegate!
    var desc : String!
    var price : NSString = ""
    var imageurl : String!
    var separatorView : UIView!
    var onHandInventory : NSString = ""
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        productShortDescriptionLabel!.textColor = WMColor.shoppingCartProductTextColor
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        
        self.productPriceLabel!.textAlignment = NSTextAlignment.Left
        
        self.productPriceLabel!.hidden = false
        
        productPriceSavingLabel = CurrencyCustomLabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19))
        productPriceSavingLabel!.textAlignment = NSTextAlignment.Left
        
        priceSelector = PriceSelectorBandHandler()
        priceSelector.delegate = self
        priceSelector.numberOfOptions = ShoppingCartAddProductsService.maxItemsInShoppingCart()
        var selectionBand =  priceSelector.buildSelector(CGRectMake(self.frame.width - 210,self.productPriceLabel!.frame.minY  , 192.0, 36.0))
        
        
        separatorView = UIView(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.lineSaparatorColor
        
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(productPriceSavingLabel)
        self.contentView.addSubview(selectionBand)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
        self.separatorView.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth())
        self.priceSelector.container!.frame = CGRectMake(self.frame.width - 210,self.productPriceLabel!.frame.minY  , 192.0, 36.0)
        self.productPriceSavingLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19)
        
    }
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:NSString,saving:NSString,quantity:Int,onHandInventory:NSString) {
        
        self.priceProduct = productPrice.doubleValue
        self.upc = upc
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        priceSelector.setValues(forQuantity: quantity, withPrice: productPrice.doubleValue)
        
        let totalInProducts = productPrice.doubleValue * Double(quantity)
        let totalPrice = NSString(format: "%.2f", totalInProducts)
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: totalPrice)
        let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.priceProductTextColor, interLine: false)
        
        if saving.doubleValue > 0 {
            
            self.savingProduct = saving.doubleValue
            
            let totalInSavings = saving.doubleValue * Double(quantity)
            let totalSavings = NSString(format: "%.2f", totalInSavings)
            
            let formatedSaving = CurrencyCustomLabel.formatString(totalSavings)
            let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
            let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
            productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.productDetailPriceText, interLine: false)
            productPriceSavingLabel.hidden = false
        }else{
            self.savingProduct = 0
            productPriceSavingLabel.hidden = true
        }
        
    }
    
    func addProductQuantity(quantity:Int) {
        
        if self.onHandInventory.integerValue < quantity {
        
            priceSelector.setValues(forQuantity: self.quantity, withPrice:  self.price.doubleValue)
            
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            
            let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
            let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
            let msgInventory = "\(firstMessage)\(self.onHandInventory) \(secondMessage)"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            
            
            
        }else {
        
            delegateProduct.startUpdatingShoppingCart()
            self.quantity = quantity
            let updateService = ShoppingCartUpdateProductsService()
            
            updateService.callCoreDataService(upc, quantity: String(quantity), comments: "", desc:desc,price:price,imageURL:imageurl,onHandInventory:self.onHandInventory,successBlock: { (result:NSDictionary) -> Void in
                
                let totalInProducts = self.priceProduct * Double(quantity)
                let totalPrice = NSString(format: "%.2f", totalInProducts)
                
                let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
                self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.priceProductTextColor, interLine: false)
                
                if self.savingProduct > 0 {
                    
                    let totalInSavings = self.savingProduct * Double(quantity)
                    let totalSavings = NSString(format: "%.2f", totalInSavings)
                    
                    let formatedSaving = CurrencyCustomLabel.formatString(totalSavings)
                    let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
                    let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
                    self.productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.productDetailPriceText, interLine: false)
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
        self.delegateProduct.startEdditingQuantity()
        UIView.animateWithDuration(0.01, animations: { () -> Void in
            self.productPriceLabel?.alpha = 0.0
            self.productPriceSavingLabel?.alpha = 0.0
        })
    }
    func endEdditingQuantity() {
        
        self.delegateProduct.endEdditingQuantity()
        UIView.animateWithDuration(0.01, animations: { () -> Void in
            self.productPriceLabel?.alpha = 1.0
            self.productPriceSavingLabel?.alpha = 1.0
        })
    }
    
}