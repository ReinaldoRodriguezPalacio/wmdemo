//
//  GRShoppingCartAddProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRShoppingCartAddProductsService : GRBaseService {
    
    func buildParams(quantity:String,upc:String,comments:String) -> NSArray {
        let quantityInt : Int = quantity.toInt()!
        return [["quantity":quantityInt,"upc":upc,"comments":comments]]
    }
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory]
    }
    
    func builParams(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,pesable:NSString) -> [[String:AnyObject]] {
        return [["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"pesable":pesable]]
    }
    
    func builParamSvc(upc:String,quantity:String,comments:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,pesable:NSString) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable]
    }
    
    func callService(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,pesable:NSString,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(requestParams: builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,pesable:pesable), successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,pesable:NSString,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,pesable:pesable), successBlock: successBlock, errorBlock: errorBlock)
    }

    func callService(upc:String,quantity:String,comments:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callService(requestParams: buildParams(quantity,upc:upc,comments:comments), successBlock: successBlock,errorBlock:errorBlock)
    }

    func buildParams(products:[AnyObject]) -> [String:AnyObject] {
        return ["strArrImp":products]
    }
    
    func buildProductObject(#upc:String, quantity:String, comments:String) -> [String:AnyObject] {
        return ["quantity":quantity,"upc":upc,"comments":comments]
    }
    
    func callService(requestParams params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        if UserCurrentSession.sharedInstance().userSigned != nil {
            var itemsSvc : [[String:AnyObject]] = []
            var upcSend = ""
            for itemSvc in params as NSArray {
                let upc = itemSvc["upc"] as NSString
                upcSend = upc
                let quantity = itemSvc["quantity"] as NSString
                var  comments = ""
                if let comment  = itemSvc["comments"] as? NSString {
                    comments = comment
                }
                itemsSvc.append(buildProductObject(upc: upc,quantity:quantity,comments:comments))
            }
            
            let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upcSend)
            if !hasUPC {
                self.callPOSTService(itemsSvc, successBlock: { (resultCall:NSDictionary) -> Void in
                    
                    if self.updateShoppingCart() {
//                        let shoppingService = GRShoppingCartProductsService()
//                        shoppingService.callService(requestParams: [:], successBlock: successBlock, errorBlock: errorBlock)
                        UserCurrentSession.sharedInstance().loadGRShoppingCart({ () -> Void in
                            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
                            successBlock!([:])
                        })
                    }else{
                        successBlock!([:])
                    }
                    }) { (error:NSError) -> Void in
                        errorBlock!(error)
                }
            } else {
                
                let svcUpdateShoppingCart = GRShoppingCartUpdateProductsService()
                svcUpdateShoppingCart.callService(params,updateSC:true,successBlock:successBlock, errorBlock:errorBlock )

//                UserCurrentSession.sharedInstance().loadGRShoppingCart({ () -> Void in
//                    UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
//                    successBlock!([:])
//                })
            }

        
        } else {
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    
    func callCoreDataService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for product in params as NSArray {
            
            var cartProduct : Cart
            var predicate = NSPredicate(format: "product.upc == %@ ",product["upc"] as NSString)
            if UserCurrentSession.sharedInstance().userSigned != nil {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as NSString,UserCurrentSession.sharedInstance().userSigned!)
            }
            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as [Cart]
            if array.count == 0 {
                cartProduct = NSEntityDescription.insertNewObjectForEntityForName("Cart" as NSString, inManagedObjectContext: context) as Cart
                var productBD =  NSEntityDescription.insertNewObjectForEntityForName("Product" as NSString, inManagedObjectContext: context) as Product
                cartProduct.product = productBD
            }else{
                cartProduct = array[0]
            }
            let quantityStr = product["quantity"] as NSString
            cartProduct.quantity = NSNumber(integer:quantityStr.integerValue)
            
            println("Product in shopping cart: \(product)")

            var pesable : NSString = "0"
            if let pesableP = product["pesable"] as? String {
                pesable = pesableP
            }
            cartProduct.product.upc = product["upc"] as NSString
            cartProduct.product.price = product["price"] as NSString
            cartProduct.product.desc = product["desc"] as NSString
            cartProduct.product.img = product["imageURL"] as NSString
            cartProduct.product.onHandInventory = product["onHandInventory"] as NSString
            cartProduct.product.iva = ""
            cartProduct.product.baseprice = ""
            cartProduct.product.type = pesable.integerValue
            cartProduct.status = NSNumber(integer: statusForProduct())
            cartProduct.type = ResultObjectType.Groceries.rawValue
            
            if let comment  = product["comments"] as? NSString {
                cartProduct.note = comment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            
            if UserCurrentSession.sharedInstance().userSigned != nil {
                cartProduct.user  = UserCurrentSession.sharedInstance().userSigned!
            }
        }
        var error: NSError? = nil
        context.save(&error)
        
        WishlistService.shouldupdate = true
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
        
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
        
    }
    
    func statusForProduct() -> Int {
        return CartStatus.Created.rawValue
    }
    
    func updateShoppingCart() -> Bool {
        return true
    }

    override func needsToLoginCode() -> Int {
        return -10
    }
    
    
}
