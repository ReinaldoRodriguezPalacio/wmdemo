//
//  ProductShoppingCartTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductShoppingCartTableViewCellDelegate: class {
    func endUpdatingShoppingCart(_ cell:ProductShoppingCartTableViewCell)
    func deleteProduct(_ cell:ProductShoppingCartTableViewCell)
    func userShouldChangeQuantity(_ cell:ProductShoppingCartTableViewCell)
    
}


class ProductShoppingCartTableViewCell : ProductTableViewCell,SelectorBandDelegate {
    
    var quantity : Int!
    var productPriceSavingLabel : CurrencyCustomLabel!
    var priceSelector : ShoppingCartButton!
    var priceProduct : Double!
    var savingProduct : Double!
    var upc : String!
    weak var delegateProduct : ProductShoppingCartTableViewCellDelegate?
    var desc : String!
    var price : NSString = ""
    var imageurl : String!
    var separatorView : UIView!
    var onHandInventory : NSString = ""
    var isPreorderable : String = ""
    var imagePresale : UIImageView!
    var productDeparment: String = ""
    var providerLBL : UILabel!
    
    override func setup() {
        super.setup()
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        
        productImage!.frame = CGRect(x: 16, y: 15, width: 76, height: 72)
      
        providerLBL = UILabel()
        providerLBL!.font = WMFont.fontMyriadProRegularOfSize(11)
        providerLBL!.numberOfLines = 1
        providerLBL!.textColor =  WMColor.light_blue
        providerLBL!.isHidden = true
        providerLBL!.text = NSLocalizedString("provider.for",comment:"")
        self.contentView.addSubview(providerLBL)
      
      
        self.productPriceLabel!.textAlignment = NSTextAlignment.left
        
        self.productPriceLabel!.isHidden = false
        
        productPriceSavingLabel = CurrencyCustomLabel(frame: CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 19))
        productPriceSavingLabel!.textAlignment = NSTextAlignment.left
        
        priceSelector = ShoppingCartButton(frame: CGRect.zero)
        priceSelector.addTarget(self, action: #selector(ProductShoppingCartTableViewCell.choseQuantity), for: UIControlEvents.touchUpInside)
        
        separatorView = UIView(frame:CGRect(x: productShortDescriptionLabel!.frame.minX, y: 109,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(productPriceSavingLabel)
        self.contentView.addSubview(priceSelector)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 15, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        
        self.providerFrame()
        self.productPriceLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: self.providerLBL.isHidden ? (productShortDescriptionLabel!.frame.maxY + 16) :  (self.providerLBL!.frame.maxY + 7.0) , width: 100 , height: 19)
        self.separatorView.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: 109,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth())
        self.productPriceSavingLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY + (self.providerLBL.isHidden ? 0 : 4.0), width: 100 , height: self.providerLBL.isHidden ? 19 : 10)
      
        self.priceSelector.frame = CGRect(x: (self.frame.width - 16) -  98.0, y: self.productPriceLabel!.frame.minY, width: 98.0, height: 30)
    }
    
    func providerFrame() {
        if !self.providerLBL.isHidden {
            self.providerLBL!.frame =  CGRect(x: productShortDescriptionLabel!.frame.minX, y: self.productShortDescriptionLabel!.frame.maxY + 3.0, width: self.frame.width - productShortDescriptionLabel!.frame.minX - 16.0, height: 11.0)
        } else {
            self.providerLBL!.frame =  CGRect(x: productShortDescriptionLabel!.frame.minX, y: self.productShortDescriptionLabel!.frame.maxY + 3.0, width: self.frame.width - productShortDescriptionLabel!.frame.minX - 16.0, height: 0.0)
            self.productPriceLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productShortDescriptionLabel!.frame.maxY + 16 , width: 100 , height: 19)
        }
    }
    
    func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:NSString,saving:NSString,quantity:Int,onHandInventory:NSString,isPreorderable:String, category: String, provider:String) {
        imagePresale.isHidden = isPreorderable == "true" ? false : true
        
        self.priceProduct = productPrice.doubleValue
        self.upc = upc
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        self.productDeparment = category
        self.isPreorderable = isPreorderable
        
        priceSelector.setValuesMg(self.upc, quantity: quantity, aviable: true)
      
        self.providerLBL.text = self.providerLBL.text! + provider
        self.providerLBL.isHidden = provider != "" ? false : true
        self.providerFrame()
        
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
            productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProRegularOfSize(12), color:  WMColor.green, interLine: false)
            productPriceSavingLabel.isHidden = false
        }else{
            self.savingProduct = 0
            productPriceSavingLabel.isHidden = true
        }
        //let size = ShoppingCartButton.sizeForQuantityWithoutIcon(quantity, pesable: false, hasNote: false, orderByPieces: false, pieces: 0)
        //self.priceSelector.frame = CGRect(x: (self.frame.width - 16) -  size.width, y: self.productPriceLabel!.frame.minY, width: size.width, height: 30)
    }
    
    func addProductQuantity(_ quantity:Int) {
        let maxProduct = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
        if maxProduct < quantity {
            priceSelector.setValues(self.upc, quantity: quantity, hasNote: false, aviable: true, pesable: false, orderByPieces: false, pieces: 0)
            
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            
            let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
            let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
            let msgInventory = "\(firstMessage)\(maxProduct) \(secondMessage)"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            
            
            
        }else {
            self.quantity = quantity
            let updateService = ShoppingCartUpdateProductsService()
            updateService.isInCart = true
            updateService.callCoreDataService(upc, quantity: String(quantity), comments: "", desc:desc,price:price as String,imageURL:imageurl,onHandInventory:self.onHandInventory,isPreorderable:isPreorderable,category:self.productDeparment,sellerId: nil,sellerName: nil,offerId: nil,successBlock: { (result:[String:Any]) -> Void in
                
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
                    self.productPriceSavingLabel.isHidden = false
                    
                    
                }
                self.delegateProduct?.endUpdatingShoppingCart(self)
                
                }) { (error:NSError) -> Void in
                    
                    self.delegateProduct?.endUpdatingShoppingCart(self)
                    
            }

        }

        
    }

    func deleteProduct() {
        self.delegateProduct?.deleteProduct(self)
    }
    
    func tapInPrice(_ quantity:Int,total:String) {
        
    }
    
    func startEdditingQuantity() {
        //EVENT
        ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "\(desc) - \(upc)")
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.productPriceLabel?.alpha = 0.0
            self.productPriceSavingLabel!.alpha = 0.0
        })
    }
    func endEdditingQuantity() {
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.productPriceLabel!.alpha = 1.0
            self.productPriceSavingLabel!.alpha = 1.0
        })
    }
    func moveRightImagePresale(_ moveRight:Bool){
        if moveRight {
            UIView.animate( withDuration: 0.3 , animations: {
                self.imagePresale.frame = CGRect( x: 36, y: 0, width: 46, height: 46)
            })
        }
        else{
            self.imagePresale.frame = CGRect( x: 0, y: 0, width: 46, height: 46)
        }
    }
    
    func choseQuantity() {
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_QUANTITY_KEYBOARD.rawValue, label: "")
        self.delegateProduct?.userShouldChangeQuantity(self)
    }
}
