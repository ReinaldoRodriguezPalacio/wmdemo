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
    var useSignals = false
    var parameterSend : AnyObject?
    override init() {
        super.init()
        //self.urlForSession = true
    }
    
    
    
    init(dictionary:NSDictionary){
        super.init()
        //self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }


    class func maxItemsInShoppingCart(useDefault:Bool, onHandInventory:Int) -> Int {
        return useDefault ? ShoppingCartParams.maxProducts : onHandInventory
    }
    
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable]
    }
    
    func builParams(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,parameter:[String:AnyObject]?) -> [[String:AnyObject]] {
        if useSignals && parameter != nil{
            parameterSend = parameter!
            return [["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable,"parameter":parameter!]]
        }
        return [["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable]]
    }
    
    func builParamSvc(upc:String,quantity:String,comments:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,isPreorderable:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist]
    }
    
    func buildProductObject(upcsParams:[AnyObject]) -> AnyObject {
        
        if useSignals  && self.parameterSend != nil {
            return   ["items":upcsParams,"parameter":self.parameterSend!]
            
        }
        return upcsParams
    }

    
    func callService(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,parameter:[String:AnyObject]?,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable, parameter:parameter), successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,parameter: nil), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        
        
        if UserCurrentSession.hasLoggedUser() {
            
            var itemsSvc : [[String:AnyObject]] = []
            var itemsWishList : [String] = []
           
            var upcSend = ""
            for itemSvc in params as! NSArray {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                itemsSvc.append(builParamSvc(upc,quantity:quantity,comments:""))
                
                if  let _ = itemSvc["wishlist"] as? Bool {
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
                    var send  : AnyObject?
                    if useSignals  && self.parameterSend != nil{
                        send = buildProductObject(itemsSvc)
                    }else{
                        send = itemsSvc
                    }
                        self.callPOSTService(send!, successBlock: { (resultCall:NSDictionary) -> Void in
                        
                        
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
        
//        if (UserCurrentSession.sharedInstance().hasPreorderable()) {// is preorderable
//            let items  = UserCurrentSession.sharedInstance().itemsMG!["items"] as? NSArray
//            let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
//            let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
//            errorBlock?(error)
//            return
//        } else {
            for product in params as! NSArray {
                if let preorderable = product["isPreorderable"] as? String {
                if preorderable == "true" && !UserCurrentSession.sharedInstance().isEmptyMG() {
                    let message = NSLocalizedString("mg.preorderanble.item.add",  comment: "")
                    let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                    errorBlock?(error)
                    return
                    }
                }
            //}
        }
        
        
        
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for product in params as! NSArray {
            
            var cartProduct : Cart
            var predicate = NSPredicate(format: "product.upc == %@ ",product["upc"] as! String)
            if UserCurrentSession.hasLoggedUser() {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! String,UserCurrentSession.sharedInstance().userSigned!)
            }
            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
            if array.count == 0 {
                cartProduct = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: context) as! Cart
                let productBD =  NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
                cartProduct.product = productBD
            }else{
                cartProduct = array[0]
            }
            let quantityStr = product["quantity"] as! NSString
            cartProduct.quantity = NSNumber(integer:quantityStr.integerValue)
            
            print("Product in shopping cart: \(product)")
            
            cartProduct.product.upc = product["upc"] as! String
            cartProduct.product.price = product["price"] as! String
            cartProduct.product.desc = product["desc"] as! String
            cartProduct.product.img = product["imageURL"] as! String
            cartProduct.product.onHandInventory = product["onHandInventory"] as! String
            cartProduct.product.iva = ""
            cartProduct.product.baseprice = ""
            cartProduct.product.isPreorderable =  product["isPreorderable"]  as? String == nil ? "false" : product["isPreorderable"] as! String
            cartProduct.status = NSNumber(integer: statusForProduct())
            cartProduct.type = ResultObjectType.Mg.rawValue

            if UserCurrentSession.hasLoggedUser() {
                cartProduct.user  = UserCurrentSession.sharedInstance().userSigned!
            }
        }
        do {
            try context.save()
        } catch {
           print("Error saving context callCoreDataService ")
        }
        
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