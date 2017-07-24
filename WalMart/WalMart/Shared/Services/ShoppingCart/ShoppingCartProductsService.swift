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
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        if !ShoppingCartService.isSynchronizing {
            
            if UserCurrentSession.hasLoggedUser() {
                synchronizeWebShoppingCartFromCoreData({ () -> Void in
                    self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
                        
                        //println("Items in shoppingCart: \(resultCall)")
                        
                        let itemsInShoppingCart = resultCall["items"] as! [[String:Any]]
                        
                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                        
                        let user = UserCurrentSession.sharedInstance.userSigned
                        
                        var currentQuantity = 0
                        if user != nil {
                            let predicate = NSPredicate(format: "user == %@  AND type == %@", user!,ResultObjectType.Mg.rawValue)
                            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                            for cart in array {
                                context.delete(cart)
                            }
                        }
                        
                        do {
                            try context.save()
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        } catch {
//                            fatalError()
                        }
                        
                        for shoppingCartProduct in itemsInShoppingCart {
                            
                            
                            var carProduct : Cart!
                            var carProductItem : Product!
                            guard let upc = shoppingCartProduct["upc"] as? String else{
                                continue
                            }
                            let quantity = shoppingCartProduct["quantity"] as! NSString
                            let desc = shoppingCartProduct["description"] as! String
                            let price = shoppingCartProduct["price"] as? String
                            var baseprice = ""
                            if  let base = shoppingCartProduct["basePrice"] as? String {
                                baseprice = base
                            }
                            if  let base = shoppingCartProduct["basePrice"] as? NSNumber {
                                baseprice = base.stringValue
                            }
                            var iva = ""
                            if  let ivabase = shoppingCartProduct["ivaAmount"] as? String {
                                iva = ivabase
                            }
                            if  let ivabase = shoppingCartProduct["ivaAmount"] as? NSNumber {
                                iva = ivabase.stringValue
                            }
                            var department = ""
                            if  let departmentBase = shoppingCartProduct["department"] as? String {
                                department = departmentBase
                            }
                            
                            var saving = ""
                            if  let savingValue = shoppingCartProduct["saving"] as? String {
                                saving = savingValue
                            }
                            
                            
                            var imageUrl = ""
                            if let images = shoppingCartProduct["imageUrl"] as? [Any] {
                                imageUrl = images[0] as! String
                            }
                            
                            carProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
                            carProductItem = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
                            
                            carProductItem.upc = upc
                            carProductItem.desc = desc
                            carProductItem.price = price as NSString? ?? ""
                            carProductItem.iva = iva
                            carProductItem.baseprice = baseprice
                            carProductItem.img = imageUrl
                            carProductItem.department = department
                            carProductItem.saving = saving as NSString
                            
                            if let offers = shoppingCartProduct["offers"] as? [Any] {
                                if let offer = offers.first as? [String:Any] {
                                    carProductItem.sellerId = offer["sellerId"] as? String
                                    carProductItem.sellerName = offer["name"] as? String
                                    carProductItem.offerId = offer["offerId"] as? String
                                    carProductItem.price = offer["price"] as? NSString ?? ""
                                    carProductItem.onHandInventory =  offer["onHandInventory"] as? String ?? ""
                                    carProductItem.upc = offer["offerId"] as! String
                                    carProductItem.baseprice = offer["basePrice"] as? String ?? ""
                                    carProductItem.iva = offer["ivaAmount"] as? String ?? ""
                                 }
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
                            
                            carProduct.quantity = NSNumber(value: quantity.intValue)
                            carProduct.product = carProductItem
                            carProduct.type = ResultObjectType.Mg.rawValue
                            carProduct.user = user!
                            carProduct.status = NSNumber(value: CartStatus.synchronized.rawValue as Int)
                            
                            currentQuantity += quantity.integerValue
                            
                        }
                        
                        
                        do {
                            try context.save()
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        } catch {
//                            fatalError()
                        }
                        
                        //successBlock!(resultCall)
                        self.callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
                        ShoppingCartService.isSynchronizing  = false
                    }) { (error:NSError) -> Void in
                        if error.code == 1 {
                            
                            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                            
                            let predicate = NSPredicate(format: "type == %@",ResultObjectType.Mg.rawValue)
                            
                            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                            for cart in array {
                                context.delete(cart)
                            }
                            
                            successBlock!(["items":[],"subtotal":NSNumber(value: 0.0 as Double)])
                            //let params = ["quantity":0]
                            //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
                        } else {
                            errorBlock!(error)
                        }
                    }
                    
                }, errorBlock: { (error: NSError) -> Void in
                    print("Error: \(error)")
                })
                
            } else {
                callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
            }
            
        } else {
            errorBlock!(NSError(domain: "", code: -888, userInfo: nil))
        }
        
    }
    
    func callCoreDataService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance.userSigned!,NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        }
        let array  =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        var returnDictionary:[String:Any] = [:]
        var items : [Any] = []
        var subtotal : Double = 0.0
        var iva : Double = 0.0
        var totalest : Double = 0.0
        var totalQuantity = 0
        for itemSC in array {

            
            //let dictItem = ["upc":itemSC.product.upc,"description":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory]
            
            let dictItem: [String:Any] = ["upc":itemSC.product.upc,"description":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory,"isPreorderable":itemSC.product.isPreorderable,"category": itemSC.product.department,"saving": itemSC.product.saving,"sellerId": itemSC.product.sellerId ?? "", "sellerName": itemSC.product.sellerName ?? "", "offerId": itemSC.product.offerId ?? ""]

            let price = itemSC.product.price as NSString
            let ivaprod = itemSC.product.iva as NSString
            let pricebiva = itemSC.product.baseprice as NSString
            subtotal += itemSC.quantity.doubleValue * pricebiva.doubleValue
            iva += itemSC.quantity.doubleValue * ivaprod.doubleValue
            totalest += itemSC.quantity.doubleValue * price.doubleValue
            items.append(dictItem)
            
            totalQuantity += itemSC.quantity.intValue
        }
        

        returnDictionary = ["subtotal":NSNumber(value: subtotal as Double),"ivaSubtotal":NSNumber(value: iva as Double),"totalEstimado":NSNumber(value: totalest as Double),"items":items]
        
        //let params = ["quantity":totalQuantity]
    
       // NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
        if successBlock != nil {
            successBlock!(returnDictionary)
            UserCurrentSession.sharedInstance.itemsMG = returnDictionary
            //UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
        }
        UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
    }
    
    
    func synchronizeWebShoppingCartFromCoreData(_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?){
        ShoppingCartService.isSynchronizing = true
        let predicateDeleted = NSPredicate(format: "status == %@ AND type == %@", NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        let deteted = UserCurrentSession.sharedInstance.coreDataShoppingCart(predicateDeleted)
        if deteted.count > 0 {
            let serviceDelete = ShoppingCartDeleteProductsService()
            var arratUpcsDelete : [String] = []
            //var currentItem = 0
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            var productsDelete: [[String : String]] = []
            for itemDeleted in deteted {
                
                itemDeleted.status = NSNumber(value: CartStatus.synchronized.rawValue)
                print("\(["name":"\(itemDeleted.product.desc)","id":"\(itemDeleted.product.upc)","category":"Shopping Cart","quantity":"\(itemDeleted.product.quantity)"])")
                productsDelete.append(["name":"\(itemDeleted.product.desc)","id":"\(itemDeleted.product.upc)","category":"Shopping Cart","quantity":"\(itemDeleted.product.quantity)"])

                do {
                    try context.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                arratUpcsDelete.append(itemDeleted.product.upc)
                
            }
             BaseController.sendAnalyticsAddOrRemovetoCart(productsDelete, isAdd: false)
            serviceDelete.callService(["parameter":arratUpcsDelete], successBlock: { (result:[String:Any]) -> Void in
               
                self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
                }, errorBlock: { (error:NSError) -> Void in
                self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
            })
            
        } else {
            self.synchronizeUpdateWebShoppingCartFromCoreData(successBlock,errorBlock: errorBlock)
        }
        
    }
    
    func synchronizeUpdateWebShoppingCartFromCoreData (_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(value: CartStatus.updated.rawValue as Int),ResultObjectType.Mg.rawValue)
        let updated = UserCurrentSession.sharedInstance.coreDataShoppingCart(predicateUpdated)
        if updated.count > 0 {
            let serviceUpdate = ShoppingCartUpdateProductsService()
            var arrayUpcsUpdate : [[String:Any]] = []
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc(itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
            }
            serviceUpdate.callService(arrayUpcsUpdate, successBlock: { (result:[String:Any]) -> Void in
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
    
    
    func synchronizeAddedWebShoppingCartFromCoreData (_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@  AND type == %@", NSNumber(value: CartStatus.created.rawValue as Int),ResultObjectType.Mg.rawValue)
        let updated = UserCurrentSession.sharedInstance.coreDataShoppingCart(predicateUpdated)
        if updated.count > 0 {
            let serviceUpdate = ShoppingCartAddProductsService()
            var arrayUpcsUpdate : [[String:Any]] = []
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc(itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
                itemUpdated.status = NSNumber(value: CartStatus.synchronized.rawValue)
            }
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            serviceUpdate.callService(arrayUpcsUpdate, successBlock: { (result:[String:Any]) -> Void in
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
