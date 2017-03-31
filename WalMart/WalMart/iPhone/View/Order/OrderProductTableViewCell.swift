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
    var stock : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    var upcString : UILabel!
    var quantityString : UILabel!
    var separatorView : UIView!
    var btnShoppingCart : UIButton!
    var type : ResultObjectType!
    var pesable : Bool! = false
    var onHandInventory : NSString! = "0"
    var isActive : Bool = true
    var isPreorderable = "false"
    var canTap = true
    
    override func setup() {
        super.setup()
        
        
        self.productPriceLabel!.isHidden = true
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 16, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        
        
        btnShoppingCart = UIButton(frame: CGRect(x: self.frame.width - 16 - 32, y: productShortDescriptionLabel!.frame.maxY + 16, width: 32, height: 32))
        btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), for:UIControlState())
        btnShoppingCart.addTarget(self, action: #selector(OrderProductTableViewCell.addToShoppingCart), for: UIControlEvents.touchUpInside)
        
        separatorView = UIView(frame:CGRect(x: productShortDescriptionLabel!.frame.minX, y: 108,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 1))
        separatorView.backgroundColor = WMColor.light_gray
        
        
        upcString = UILabel(frame:CGRect(x: productShortDescriptionLabel!.frame.minX, y: productShortDescriptionLabel!.frame.maxY + 18,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 12))
        

        
        quantityString = UILabel(frame:CGRect(x: productShortDescriptionLabel!.frame.minX, y: upcString.frame.maxY + 3,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 12))
       
        
        self.contentView.addSubview(upcString)
        self.contentView.addSubview(quantityString)
        self.contentView.addSubview(btnShoppingCart)
        self.contentView.addSubview(separatorView)
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productImage!.frame = CGRect(x: 16, y: 0, width: 80, height: 109)
        productShortDescriptionLabel!.frame = CGRect(x: productImage!.frame.maxX + 16, y: 16, width: self.frame.width - (productImage!.frame.maxX + 16) - 16, height: 28)
        btnShoppingCart.frame = CGRect(x: self.frame.width - 16 - 32, y: productShortDescriptionLabel!.frame.maxY + 16, width: 32, height: 32)
        separatorView.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: 108,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 1)
        upcString.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: productShortDescriptionLabel!.frame.maxY + 18,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 12)
        quantityString.frame = CGRect(x: productShortDescriptionLabel!.frame.minX, y: upcString.frame.maxY + 3,width: self.frame.width - productShortDescriptionLabel!.frame.minX, height: 12)
    }
    
    func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:String,quantity:NSString, type:ResultObjectType, pesable:Bool, onHandInventory:String,isActive:Bool,isPreorderable:String) {
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.type = type
        self.pesable = pesable
        self.onHandInventory = onHandInventory as NSString!
        self.isPreorderable = isPreorderable
        
        let lblUPC = NSLocalizedString("previousorder.upc",comment:"")

        //var valueItem = NSMutableAttributedString()
        let attrStringLab = NSAttributedString(string:"\(lblUPC): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(12),NSForegroundColorAttributeName:WMColor.gray])
        let attrStringVal = NSAttributedString(string:"\(upc)", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(12),NSForegroundColorAttributeName:WMColor.dark_gray])
        
        let valuesDescItem = NSMutableAttributedString()
        valuesDescItem.append(attrStringLab)
        valuesDescItem.append(attrStringVal)
        
        upcString.attributedText = valuesDescItem
        
        var lblItems = NSLocalizedString("previousorder.quantity",comment:"")
        var attrStringLabQ = NSAttributedString(string:"\(lblItems): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(12),NSForegroundColorAttributeName:WMColor.gray])
        var attrStringValQ = NSAttributedString(string:"\(quantity.integerValue)", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(12),NSForegroundColorAttributeName:WMColor.dark_gray])
        
        if pesable {
            lblItems = NSLocalizedString("previousorder.quantityPesable",comment:"")
            let quantityDouble: Double = quantity.integerValue >= 100 ? (quantity.doubleValue / 1000) : quantity.doubleValue
            let quantitiString: NSString = quantity.integerValue >= 100 ? NSString(format: "%.2f kg", quantityDouble) : NSString(format: "%.0f gr", quantityDouble)
            attrStringLabQ = NSAttributedString(string:"\(lblItems): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(12),NSForegroundColorAttributeName:WMColor.gray])
            attrStringValQ = NSAttributedString(string:quantitiString as String, attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(12),NSForegroundColorAttributeName:WMColor.dark_gray])
        }
        
        
        let valuesDescItemQ = NSMutableAttributedString()
        valuesDescItemQ.append(attrStringLabQ)
        valuesDescItemQ.append(attrStringValQ)
        
        quantityString.attributedText = valuesDescItemQ
        
        let isInShoppingCart = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
        
        if isActive == false  {
            btnShoppingCart.isEnabled = false
            self.btnShoppingCart.setImage(UIImage(named: "wishlist_cart_disabled"), for: UIControlState())
        }else{
            if isInShoppingCart {
                btnShoppingCart.isEnabled = true
                btnShoppingCart.setImage(UIImage(named: "products_done"), for:UIControlState())
            }else {
                btnShoppingCart.isEnabled = true
                btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), for:UIControlState())
            }
        }
        
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        
    }
    
    
    func addToShoppingCart() {
        if canTap {
            
            let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
            canTap = false
            
            if !hasUPC {
                
                var quanty = "1"
                if self.type == ResultObjectType.Groceries    {
                    
                    if self.pesable == true {
                        quanty = "50"
                    }
                    
                    let  params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: quanty, comments:"", onHandInventory:self.onHandInventory as String, type:self.type.rawValue , pesable: (self.pesable == true ? "1" : "0"),isPreorderable:isPreorderable,orderByPieces: !self.pesable)
                    btnShoppingCart.setImage(UIImage(named: "wishlist_done"), for:UIControlState())
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                    
                }else {
                    
                    let  params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String, wishlist:false,type:self.type.rawValue ,pesable:"0",isPreorderable:isPreorderable, category: "")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
            
            delay(0.5, completion: {
                self.canTap = true
            })
            
        }
    }
    
    
}
