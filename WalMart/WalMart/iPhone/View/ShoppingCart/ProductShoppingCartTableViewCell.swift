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
    func showViewPlpItem()
}


class ProductShoppingCartTableViewCell : ProductTableViewCell,SelectorBandDelegate {
    
    var quantity : Int! = 0
     var productPriceThroughLabel : UILabel!
    
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
    var promotionDescription : String? = ""
    var equivalenceByPiece: NSNumber! = NSNumber(int:0)
    var typeProd : Int = 0
    var comments : String! = ""
    var pesable : Bool = false
    var picturesView : UIView? = nil
    var countPromotion: Int = 0
    
    override func setup() {
        super.setup()
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.hidden =  true
        imagePresale.backgroundColor = UIColor.blueColor()
        self.addSubview(imagePresale)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        
        self.productPriceLabel!.textAlignment = NSTextAlignment.Left
        
        self.productPriceLabel!.hidden = false
        
        self.productPriceThroughLabel = UILabel(frame:CGRectZero)
        self.productPriceThroughLabel!.textAlignment = .Left
 
        
        priceSelector = ShoppingCartButton(frame: CGRectZero)
        priceSelector.addTarget(self, action: #selector(ProductShoppingCartTableViewCell.choseQuantity), forControlEvents: UIControlEvents.TouchUpInside)
        
        separatorView = UIView(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, 109,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth()))
        separatorView.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(productPriceThroughLabel)
        self.contentView.addSubview(priceSelector)
        
        self.picturesView = UIView(frame: CGRectZero)
        self.contentView.addSubview(picturesView!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductShoppingCartTableViewCell.showViewPLP))
        picturesView!.addGestureRecognizer(tapGesture)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 8, self.frame.width - (productImage!.frame.maxX + 16) - 16, 34)
        self.separatorView.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, self.frame.height - 1,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth())

        if  self.productPriceThroughLabel!.hidden {
            self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 8 , 100 , 36)
        }else {
            self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 8 , 100 , 20)
            self.productPriceThroughLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 10)
        }
      
        let size = ShoppingCartButton.sizeForQuantity(quantity,pesable:pesable,hasNote:self.comments != "")
        priceSelector.frame =  CGRectMake((self.frame.width - 16) -  size.width, self.productPriceLabel!.frame.minY, size.width, 30)
        
        self.picturesView!.frame = CGRectMake(112.0, 94.0, 22.0 * CGFloat(self.countPromotion), 14.0)
        
    }
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:NSString,saving:NSString,quantity:Int,onHandInventory:NSString,isPreorderable:String, category: String, promotionDescription: String?, productPriceThrough:String, isMoreArts:Bool) {
        imagePresale.hidden = isPreorderable == "true" ? false : true
        self.priceProduct = productPrice.doubleValue
        self.upc = upc
        self.desc = productShortDescription
        self.price = productPrice
        self.imageurl = productImageURL
        self.onHandInventory = onHandInventory
        self.quantity = quantity
        self.productDeparment = category
        self.isPreorderable = isPreorderable
        self.promotionDescription = promotionDescription
            
        //priceSelector.setValuesMg(self.upc, quantity: quantity, aviable: true)
        priceSelector.setValues(self.upc, quantity: quantity, hasNote: self.comments != "", aviable: true, pesable: typeProd == 1)
        
        let totalInProducts = productPrice.doubleValue * Double(quantity)
        let totalPrice = NSString(format: "%.2f", totalInProducts)
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: totalPrice as String)
        let formatedPrice = CurrencyCustomLabel.formatString(totalPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
      
        
        var savingPrice = ""
        if productPriceThrough != "" { //&& type == ResultObjectType.Groceries.rawValue
            if isMoreArts {
                let doubleVaule = NSString(string: productPriceThrough).doubleValue
                if doubleVaule > 0.1 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)")
                    savingPrice = "\(savingStr) \(formated)"
                    self.productPriceThroughLabel!.textColor = WMColor.red
                }
            } else {
                savingPrice = productPriceThrough
                self.productPriceThroughLabel!.textColor = WMColor.green
            }
        }
        
        if savingPrice != ""{
            self.productPriceThroughLabel!.hidden = false
            self.productPriceThroughLabel.text = savingPrice
            self.productPriceThroughLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        } else{
            self.productPriceThroughLabel!.hidden = true
        }

        
        
        
        let size = ShoppingCartButton.sizeForQuantityWithoutIcon(quantity,pesable:false,hasNote:false)
        self.priceSelector.frame = CGRectMake((self.frame.width - 16) -  size.width, self.productPriceLabel!.frame.minY, size.width, 30)
        
       
        
    }
    
    
    func setPLP(PlpArray:NSArray){
        
        self.countPromotion =  PlpArray.count
        
        for subview in picturesView!.subviews {
            subview.removeFromSuperview()
        }
        
        let yView : CGFloat = 0.0
        var xView : CGFloat = 0.0
        let ySpace : CGFloat = 4.0
        let heighView : CGFloat = 14.0
        let widthView : CGFloat = 18.0
        
        //Show PLP in Cell
        if PlpArray.count > 0 {
            for lineToShow in PlpArray {
                //Se muestran etiquetas para promociones, etc.
                let promotion = UIView(frame: CGRectMake(xView, yView, widthView, heighView))
                promotion.backgroundColor = lineToShow["color"] as? UIColor //WMColor.light_red
                promotion.layer.cornerRadius = 2.0
                
                let textLabel = UILabel(frame: CGRectMake(0, 0, widthView, heighView))
                textLabel.text =  lineToShow["text"] as? String //"TS"
                textLabel.textColor = UIColor.whiteColor()
                textLabel.font = WMFont.fontMyriadProRegularOfSize(9)
                textLabel.textAlignment = .Center
                promotion.addSubview(textLabel)
                
                self.picturesView!.addSubview(promotion)
                
                xView = promotion.frame.maxX + ySpace
            }
        }
        
        self.picturesView!.frame = CGRectMake(112.0, 94.0, 22.0 * CGFloat(self.countPromotion), heighView)
        
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
            updateService.isInCart = true
            updateService.callCoreDataService(upc, quantity: String(quantity), comments: "", desc:desc,price:price as String,imageURL:imageurl,onHandInventory:self.onHandInventory,isPreorderable:isPreorderable,category:self.productDeparment ,successBlock: { (result:NSDictionary) -> Void in
                
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
    
    func tapInPrice(quantity:Int,total:String) {
        
    }
    
    func startEdditingQuantity() {
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "\(desc) - \(upc)")
        UIView.animateWithDuration(0.01, animations: { () -> Void in
            self.productPriceLabel?.alpha = 0.0
            self.productPriceThroughLabel!.alpha = 0.0
        })
    }
    func endEdditingQuantity() {
        UIView.animateWithDuration(0.01, animations: { () -> Void in
            self.productPriceLabel!.alpha = 1.0
            self.productPriceThroughLabel!.alpha = 1.0
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
    
    func showViewPLP(){
        self.delegateProduct?.showViewPlpItem()
    }
    
}