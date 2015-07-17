//
//  ShoppingCartProductsServices.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


struct ShoppingCartService {
    static var shouldupdate : Bool = true
    static var isSynchronizing : Bool = false
}

class ShoppingCartProductsService : BaseService {
    
    let JSON_PRODUCTDETAIL_RESULT = "responseObject"
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !ShoppingCartService.isSynchronizing {
        if UserCurrentSession.sharedInstance().userSigned != nil {
            synchronizeWebShoppingCartFromCoreData({ () -> Void in
                self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
                    
                    //println("Items in shoppingCart: \(resultCall)")
                    
                    let itemsInShoppingCart = resultCall["items"] as NSArray
                    
                    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    
                    let user = UserCurrentSession.sharedInstance().userSigned
                    
                    var currentQuantity = 0
                    
                    let predicate = NSPredicate(format: "user == %@  AND type == %@", user!,ResultObjectType.Mg.rawValue)
                    let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as [Cart]
                    for cart in array {
                        context.deleteObject(cart)
                    }
                    
                    var error: NSError? = nil
                    context.save(&error)
                    
                    for shoppingCartProduct in itemsInShoppingCart {
                        
                        
                        var carProduct : Cart!
                        var carProductItem : Product!
                        let upc = shoppingCartProduct["upc"] as NSString
                        let quantity = shoppingCartProduct["quantity"] as NSString
                        let desc = shoppingCartProduct["description"] as NSString
                        let price = shoppingCartProduct["price"] as NSString
                        var baseprice = ""
                        if  let base = shoppingCartProduct["basePrice"] as? NSString {
                            baseprice = base
                        }
                        if  let base = shoppingCartProduct["basePrice"] as? NSNumber {
                            baseprice = base.stringValue
                        }
                        var iva = ""
                        if  let ivabase = shoppingCartProduct["ivaAmount"] as? NSString {
                            iva = ivabase
                        }
                        if  let ivabase = shoppingCartProduct["ivaAmount"] as? NSNumber {
                            iva = ivabase.stringValue
                        }
                        
                        
                        var imageUrl = ""
                        if let images = shoppingCartProduct["imageUrl"] as? NSArray {
                            imageUrl = images[0] as NSString
                        }
                        
                        carProduct = NSEntityDescription.insertNewObjectForEntityForName("Cart" as NSString, inManagedObjectContext: context) as Cart
                        
                        carProductItem = NSEntityDescription.insertNewObjectForEntityForName("Product" as NSString, inManagedObjectContext: context) as Product
                        
                        carProductItem.upc = upc
                        carProductItem.desc = desc
                        carProductItem.price = price
                        carProductItem.iva = iva
                        carProductItem.baseprice = baseprice
                        carProductItem.img = imageUrl
                        
                        if let active = shoppingCartProduct["isActive"] as? String {
                            carProductItem.isActive = active
                        }
                        if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                            carProductItem.onHandInventory = inventory
                        }
                        if let preorderable = shoppingCartProduct["isPreorderable"] as? String {
                            carProductItem.isPreorderable = preorderable
                        }

                        carProduct.quantity = NSNumber(integer: quantity.integerValue)
                        carProduct.product = carProductItem
                        carProduct.type = ResultObjectType.Mg.rawValue
                        carProduct.user = user!
                        carProduct.status = NSNumber(integer:CartStatus.Synchronized.rawValue)
                        
                        currentQuantity += quantity.integerValue
                        
                    }
                    
                    
                    context.save(&error)
                    
                    successBlock!(resultCall)
                    ShoppingCartService.isSynchronizing  = false
                    }) { (error:NSError) -> Void in
                        if error.code == 1 {
                            
                            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                            
                            let predicate = NSPredicate(format: "type == %@",ResultObjectType.Mg.rawValue)
                            
                            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as [Cart]
                            for cart in array {
                                context.deleteObject(cart)
                            }
                            
                            successBlock!(["items":[],"subtotal":NSNumber(double: 0.0)])
                            let params = ["quantity":0]
                            //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
                        }else{
                            errorBlock!(error)
                        }
                }
                
                }, errorBlock: { (error:NSError) -> Void in
                    println("Error: \(error)")
            })
        }else{
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
        }
    }
    
    func callCoreDataService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(integer: WishlistStatus.Deleted.rawValue),ResultObjectType.Mg.rawValue)
        if UserCurrentSession.sharedInstance().userSigned != nil {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance().userSigned!,NSNumber(integer: CartStatus.Deleted.rawValue),ResultObjectType.Mg.rawValue)
        }
        var array  =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as [Cart]
        var returnDictionary = [:]
        var items : [AnyObject] = []
        var subtotal : Double = 0.0
        var iva : Double = 0.0
        var totalest : Double = 0.0
        var totalQuantity = 0
        for itemSC in array {

            
            let dictItem = ["upc":itemSC.product.upc,"description":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory]
            let price = itemSC.product.price as NSString
            let ivaprod = itemSC.product.iva as NSString
            let pricebiva = itemSC.product.baseprice as NSString
            subtotal += itemSC.quantity.doubleValue * pricebiva.doubleValue
            iva += itemSC.quantity.doubleValue * ivaprod.doubleValue
            totalest += itemSC.quantity.doubleValue * price.doubleValue
            items.append(dictItem)
            
            totalQuantity += itemSC.quantity.integerValue
        }
        

        returnDictionary = ["subtotal":NSNumber(double: subtotal),"ivaSubtotal":NSNumber(double: iva),"totalEstimado":NSNumber(double: totalest),"items":items]
        
        let params = ["quantity":totalQuantity]
    
       // NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
        if successBlock != nil {
            successBlock!(returnDictionary)
            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
        }
        
    }
    
    
    func synchronizeWebShoppingCartFromCoreData(successBlock:(() -> Void), errorBlock:((NSError) -> Void)?){
        ShoppingCartService.isSynchronizing = true
        let predicateDeleted = NSPredicate(format: "status == %@ AND type == %@", NSNumber(integer:CartStatus.Deleted.rawValue),ResultObjectType.Mg.rawValue)
        let deteted = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateDeleted!)
        if deteted.count > 0 {
            let serviceDelete = ShoppingCartDeleteProductsService()
            var arratUpcsDelete : [String] = []
            var currentItem = 0
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            for itemDeleted in deteted {
                
                itemDeleted.status = CartStatus.Synchronized.rawValue
                var error: NSError? = nil
                context.save(&error)
                
                arratUpcsDelete.append(itemDeleted.product.upc)
                
            }
            serviceDelete.callService(["parameter":arratUpcsDelete], successBlock: { (result:NSDictionary) -> Void in
                self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock)
                }, errorBlock: { (error:NSError) -> Void in
                self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock)
            })
            
        } else {
            self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock)
        }
        
    }
    
    func synchronizeUpdateWebShoppingCartFromCoreData (successBlock:(() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(integer:CartStatus.Updated.rawValue),ResultObjectType.Mg.rawValue)
        let updated = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateUpdated!)
        if updated.count > 0 {
            let serviceUpdate = ShoppingCartUpdateProductsService()
            var arrayUpcsUpdate : [AnyObject] = []
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc(itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
            }
            serviceUpdate.callService(arrayUpcsUpdate, successBlock: { (result:NSDictionary) -> Void in
                self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock)
                }, errorBlock: { (error:NSError) -> Void in
                    if error.code != -100 {
                        self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock)
                    }
            })
        } else {
            self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock)
        }

    }
    
    
    func synchronizeAddedWebShoppingCartFromCoreData (successBlock:(() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(integer:CartStatus.Created.rawValue),ResultObjectType.Mg.rawValue)
        let updated = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateUpdated!)
        if updated.count > 0 {
            let serviceUpdate = ShoppingCartAddProductsService()
            var arrayUpcsUpdate : [AnyObject] = []
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc(itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
                itemUpdated.status = CartStatus.Synchronized.rawValue
            }
            var error: NSError? = nil
            context.save(&error)
            
            serviceUpdate.callService(arrayUpcsUpdate, successBlock: { (result:NSDictionary) -> Void in
                ShoppingCartService.isSynchronizing = false
                successBlock()
                
                }, errorBlock: { (error:NSError) -> Void in
                    if error.code != -100 {
                        ShoppingCartService.isSynchronizing = false
                        successBlock()
                    }
            })
        } else {
            ShoppingCartService.isSynchronizing = false
            successBlock()
        }
        ShoppingCartService.isSynchronizing = false
        
    }
    
    
}