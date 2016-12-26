//
//  ProductShoppingCartTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductShoppingCartTableViewCellDelegate {
    func endUpdatingShoppingCart(_ cell:ProductShoppingCartTableViewCell)
    func deleteProduct(_ cell:ProductShoppingCartTableViewCell)
    func userShouldChangeQuantity(_ cell:ProductShoppingCartTableViewCell)
}


class ProductShoppingCartTableViewCell : ProductTableViewCell,SelectorBandDelegate {
    
    var quantity : Int! = 0
     var productPriceThroughLabel : UILabel!
    
    var priceSelector : ShoppingCartButton!
    var priceProduct : Double!
    var savingProduct : Double!
    var skuId : String!
    var productId : String!
    var delegateProduct : ProductShoppingCartTableViewCellDelegate!
    var desc : String!
    var price : String = ""
    var imageurl : String!
    var separatorView : UIView!
    var onHandInventory : String = ""
    var isPreorderable : String = ""
    var imagePresale : UIImageView!
    var productDeparment: String = ""
    var promotionDescription : String? = ""
    var equivalenceByPiece: NSNumber! = NSNumber(value: 0 as Int32)
    var typeProd : Int = 0
    var comments : String! = ""
    var pesable : Bool = false
    var promotiosView  : UIView?
    var commerceIds : String!
    
    override func setup() {
        super.setup()
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        imagePresale.backgroundColor = UIColor.blue
        self.addSubview(imagePresale)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        productShortDescriptionLabel!.textColor = WMColor.reg_gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        
        self.productPriceLabel!.textAlignment = NSTextAlignment.left
        
        self.productPriceLabel!.isHidden = false
        
        self.productPriceThroughLabel = UILabel(frame:CGRect.zero)
        self.productPriceThroughLabel!.textAlignment = .left
        
        priceSelector = ShoppingCartButton(frame: CGRect.zero)
        priceSelector.addTarget(self, action: #selector(ProductShoppingCartTableViewCell.choseQuantity), for: UIControlEvents.touchUpInside)
        
        separatorView = UIView(frame:CGRect(x: productShortDescriptionLabel!.frame.minX, y: 109,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(productPriceThroughLabel)
        self.contentView.addSubview(priceSelector)
        
        self.promotiosView = UIView()
        self.contentView.addSubview(promotiosView!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 8, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 34)
        self.separatorView.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: self.frame.height - 1,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: AppDelegate.separatorHeigth())

        self.productPriceLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productShortDescriptionLabel!.frame.maxY + 8 , width: 100 , height: 20)
        self.productPriceThroughLabel!.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productPriceLabel!.frame.maxY  , width: 100 , height: 10)
      
        let size = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.comments != "")
        priceSelector.frame =  CGRect(x: (self.frame.width - 16) -  size.width, y: self.productPriceLabel!.frame.minY, width: size.width, height: 30)
        
