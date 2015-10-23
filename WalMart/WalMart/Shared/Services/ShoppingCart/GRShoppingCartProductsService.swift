//
//  GRShoppingCartProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRShoppingCartProductsService : GRBaseService {

    func callService(requestParams params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //if !ShoppingCartService.isSynchronizing {
            if UserCurrentSession.hasLoggedUser() {
                synchronizeWebShoppingCartFromCoreData({ () -> Void in
                    self.callGETService(params,
                        successBlock: { (resultCall:NSDictionary) -> Void in
                            
                            
                            let itemsInShoppingCart =  resultCall["items"] as! NSArray
                            
                            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                            
                            
                            if UserCurrentSession.sharedInstance().userSigned == nil {
                                return
                            }
                            let user = UserCurrentSession.sharedInstance().userSigned
                            
                            //var currentQuantity = 0
                            
                            let predicate = NSPredicate(format: "user == %@ AND type == %@", user!,ResultObjectType.Groceries.rawValue)
                            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                            for cart in array {
                                context.deleteObject(cart)
                            }
                            
                            do {
                                try context.save()
                            } catch let error1 as NSError {
                                print(error1.description)
                            } catch {
                                fatalError()
                            }
                            
                            for shoppingCartProduct in itemsInShoppingCart {
                                
                                
                                var carProduct : Cart!
                                var carProductItem : Product!
                                let upc = shoppingCartProduct["upc"] as! String
                                let quantity = shoppingCartProduct["quantity"] as! Int
                                let desc = shoppingCartProduct["description"] as! String
                                var price = ""
                                if let priceR =  shoppingCartProduct["price"] as? NSNumber {
                                    price = "\(priceR)"
                                }
                                let baseprice = ""
                                var imageUrl = ""
                                if let images = shoppingCartProduct["imageUrl"] as? NSArray {
                                    imageUrl = images[0] as! String
                                }
                                
                                if let imagestr = shoppingCartProduct["imageUrl"] as? String {
                                    imageUrl = imagestr
                                }
                                
                                
                                
                                carProduct = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: context) as! Cart
                                
                                carProductItem = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
                                
                                carProductItem.upc = upc
                                carProductItem.desc = desc
                                carProductItem.price = price
                                carProductItem.baseprice = baseprice
                                carProductItem.img = imageUrl
                                if let pesable = shoppingCartProduct["type"] as?  NSString {
                                    carProductItem.type = NSNumber(integer:pesable.integerValue)
                                }

                                
                                if let active = shoppingCartProduct["isActive"] as? String {
                                    carProductItem.isActive = active
                                }
                                if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                                    carProductItem.onHandInventory = inventory
                                }
                                if let preorderable = shoppingCartProduct["isPreorderable"] as? String {
                                    carProductItem.isPreorderable = preorderable
                                }
                                
                                if let comment  = shoppingCartProduct["comments"] as? NSString {
                                      carProduct.note = comment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                }
                                
                                carProduct.quantity = NSNumber(integer: quantity)
                                carProduct.product = carProductItem
                                carProduct.user = user!
                                carProduct.type = ResultObjectType.Groceries.rawValue
                                carProduct.status = NSNumber(integer:CartStatus.Synchronized.rawValue)
                                
                            }
                            
                            successBlock?(resultCall)
                            return
                        },
                        errorBlock: { (error:NSError) -> Void in
                            errorBlock?(error)
                            return
                        }
                    )
                    }, errorBlock: { (error:NSError) -> Void in
                        print("Error: \(error)")
                })
            }
            else{
                callCoreDataService(params as! NSDictionary,successBlock:successBlock, errorBlock:errorBlock )
        }
    
        //}
    }
    
    func callCoreDataService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(integer: WishlistStatus.Deleted.rawValue),ResultObjectType.Groceries.rawValue)
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance().userSigned!,NSNumber(integer: CartStatus.Deleted.rawValue),ResultObjectType.Groceries.rawValue)
        }
        var arrayUPCQuantity : [[String:String]] = []
        let array  =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        let service = GRProductsByUPCService()
        for item in array {
            arrayUPCQuantity.append(service.buildParamService(item.product.upc, quantity: item.quantity.stringValue))
        }
        
        service.callService(requestParams: arrayUPCQuantity, successBlock: { (response:NSDictionary) -> Void in
            print("")
            self.saveItemsAndSuccess(arrayUPCQuantity,resultCall: response,successBlock: successBlock)
            }) { (error:NSError) -> Void in
                print("")
            errorBlock?(error)
        }
        
