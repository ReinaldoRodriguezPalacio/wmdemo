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
    
    func callService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !ShoppingCartService.isSynchronizing {
        if UserCurrentSession.hasLoggedUser() {
            synchronizeWebShoppingCartFromCoreData({ () -> Void in
                self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
                    
                   // let itemsInShoppingCart =  resultCall["items"] as! NSArray
                    
                    //println("Items in shoppingCart: \(resultCall)")
                    //self.saveItemsAndSuccess( resultCall["responseObject"] as! NSDictionary)
                    
                    self.saveItemsAndSuccess([],resultCall: resultCall["responseObject"] as! NSDictionary,successBlock: nil)

                    let responseObj = resultCall["responseObject"] as! NSDictionary
                    successBlock!(responseObj["order"] as! NSDictionary)
                    
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
                        }else{
                            errorBlock!(error)
                        }
                }
                
                }, errorBlock: { (error:NSError) -> Void in
                    print("Error: \(error)")
            })
        }else{
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
        }
    }
    
    func callCoreDataService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance().userSigned!,NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        }
        let array  =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        var returnDictionary = [:]
        var items : [AnyObject] = []
        var subtotal : Double = 0.0
        var iva : Double = 0.0
        var totalest : Double = 0.0
        var totalQuantity = 0
        var order = ""
        for itemSC in array {
            
            //let dictItem = ["upc":itemSC.product.upc,"description":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory]
            
            let dictItem = ["productId":itemSC.product.upc,"productDisplayName":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory,"isPreorderable":itemSC.product.isPreorderable,"category": itemSC.product.department, "currencyCode" :"MXN" ,"orderedQtyWeight":itemSC.product.orderedQtyWeight, "isWeighable":itemSC.product.isWeighable, "commerceItemId": itemSC.product.commerceItemId, "catalogRefId": itemSC.product.catalogRefId]
            
            let price = itemSC.product.price as NSString
            let ivaprod = itemSC.product.iva as NSString
            let pricebiva = itemSC.product.baseprice as NSString
            subtotal += itemSC.quantity.doubleValue * pricebiva.doubleValue
            iva += itemSC.quantity.doubleValue * ivaprod.doubleValue
            totalest += itemSC.quantity.doubleValue * price.doubleValue
            items.append(dictItem)
            
            totalQuantity += itemSC.quantity.intValue
            
            order = itemSC.orderId!
        }
        
        
        returnDictionary = ["total": totalQuantity,"orderId":order,"totalCommerceItemCount":array.count,"commerceItems":array]
        
        //let params = ["quantity":totalQuantity]
        
        // NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
        if successBlock != nil {
            successBlock!(returnDictionary as NSDictionary)
            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
        }
    }
    
    
    func saveItemsAndSuccess(_ params:[[String:String]],resultCall:NSDictionary, successBlock:((NSDictionary) -> Void)?) {
       
        let itemsInShoppingCart = resultCall["order"] as! NSDictionary
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let user = UserCurrentSession.sharedInstance().userSigned
        
        var currentQuantity = 0
        var  predicate : NSPredicate
        if user != nil {
            predicate = NSPredicate(format: "user == %@  AND type == %@", user!,ResultObjectType.Mg.rawValue)
        }else {
            predicate = NSPredicate(format: "type == %@", ResultObjectType.Mg.rawValue)
        }
        
        let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        for cart in array {
            context.delete(cart)
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            fatalError()
        }
        
         var resultServiceCall : [String:AnyObject] = [:]
        
        let orderId = itemsInShoppingCart["orderId"] as? NSString
        
        let commerceItems = itemsInShoppingCart["commerceItems"] as! NSArray
        
        if itemsInShoppingCart.count > 1 {
            for indx in 0 ..< commerceItems.count  {
            let shoppingCartProduct = commerceItems[indx] as! NSDictionary
            
            var carProduct : Cart!
            var carProductItem : Product!
            if let upc = shoppingCartProduct["productId"] as? String {
                
            if let commerceItemId = shoppingCartProduct["commerceItemId"] as? String {

                    //let quantity = shoppingCartProduct["quantity"] as! NSNumber
                var quantiValue = 0
                if let quantity = shoppingCartProduct["quantity"] as? NSNumber {
                    quantiValue = quantity.intValue
                }
            
                let desc = shoppingCartProduct["productDisplayName"] as! String
                var price = "" //shoppingCartProduct["price"] as! String
                if  let priceValue = shoppingCartProduct["price"] as? NSNumber {
                    price = priceValue.stringValue
                }
            
                var baseprice = ""
                var iva = ""
                if let priceInfo = shoppingCartProduct["priceInfo"] as? NSDictionary {
                    if  let base = priceInfo["amount"] as? String {
                        baseprice = base
                    }
                    if  let base = priceInfo["amount"] as? NSNumber {
                        baseprice = base.stringValue
                    }
                
                    if  let ivabase = priceInfo["savingsAmount"] as? String {
                        iva = ivabase
                    }
                    if  let ivabase = priceInfo["savingsAmount"] as? NSNumber {
                        iva = ivabase.stringValue
                    }
                }
           
                var department = ""
                if  let departmentBase = shoppingCartProduct["department"] as? String {
                    department = departmentBase
                }
                var comments = ""
                if let commentBase = shoppingCartProduct["comments"] as? String {
                    comments = commentBase
                }
                
                var orderedQtyWeight = 0
                if let orderedQtyWeightBase = shoppingCartProduct["orderedQtyWeight"] as? NSNumber {
                    orderedQtyWeight = orderedQtyWeightBase.intValue
                }
                
                var isWeighable = 0
                if let isWeighableBase = shoppingCartProduct["isWeighable"] as? NSNumber {
                    isWeighable = isWeighableBase.intValue
                }
                
                var catalogRefId = ""
                if let catalogRefIdBase = shoppingCartProduct["catalogRefId"] as? NSString {
                    catalogRefId = catalogRefIdBase as String
                }

                
                let equivalenceByPiece = ""
                let promoDescription = ""
                let saving = ""
                let stock = true
                let idLine = ""
                var nameLine = ""
                /*if let nameLineBase = shoppingCartProduct["fineContent"] as? AnyObject {
                 nameLine = (nameLineBase["fineLineName"] as? String)!
                 }*/
            
                var imageUrl = ""
                if let images = shoppingCartProduct["imageUrl"] as? NSArray {
                    imageUrl = images[0] as! String
                }
            
                carProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
            
                carProductItem = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
            
                carProduct.orderId = orderId as? String
                
                carProductItem.upc = upc
                carProductItem.commerceItemId = commerceItemId
                carProductItem.orderedQtyWeight = NSNumber(orderedQtyWeight)
                carProductItem.isWeighable = NSNumber(isWeighable)
                carProductItem.catalogRefId = catalogRefId
                carProductItem.desc = desc
                carProductItem.price = price as NSString
                carProductItem.iva = iva
                carProductItem.baseprice = baseprice
                carProductItem.img = imageUrl
                carProductItem.department = department
                //New items
                carProductItem.comments = comments
                carProductItem.equivalenceByPiece = equivalenceByPiece
                carProductItem.promoDescription = promoDescription
                carProductItem.saving = saving
                carProductItem.stock = stock
                //carProductItem.idLine = idLine
                carProductItem.nameLine = nameLine
                //
            
                if let active = shoppingCartProduct["isActive"] as? String {
                    carProductItem.isActive = active
                }
                if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                    carProductItem.onHandInventory = inventory
                }
                if let preorderable = shoppingCartProduct["isPreorderable"] as? String {
                    carProductItem.isPreorderable = preorderable
                }
            
                carProduct.quantity = NSNumber(value: quantiValue as Int)
                carProduct.product = carProductItem
                carProduct.type = ResultObjectType.Mg.rawValue
                if user != nil {
                    carProduct.user = user!
                }
                carProduct.status = NSNumber(value: CartStatus.synchronized.rawValue as Int)
                currentQuantity += quantiValue
            }
                
            }
        }
            
        successBlock?(resultServiceCall as NSDictionary)

    }
    
        /*for shoppingCartProduct in itemsInShoppingCart {
         
        }*/
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            fatalError()
        }
    }
    
    
    
    func synchronizeWebShoppingCartFromCoreData(_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?){
        ShoppingCartService.isSynchronizing = true
        let predicateDeleted = NSPredicate(format: "status == %@ AND type == %@", NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        let deteted = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateDeleted)
        if deteted.count > 0 {
            let serviceDelete = ShoppingCartDeleteProductsService()
            var arratUpcsDelete : [String] = []
            //var currentItem = 0
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            for itemDeleted in deteted {
                itemDeleted.status = CartStatus.synchronized.rawValue
                do {
                    try context.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                arratUpcsDelete.append(itemDeleted.product.commerceItemId)
            }
            
            let dic = serviceDelete.builParamsMultiple(arratUpcsDelete)
            serviceDelete.callService(dic, successBlock: { (result:NSDictionary) -> Void in
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
        let updated = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateUpdated)
        if updated.count > 0 {
            let serviceUpdate = ShoppingCartUpdateProductsService()
            var arrayUpcsUpdate : [AnyObject] = []
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc("", upc:itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
            }
            serviceUpdate.callService(arrayUpcsUpdate, successBlock: { (result:NSDictionary) -> Void in
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
        let updated = UserCurrentSession.sharedInstance().coreDataShoppingCart(predicateUpdated)
        if updated.count > 0 {
            let serviceUpdate = ShoppingCartAddProductsService()
            var arrayUpcsUpdate : [AnyObject] = []
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            for itemUpdated in updated {
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc("", upc:itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
                itemUpdated.status = CartStatus.synchronized.rawValue
            }
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
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
