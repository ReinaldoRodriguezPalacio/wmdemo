//
//  OrderProductTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class OrderProductTableViewCell : ProductTableViewCell {
    
    var upc : String!
    var skuid: String!
    var stock : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    //var upcString : UILabel!
    var priceString : CurrencyCustomLabel!
    var quantityString : UILabel!
    var separatorView : UIView!
    var btnShoppingCart : UIButton!
    var type : ResultObjectType!
    var pesable : Bool! = false
    var onHandInventory : NSString! = "0"
    var isActive : Bool = true
    var isPreorderable = "false"
    
    override func setup() {
        super.setup()
        
        self.productPriceLabel!.hidden = true
        
        productShortDescriptionLabel!.textColor = WMColor.reg_gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        
        btnShoppingCart = UIButton(frame: CGRectMake(self.frame.width - 16 - 32, productShortDescriptionLabel!.frame.maxY + 16, 32, 32))
        btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
        btnShoppingCart.addTarget(self, action: #selector(OrderProductTableViewCell.addToShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        
        separatorView = UIView(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, 108,self.frame.width - productShortDescriptionLabel!.frame.minX, 1))
        separatorView.backgroundColor = WMColor.light_gray
        
        priceString = CurrencyCustomLabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 18, 100, 18))
        priceString.textAlignment = .Left
        priceString.backgroundColor = UIColor.clearColor()
        priceString.setCurrencyUserInteractionEnabled(true)
        //upcString = UILabel(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 18,self.frame.width - productShortDescriptionLabel!.frame.minX, 12))
        
        quantityString = UILabel(frame:CGRectMake(productShortDescriptionLabel!.frame.minX, priceString.frame.maxY + 3,self.frame.width - productShortDescriptionLabel!.frame.minX, 12))
       
        self.contentView.addSubview(priceString)
        //self.contentView.addSubview(upcString)
        self.contentView.addSubview(quantityString)
        self.contentView.addSubview(btnShoppingCart)
        self.contentView.addSubview(separatorView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        btnShoppingCart.frame = CGRectMake(self.frame.width - 16 - 32, productShortDescriptionLabel!.frame.maxY + 16, 32, 32)
        separatorView.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 108,self.frame.width - productShortDescriptionLabel!.frame.minX, 1)
        priceString.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 58, 100, 18)
        //upcString.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 18,self.frame.width - productShortDescriptionLabel!.frame.minX, 12)
        quantityString.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, priceString.frame.maxY + 3,self.frame.width - productShortDescriptionLabel!.frame.minX, 12)
    }
    
    func setValues(skuid:String,upc:String,productImageURL:String,productShortDescription:String,productPrice:String,quantity:NSString, type:ResultObjectType, pesable:Bool, onHandInventory:String,isActive:Bool,isPreorderable:String) {
        
        self.upc = upc
        self.skuid = skuid
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.type = type
        self.pesable = pesable
        self.onHandInventory = onHandInventory
        self.isPreorderable = isPreorderable
        
        let lblUPC = NSLocalizedString("previousorder.upc",comment:"")

        //var valueItem = NSMutableAttributedString()
        let attrStringLab = NSAttributedString(string:"\(lblUPC): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(12),NSForegroundColorAttributeName:WMColor.reg_gray])
        let attrStringVal = NSAttributedString(string:"\(upc)", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(12),NSForegroundColorAttributeName:WMColor.dark_gray])
        
        let valuesDescItem = NSMutableAttributedString()
        valuesDescItem.appendAttributedString(attrStringLab)
        valuesDescItem.appendAttributedString(attrStringVal)
        
        //upcString.attributedText = valuesDescItem
        priceString.updateMount(productPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        var lblItems = NSLocalizedString("previousorder.quantity",comment:"")
        var attrStringLabQ = NSAttributedString(string:"\(lblItems): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(12),NSForegroundColorAttributeName:WMColor.reg_gray])
        var attrStringValQ = NSAttributedString(string:"\(quantity.integerValue)", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(12),NSForegroundColorAttributeName:WMColor.dark_gray])
        
        if pesable {
            lblItems = NSLocalizedString("previousorder.quantityPesable",comment:"")
            let quantityDouble: Double = quantity.integerValue >= 100 ? (quantity.doubleValue / 1000) : quantity.doubleValue
            let quantitiString: NSString = quantity.integerValue >= 100 ? NSString(format: "%.2f kg", quantityDouble) : NSString(format: "%.0f gr", quantityDouble)
            attrStringLabQ = NSAttributedString(string:"\(lblItems): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(12),NSForegroundColorAttributeName:WMColor.reg_gray])
            attrStringValQ = NSAttributedString(string:quantitiString as String, attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(12),NSForegroundColorAttributeName:WMColor.dark_gray])
        }
        
        let valuesDescItemQ = NSMutableAttributedString()
        valuesDescItemQ.appendAttributedString(attrStringLabQ)
        valuesDescItemQ.appendAttributedString(attrStringValQ)
        
        quantityString.attributedText = valuesDescItemQ
        
        let isInShoppingCart = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
        
        if isActive == false  {
            btnShoppingCart.enabled = false
            self.btnShoppingCart.setImage(UIImage(named: "wishlist_cart_disabled"), forState: UIControlState.Normal)
        }else{
            if isInShoppingCart {
                btnShoppingCart.enabled = true
                btnShoppingCart.setImage(UIImage(named: "products_done"), forState:UIControlState.Normal)
            }else {
                btnShoppingCart.enabled = true
                btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
            }
        }
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
    }
    
    
    func addToShoppingCart() {
        let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
        if !hasUPC {
            
            if type == ResultObjectType.Mg {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: "")
            }else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: "")
            }
            
            var quanty = "1"
            if self.type == ResultObjectType.Groceries    {
                
                if self.pesable == true {
                    quanty = "50"
                }

                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue , label:"\(self.desc) \(self.upc)")
                
                
                let  params = CustomBarViewController.buildParamsUpdateShoppingCart(self.skuid,upc:self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: quanty, comments:"", onHandInventory:self.onHandInventory as String, type:self.type.rawValue , pesable: (self.pesable == true ? "1" : "0"),isPreorderable:isPreorderable)
                
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                
            }
            else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue , label:"\(self.desc) \(self.upc)")
                
                let  params = CustomBarViewController.buildParamsUpdateShoppingCart(self.skuid, upc:self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String, wishlist:false,type:self.type.rawValue ,pesable:"0",isPreorderable:isPreorderable, category: "")
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
            }
            
            //let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:"1",wishlist:false,type:type.rawValue,pesable:"0")
            
            /*let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory,pesable:"0", type: resultObjectType.rawValue)
            */
            //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
        }else{
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
            alert!.setMessage(NSLocalizedString("shoppingcart.isincart",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
        }
    }
    
}