//        var returnDictionary = [:]
//        var items : [AnyObject] = []
//        var subtotal : Double = 0.0
//        var iva : Double = 0.0
//        var totalest : Double = 0.0
//        var totalQuantity = 0
//        for itemSC in array {
//            let type = itemSC.product.type
//            let dictItem = ["upc":itemSC.product.upc,"description":itemSC.product.desc,"price":NSNumber(double: itemSC.product.price.doubleValue),"quantity":itemSC.quantity,"imageUrl":itemSC.product.img,"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory, "comments": ( itemSC.note == nil ? "" : itemSC.note!) ,"type":"\(type)"]
//            let price = itemSC.product.price as NSString
//            let ivaprod = itemSC.product.iva as NSString
//            let pricebiva = itemSC.product.baseprice as NSString
//            subtotal += itemSC.quantity.doubleValue * pricebiva.doubleValue
//            iva += itemSC.quantity.doubleValue * ivaprod.doubleValue
//            totalest += itemSC.quantity.doubleValue * price.doubleValue
//            items.append(dictItem)
//            
//            totalQuantity += itemSC.quantity.integerValue
//        }
//        
//        
//        returnDictionary = ["subtotal":NSNumber(double: subtotal),"ivaSubtotal":NSNumber(double: iva),"totalEstimado":NSNumber(double: totalest),"items":items]
//        
//        let params = ["quantity":totalQuantity]
//        // NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
//        if successBlock != nil {
//            successBlock!(returnDictionary)
//        }
        
    }
    
    
    func synchronizeWebShoppingCartFromCoreData(successBlock:(() -> Void), errorBlock:((NSError) -> Void)?){
        ShoppingCartService.isSynchronizing = true
        let predicateDeleted = NSPredicate(format: "status == %@  AND type == %@", NSNumber(integer:CartStatus.Deleted.rawValue),ResultObjectType.Groceries.rawValue)
        let deteted = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateDeleted)
        if deteted.count > 0 {
            let serviceDelete = GRShoppingCartDeleteProductsService()
            //var arratUpcsDelete : [String] = []
            var currentItem = 0
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            for itemDeleted in deteted {
                currentItem++
                
                itemDeleted.status = CartStatus.Synchronized.rawValue
                do {
                    try context.save()
                } catch let error1 as NSError {
                    print(error1.description)
                }
                
                //arratUpcsDelete.append(itemDeleted.product.upc)
                if currentItem == deteted.count {
                    serviceDelete.callService(requestParams: ["parameter":[itemDeleted.product.upc]], successBlock: { (result:NSDictionary) -> Void in
                        self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
                        WishlistService.shouldupdate = true
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
                        
                        }, errorBlock: { (error:NSError) -> Void in
                            if error.code != -100 {
                                self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
                            }
                    })
                }else {
                    serviceDelete.callService(requestParams: ["parameter":[itemDeleted.product.upc]], successBlock: nil, errorBlock: nil)
                }
                
            }
            
        } else {
            self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
        }
        
    }
    
    func synchronizeUpdateWebShoppingCartFromCoreData (successBlock:(() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(integer:CartStatus.Updated.rawValue),ResultObjectType.Groceries.rawValue)
        let updated = Array(UserCurrentSession.sharedInstance().userSigned!.productsInCart.filteredSetUsingPredicate(predicateUpdated)) as! [Cart]
        if updated.count > 0 {
            let serviceUpdate = GRShoppingCartUpdateProductsService()
            var arrayUpcsUpdate : [AnyObject] = []
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.buildParams(itemUpdated.product.upc, upc: itemUpdated.quantity.stringValue, comments: ""))
            }
            serviceUpdate.callService(requestParams: arrayUpcsUpdate, successBlock: { (result:NSDictionary) -> Void in
                self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
                }, errorBlock: { (error:NSError) -> Void in
                    if error.code != -100 {
                        self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
                    }
            })
        } else {
            self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
        }
        
    }
    
    
    func synchronizeAddedWebShoppingCartFromCoreData (successBlock:(() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(integer:CartStatus.Created.rawValue),ResultObjectType.Groceries.rawValue)
        let updated = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateUpdated)
        if updated.count > 0 {
            
            
          let serviceUpdate = GRShoppingCartAddProductsService()
            
            
            var arrayUpcsUpdate : [AnyObject] = []
            for itemUpdated in updated {
                let ntVal = itemUpdated.note != nil ? itemUpdated.note! : ""
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc(itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ntVal))
            }
            
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            for itemUpdated in updated {
                itemUpdated.status = CartStatus.Synchronized.rawValue
            }
            do {
                try context.save()
            } catch let error1 as NSError {
                print(error1.description)
            }
            
            
            
            
            serviceUpdate.callService(requestParams: arrayUpcsUpdate, successBlock: { (result:NSDictionary) -> Void in
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
    
    
    
    func saveItemsAndSuccess(params:[[String:String]],resultCall:NSDictionary, successBlock:((NSDictionary) -> Void)?) {
        let itemsInShoppingCart =  resultCall["items"] as! NSArray
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //let user = UserCurrentSession.sharedInstance().userSigned
        
        //var currentQuantity = 0
        //var error: NSError? = nil
        
        let predicate = NSPredicate(format: "user == nil AND type == %@",ResultObjectType.Groceries.rawValue)
        let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
//        for cart in array {
//            if cart.note != "" {
//                let filtredByUpc = params.filter {$0["upc"] == cart.product.upc}
//                if filtredByUpc.count > 0 {
//                    
//                }
//            
//            }
//            context.deleteObject(cart)
//        }
//        
//        var error: NSError? = nil
//        context.save(&error)
//        
        var resultServiceCall : [String:AnyObject] = [:]
        var resultItems : [NSDictionary] = []
        
        for shoppingCartProduct in itemsInShoppingCart {
            

            var carProduct : Cart!
            var carProductItem : Product!
            let upc = shoppingCartProduct["upc"] as! String
            
            //let quantity = shoppingCartProduct["quantity"] as! Int
            let desc = shoppingCartProduct["description"] as! String
            var price = ""
            if let priceR =  shoppingCartProduct["price"] as? NSNumber {
                price = "\(priceR)"
            }
            let baseprice = ""
            var imageUrl = ""
            if let images = shoppingCartProduct["imageUrl"] as? NSArray {
                imageUrl = images[0] as! String
            }
            
            if let imagestr = shoppingCartProduct["imageUrl"] as? String {
                imageUrl = imagestr
            }
            
            let cartResult = array.filter{$0.product.upc == upc}
            if cartResult.count == 0 {
                carProduct = NSEntityDescription.insertNewObjectForEntityForName("Cart" as String, inManagedObjectContext: context) as! Cart
            }else {
                carProduct = cartResult[0]
            }
            
            
            carProductItem = NSEntityDescription.insertNewObjectForEntityForName("Product" as String, inManagedObjectContext: context) as! Product
            
            
            let filtredByUpc = params.filter {$0["upc"] == upc}
            if filtredByUpc.count > 0 {
                let paramUse = filtredByUpc[0] as [String:String]
                let quantity = paramUse["quantity"]
                carProduct.quantity = NSNumber(integer: Int(quantity!)!)
                let newItemQ = NSMutableDictionary(dictionary: shoppingCartProduct as! NSDictionary)
                newItemQ.setValue(quantity, forKey: "quantity")
                newItemQ.setValue(carProduct.note,forKey: "comments")
                resultItems.append(newItemQ )
            }

            
            carProductItem.upc = upc
            carProductItem.desc = desc
            carProductItem.price = price
            carProductItem.baseprice = baseprice
            carProductItem.img = imageUrl
            if let pesable = shoppingCartProduct["type"] as?  NSString {
                carProductItem.type = NSNumber(integer:pesable.integerValue)
            }
            
            
            if let active = shoppingCartProduct["isActive"] as? String {
                carProductItem.isActive = active
            }
            if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                carProductItem.onHandInventory = inventory
            }
            if let preorderable = shoppingCartProduct["isPreorderable"] as? String {
                carProductItem.isPreorderable = preorderable
            }
            
//            if let comment  = shoppingCartProduct["comments"] as? NSString {
//                carProduct.note = comment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//            }
            
            
            
            //carProduct.quantity = NSNumber(integer: quantity)
            carProduct.product = carProductItem
            carProduct.type = ResultObjectType.Groceries.rawValue
            
        }
        
        resultServiceCall["items"] = resultItems
        resultServiceCall["saving"] = resultCall["saving"]
        
        do {
            try context.save()
        } catch let error1 as NSError {
           print(error1.description)
            
        }

        
        successBlock?(resultServiceCall)
    }
    
}