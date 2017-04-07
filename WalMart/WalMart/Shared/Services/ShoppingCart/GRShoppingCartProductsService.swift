//
//  GRShoppingCartProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRShoppingCartProductsService : BaseService {
    
    func callService(requestParams params:AnyObject, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //if !ShoppingCartService.isSynchronizing {
        if UserCurrentSession.hasLoggedUser() {
            synchronizeWebShoppingCartFromCoreData({ () -> Void in
                self.callGETService(params,
                                    successBlock: { (resultCall:[String:Any]) -> Void in
                                        
                                        
                                        let itemsInShoppingCart =  resultCall["items"] as! [[String:Any]]
                                        
                                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                                        
                                        
                                        if UserCurrentSession.sharedInstance.userSigned == nil {
                                            return
                                        }
                                        let user = UserCurrentSession.sharedInstance.userSigned
                                        
                                        //var currentQuantity = 0
                                        
                                        let predicate = NSPredicate(format: "user == %@ AND type == %@", user!,ResultObjectType.Groceries.rawValue)
                                        let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                                        for cart in array {
                                            context.delete(cart)
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
                                            if let images = shoppingCartProduct["imageUrl"] as? [[String:Any]] {
                                                imageUrl = images[0] as! String
                                            }
                                            
                                            if let imagestr = shoppingCartProduct["imageUrl"] as? String {
                                                imageUrl = imagestr
                                            }
                                            
                                            
                                            
                                            carProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
                                            
                                            carProductItem = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
                                            
                                            carProductItem.upc = upc
                                            carProductItem.desc = desc
                                            carProductItem.price = price as NSString
                                            carProductItem.baseprice = baseprice
                                            carProductItem.img = imageUrl
                                            if let pesable = shoppingCartProduct["type"] as?  NSString {
                                                carProductItem.type =  NSNumber(value: pesable.integerValue as Int)
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
                                                carProduct.note = comment.trimmingCharacters(in: CharacterSet.whitespaces)
                                            }
                                            
                                            carProduct.quantity = NSNumber(value: quantity as Int)
                                            carProduct.product = carProductItem
                                            carProduct.user = user!
                                            carProduct.type = ResultObjectType.Groceries.rawValue
                                            carProduct.status = NSNumber(value: CartStatus.synchronized.rawValue as Int)
                                            
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
            callCoreDataService(params as! [String:Any],successBlock:successBlock, errorBlock:errorBlock )
        }
        
        //}
    }
    
    func callCoreDataService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int),ResultObjectType.Groceries.rawValue)
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance.userSigned!,NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Groceries.rawValue)
        }
        var arrayUPCQuantity : [[String:String]] = []
        let array  =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        let service = GRProductsByUPCService()
        for item in array {
            arrayUPCQuantity.append(service.buildParamService(item.product.upc, quantity: item.quantity.stringValue))
        }
        
        service.callService(requestParams: arrayUPCQuantity as AnyObject, successBlock: { (response:[String:Any]) -> Void in
            print("")
            self.saveItemsAndSuccess(arrayUPCQuantity,resultCall: response,successBlock: successBlock)
        }) { (error:NSError) -> Void in
            print("")
            errorBlock?(error)
        }
        
    }
    
    
    func synchronizeWebShoppingCartFromCoreData(_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?){
        ShoppingCartService.isSynchronizing = true
        let predicateDeleted = NSPredicate(format: "status == %@  AND type == %@", NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Groceries.rawValue)
        let deteted = UserCurrentSession.sharedInstance.coreDataShoppingCart(predicateDeleted)
        if deteted.count > 0 {
            let serviceDelete = GRShoppingCartDeleteProductsService()
            //var arratUpcsDelete : [String] = []
            var currentItem = 0
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            for itemDeleted in deteted {
                currentItem += 1
                
                itemDeleted.status = NSNumber(value:CartStatus.synchronized.rawValue)
                do {
                    try context.save()
                } catch let error1 as NSError {
                    print(error1.description)
                }
                
                //arratUpcsDelete.append(itemDeleted.product.upc)
                if currentItem == deteted.count {
                    serviceDelete.callService(requestParams: ["parameter":[itemDeleted.product.upc]], successBlock: { (result:[String:Any]) -> Void in
                        self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
                        
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
    
    func synchronizeUpdateWebShoppingCartFromCoreData (_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(value: CartStatus.updated.rawValue as Int),ResultObjectType.Groceries.rawValue)
        let updated = Array(UserCurrentSession.sharedInstance.userSigned!.productsInCart.filtered(using: predicateUpdated)) as! [Cart]
        if updated.count > 0 {
            print("synchronizeUpdateWebShoppingCartFromCoreData")
            
        } else {
            self.synchronizeAddedWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
        }
        
    }
    
    
    func synchronizeAddedWebShoppingCartFromCoreData (_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(value: CartStatus.created.rawValue as Int),ResultObjectType.Groceries.rawValue)
        let updated = UserCurrentSession.sharedInstance.coreDataShoppingCart(predicateUpdated)
        if updated.count > 0 {
            
            
            let serviceUpdate = GRShoppingCartAddProductsService()
            
            
            var arrayUpcsUpdate : [Any] = []
            for itemUpdated in updated {
                let ntVal = itemUpdated.note != nil ? itemUpdated.note! : ""
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc(itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ntVal))
            }
            
            
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            for itemUpdated in updated {
                itemUpdated.status = NSNumber(value:CartStatus.synchronized.rawValue)
            }
            do {
                try context.save()
            } catch let error1 as NSError {
                print(error1.description)
            }
            
            print(arrayUpcsUpdate)
            
            serviceUpdate.callService(requestParams: arrayUpcsUpdate as AnyObject, successBlock: { (result:[String:Any]) -> Void in
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
    
    
    
    func saveItemsAndSuccess(_ params:[[String:String]],resultCall:[String:Any], successBlock:(([String:Any]) -> Void)?) {
        let itemsInShoppingCart = resultCall["items"] != nil ? resultCall["items"] as? [[String:Any]] : []
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //let user = UserCurrentSession.sharedInstance.userSigned
        
        //var currentQuantity = 0
        //var error: NSError? = nil
        
        let predicate = NSPredicate(format: "user == nil AND type == %@",ResultObjectType.Groceries.rawValue)
        let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        
        var resultServiceCall : [String:Any] = [:]
        var resultItems : [[String:Any]] = []
        
        for shoppingCartProduct in itemsInShoppingCart! {
            
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
            if let images = shoppingCartProduct["imageUrl"] as? [[String:Any]] {
                imageUrl = images[0] as! String
            }
            
            if let imagestr = shoppingCartProduct["imageUrl"] as? String {
                imageUrl = imagestr
            }
            
            let cartResult = array.filter{$0.product.upc == upc}
            if cartResult.count == 0 {
                carProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart" as String, into: context) as! Cart
            }else {
                carProduct = cartResult[0]
            }
            
            carProductItem = NSEntityDescription.insertNewObject(forEntityName: "Product" as String, into: context) as! Product
            
            let filtredByUpc = params.filter {$0["upc"] == upc}
            if filtredByUpc.count > 0 {
                let paramUse = filtredByUpc[0] as [String:String]
                let quantity = paramUse["quantity"]
                carProduct.quantity = NSNumber(value: Int(quantity!)! as Int)
                var newItemQ = shoppingCartProduct
                newItemQ["quantity" ] = quantity
                newItemQ["comments"] = carProduct.note
                resultItems.append(newItemQ )
            }
            
            carProductItem.upc = upc
            carProductItem.desc = desc
            carProductItem.price = price as NSString
            carProductItem.baseprice = baseprice
            carProductItem.img = imageUrl
            if let pesable = shoppingCartProduct["type"] as?  NSString {
                carProductItem.type = NSNumber(value: pesable.integerValue as Int) 
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
            
            carProduct.product = carProductItem
            carProduct.type = ResultObjectType.Groceries.rawValue
            
        }
        
        resultServiceCall["items"] = resultItems as AnyObject?
        resultServiceCall["saving"] = resultCall["saving"]
        
        do {
            try context.save()
        } catch let error1 as NSError {
            print(error1.description)
            
        }
        
        
        successBlock?(resultServiceCall as [String:Any])
    }
    
}
