//
//  ShoppingCartAddProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/9/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


class ShoppingCartAddProductsService : BaseService {
    

    class func maxItemsInShoppingCart() -> Int {
        return ShoppingCartParams.maxProducts
    }
    
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory]
    }
    
    func builParams(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString) -> [[String:AnyObject]] {
        return [["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory]]
    }
    
    func builParamSvc(upc:String,quantity:String,comments:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist]
    }

    
    func callService(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory), successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        
        
        if UserCurrentSession.sharedInstance().userSigned != nil {
            
            var itemsSvc : [[String:AnyObject]] = []
            var itemsWishList : [String] = []
           
            var upcSend = ""
            for itemSvc in params as! NSArray {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                itemsSvc.append(builParamSvc(upc,quantity:quantity,comments:""))
                
                let wlValue =  itemSvc["wishlist"] as? Bool
                
                if  let delWishlist = itemSvc["wishlist"] as? Bool {
                    itemsWishList.append(upc)
                }
                
            }
            
            if itemsSvc.count > 1 {
                self.callPOSTService(itemsSvc, successBlock: { (resultCall:NSDictionary) -> Void in
                    
                    
                    if self.updateShoppingCart() {
                        
                        let serviceWishDelete = DeleteItemWishlistService()

                        for itemWishlistUPC in itemsWishList {
                            serviceWishDelete.callCoreDataService(itemWishlistUPC, successBlock: { (result:NSDictionary) -> Void in
                                }) { (error:NSError) -> Void in
                            }
                        }
                        
                        UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
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
            
                let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upcSend)
                if !hasUPC {
                        self.callPOSTService(itemsSvc, successBlock: { (resultCall:NSDictionary) -> Void in
                        
                        
                        if self.updateShoppingCart() {
                            UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
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
                    let svcUpdateShoppingCart = ShoppingCartUpdateProductsService()
                    svcUpdateShoppingCart.callService(params,updateSC:true,successBlock:successBlock, errorBlock:errorBlock )
                }
            }
        } else {
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    func callCoreDataService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for product in params as! NSArray {
            
            var cartProduct : Cart
            var predicate = NSPredicate(format: "product.upc == %@ ",product["upc"] as! String)
            if UserCurrentSession.sharedInstance().userSigned != nil {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! String,UserCurrentSession.sharedInstance().userSigned!)
            }
            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
            if array.count == 0 {
                cartProduct = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: context) as! Cart
                var productBD =  NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
                cartProduct.product = productBD
            }else{
                cartProduct = array[0]
            }
            let quantityStr = product["quantity"] as! NSString
            if  quantityStr.integerValue <= ShoppingCartAddProductsService.maxItemsInShoppingCart() {
                cartProduct.quantity = NSNumber(integer:quantityStr.integerValue)
            } else {
                cartProduct.quantity = NSNumber(integer:ShoppingCartAddProductsService.maxItemsInShoppingCart())
            }
            
            println("Product in shopping cart: \(product)")
            
            cartProduct.product.upc = product["upc"] as! String
            cartProduct.product.price = product["price"] as! String
            cartProduct.product.desc = product["desc"] as! String
            cartProduct.product.img = product["imageURL"] as! String
            cartProduct.product.onHandInventory = product["onHandInventory"] as! String
            cartProduct.product.iva = ""
            cartProduct.product.baseprice = ""
            cartProduct.status = NSNumber(integer: statusForProduct())
            cartProduct.type = ResultObjectType.Mg.rawValue
            
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

}