        self.promotiosView?.frame = CGRect(x: self.productShortDescriptionLabel!.frame.minX, y: 90.0, width: self.productShortDescriptionLabel!.frame.width, height: 30)
    }
    
    func setValueArray(_ plpArray:[[String:Any]]){
        
        if plpArray.count > 0 {
            if self.promotiosView != nil {
                for subview in self.promotiosView!.subviews {
                    subview.removeFromSuperview()
                }
            }
            
            let promoView = PLPLegendView(isvertical: false, PLPArray: plpArray, viewPresentLegend: self.superview!)
            promoView.frame = CGRect(x:0 , y:0 , width: 180, height: 30)
            self.promotiosView!.addSubview(promoView)
        }
    }
    
    func setValues(_ skuid:String?,productId:String?,productImageURL:String,productShortDescription:String,productPrice:String,saving:String,quantity:Int,onHandInventory:String,isPreorderable:String, category: String, promotionDescription: String?, productPriceThrough:String, isMoreArts:Bool,commerceItemId:String,comments:String) {
        imagePresale.isHidden = isPreorderable == "true" ? false : true
        self.priceProduct = (productPrice as NSString).doubleValue
        self.skuId = skuid
        self.productId = productId
        self.commerceIds = commerceItemId
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        self.productDeparment = category
        self.isPreorderable = isPreorderable
        self.promotionDescription = promotionDescription
        self.pesable = typeProd == 1
        self.comments = comments.trimmingCharacters(in: CharacterSet.whitespaces)
        //priceSelector.setValuesMg(self.upc, quantity: quantity, aviable: true)
        priceSelector.setValues(self.productId, quantity: quantity, hasNote: self.comments != "", aviable: true, pesable: typeProd == 1)
        
        let totalInProducts = (productPrice as NSString).doubleValue * Double(quantity)
        let totalPrice = NSString(format: "%.2f", totalInProducts)
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: totalPrice as String)
        let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        var savingPrice = ""
        if productPriceThrough != "" && productPriceThrough != "0" && productPriceThrough != "0.0"{ //&& type == ResultObjectType.Groceries.rawValue
            self.productPriceThroughLabel!.textColor = WMColor.green
            if isMoreArts {
                let doubleVaule = NSString(string: productPriceThrough).doubleValue
                if doubleVaule > 0.1 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)" as NSString)
                    savingPrice = "\(savingStr) \(formated)"
                }
            } else {
                savingPrice = productPriceThrough
            }
        }
        
        if savingPrice != ""{
            self.productPriceThroughLabel!.isHidden = false
            self.productPriceThroughLabel.text = savingPrice
            self.productPriceThroughLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        } else{
            self.productPriceThroughLabel!.isHidden = true
        }

        let size = ShoppingCartButton.sizeForQuantityWithoutIcon(quantity,pesable:self.pesable,hasNote:false)
        self.priceSelector.frame = CGRect(x: (self.frame.width - 16) -  size.width, y: self.productPriceLabel!.frame.minY, width: size.width, height: 30)
    }
    
    /*func setValuesGR(upc:String,productImageURL:String,productShortDescription:String,productPrice:NSString,saving:NSString,quantity:Int,onHandInventory:NSString,typeProd:Int, comments:NSString,equivalenceByPiece:NSNumber) {
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
        
        priceSelector.setValues(self.upc, quantity: quantity, hasNote: self.comments != "", aviable: true, pesable: typeProd == 1)
        
        if saving != "" {
            //productPriceSavingLabel.text = saving as String
            productPriceSavingLabel!.updateMount(saving as String, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.green, interLine: false)
            
            productPriceSavingLabel.hidden = true
        }else{
            self.savingProduct = 0
            productPriceSavingLabel!.updateMount("", font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.green, interLine: false)
            productPriceSavingLabel.hidden = true
        }
        
        //        if self.quantity != nil &&  width == 0 {
        //            let sizeQ = priceSelector.sizeForQuantity(self.quantity, pesable: self.pesable,hasNote:self.comments != "")
        //            self.width = sizeQ.width
        //        }
        
        // priceSelector.frame =  CGRectMake((self.frame.width - 16) -  width!, self.productPriceLabel!.frame.minY, width!, 30)
        //let size = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.comments != "")
        let size = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.comments != "")
        
        priceSelector.frame =  CGRectMake((self.frame.width - 16) -  size.width, self.productPriceLabel!.frame.minY, size.width, 30)
        
    }*/
    
    func addProductQuantity(_ quantity:Int) {
        let maxProduct = ((self.onHandInventory as NSString).integerValue <= 5 || self.productDeparment == "d-papeleria") ?(self.onHandInventory as NSString).integerValue : 5
        if maxProduct < quantity {
            priceSelector.setValues(self.productId, quantity: quantity, hasNote: false, aviable: true, pesable: false)
            
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
            updateService.callCoreDataService(skuId,upc:productId, quantity: String(quantity), comments: "", desc:desc,price:price as String,imageURL:imageurl,onHandInventory:self.onHandInventory as NSString,isPreorderable:isPreorderable,category:self.productDeparment,pesable:String(self.pesable) as NSString,successBlock: { (result:[String:Any]) -> Void in
                
                let totalInProducts = self.priceProduct * Double(quantity)
                let totalPrice = NSString(format: "%.2f", totalInProducts)
                
                let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
                self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
                
                if self.savingProduct > 0 {
                    
                    let totalInSavings = self.savingProduct * Double(quantity)
                    let totalSavings = NSString(format: "%.2f", totalInSavings)
                    
                    //let formatedSaving = CurrencyCustomLabel.formatString(totalSavings)
                    //let ahorrasLabel = NSLocalizedString("price.saving",comment:"")
                    //let finalSavingLabel = "\(ahorrasLabel) \(formatedSaving)"
                    
                   // self.productPriceSavingLabel!.updateMount(finalSavingLabel, font: WMFont.fontMyriadProSemiboldSize(14), color:  WMColor.gray, interLine: false)
                   // self.productPriceSavingLabel.hidden = false
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
    
    func tapInPrice(_ quantity:Int,total:String) {
        
    }
    
    func startEdditingQuantity() {
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "\(desc) - \(productId)")
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.productPriceLabel?.alpha = 0.0
            self.productPriceThroughLabel!.alpha = 0.0
        })
    }
    func endEdditingQuantity() {
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.productPriceLabel!.alpha = 1.0
            self.productPriceThroughLabel!.alpha = 1.0
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
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_QUANTITY_KEYBOARD.rawValue, label: "")
        self.delegateProduct?.userShouldChangeQuantity(self)
    }
    
}
