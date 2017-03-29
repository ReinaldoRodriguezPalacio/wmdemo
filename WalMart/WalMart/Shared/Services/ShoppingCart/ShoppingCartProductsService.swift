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
                let empty: [String:Any] = [:]
                self.callGETService(empty as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
                    
                   // let itemsInShoppingCart =  resultCall["items"] as! NSArray
                    
                    //println("Items in shoppingCart: \(resultCall)")
                    //self.saveItemsAndSuccess( resultCall["responseObject"] as! [String:Any])
                    
                    self.saveItemsAndSuccess([],resultCall: resultCall as! [String:Any],successBlock: nil)

                    //let responseObj = resultCall["responseObject"] as! [String:Any]
                    successBlock!(resultCall as! [String:Any])
                    
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
    
    func callCoreDataService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance.userSigned!,NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Mg.rawValue)
        }
        let array  =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        var returnDictionary: [String:Any] = [:]
        var items : [Any] = []
        var subtotal : Double = 0.0
        var iva : Double = 0.0
        var totalest : Double = 0.0
        var totalQuantity = 0
        var order = ""
        for itemSC in array {
            
            //let dictItem = ["upc":itemSC.product.upc,"description":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory]
            
            let dictItem = ["productId":itemSC.product.upc,"productDisplayName":itemSC.product.desc,"price":itemSC.product.price,"quantity":itemSC.quantity.stringValue,"imageUrl":[itemSC.product.img],"ivaAmount":itemSC.product.iva,"basePrice":itemSC.product.baseprice,"onHandInventory":itemSC.product.onHandInventory,"isPreorderable":itemSC.product.isPreorderable,"category": itemSC.product.department, "currencyCode" :"MXN" ,"orderedQtyWeight":itemSC.product.orderedQtyWeight, "isWeighable":itemSC.product.isWeighable, "commerceItemId": itemSC.product.commerceItemId, "catalogRefId": itemSC.product.catalogRefId] as [String : Any]
            
            let price = itemSC.product.price as NSString
            let ivaprod = itemSC.product.iva as NSString
            let pricebiva = itemSC.product.baseprice as NSString
            subtotal += itemSC.quantity.doubleValue * pricebiva.doubleValue
            iva += itemSC.quantity.doubleValue * ivaprod.doubleValue
            totalest += itemSC.quantity.doubleValue * price.doubleValue
            items.append(dictItem)
            
            totalQuantity += itemSC.quantity.intValue
            
            if let valueOrder = itemSC.orderId {
                order = itemSC.orderId!
            }
        }
        
        
        returnDictionary = ["total": totalQuantity,"orderId":order,"totalCommerceItemCount":array.count,"commerceItems":array]
        
        //let params = ["quantity":totalQuantity]
        
        // NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
        if successBlock != nil {
            successBlock!(returnDictionary as! [String:Any])
            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
        }
    }
    
    
    func saveItemsAndSuccess(_ params:[[String:String]],resultCall:[String:Any], successBlock:(([String:Any]) -> Void)?) {
       
        let itemsInShoppingCart = resultCall["priceMap"] as! [String:Any]
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let user = UserCurrentSession.sharedInstance.userSigned
        
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
        
         var resultServiceCall : [String:Any] = [:]
        
        let orderId = itemsInShoppingCart["orderId"] as? NSString
        
        if let cartDetails = resultCall["cartDetails"] as? [[String:Any]] {
            
            //let commerceItems = cartDetails
            if cartDetails.count > 1 {
                for indx in 0 ..< cartDetails.count  {
                    let shoppingCartProduct = cartDetails[indx] as? [String:Any]
                    
                    var carProduct : Cart!
                    var carProductItem : Product!
                    
                    var desc = ""
                    var commerceItemId = ""
                    if let sku = shoppingCartProduct!["sku"] as? [String:Any] {
                        desc = sku["productDisplayName"] as! String
                    }
                    if let upc = shoppingCartProduct!["skuId"] as? String {
                        
                        
                        if let commerceItemDetailsM = shoppingCartProduct!["commerceItemDetailsMap"] as? [String:Any] {
                            
                            //let quantity = shoppingCartProduct["quantity"] as! NSNumber
                            var quantiValue = 0
                            if let quantity = commerceItemDetailsM["quantity"] as? NSNumber {
                                quantiValue = quantity.intValue
                            }
                            
                            if  let commerceItemIdValue = commerceItemDetailsM["commerceItemId"] as? String {
                                commerceItemId = commerceItemIdValue
                            }
                            
                            //let desc = shoppingCartProduct["productDisplayName"] as! String
                            var price = "" //shoppingCartProduct["price"] as! String
                            if  let priceValue = shoppingCartProduct!["price"] as? NSNumber {
                                price = priceValue.stringValue
                            }
                            
                            var baseprice = ""
                            var iva = ""
                            if let priceInfo = shoppingCartProduct!["priceInfo"] as? [String:Any] {
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
                            if  let departmentBase = shoppingCartProduct!["department"] as? String {
                                department = departmentBase
                            }
                            var comments = ""
                            if let commentBase = shoppingCartProduct!["comments"] as? String {
                                comments = commentBase
                            }
                            
                            var orderedQtyWeight = 0
                            if let orderedQtyWeightBase = shoppingCartProduct!["orderedQtyWeight"] as? NSNumber {
                                orderedQtyWeight = orderedQtyWeightBase.intValue
                            }
                            
                            var isWeighable = 0
                            if let isWeighableBase = shoppingCartProduct!["isWeighable"] as? NSNumber {
                                isWeighable = isWeighableBase.intValue
                            }
                            
                            var catalogRefId = ""
                            if let catalogRefIdBase = shoppingCartProduct!["catalogRefId"] as? NSString {
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
                            if let images = shoppingCartProduct!["imageUrl"] as? [[String:Any]] {
                                imageUrl = images[0] as! String
                            }
                            
                            carProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
                            
                            carProductItem = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
                            
                            carProduct.orderId = orderId as? String
                            
                            carProductItem.upc = upc
                            carProductItem.commerceItemId = commerceItemId
                            carProductItem.orderedQtyWeight = NSNumber(value: orderedQtyWeight)
                            carProductItem.isWeighable = NSNumber(value:isWeighable)
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
                            
                            if let active = shoppingCartProduct!["isActive"] as? String {
                                carProductItem.isActive = active
                            }
                            if let inventory = shoppingCartProduct!["onHandInventory"] as? String {
                                carProductItem.onHandInventory = inventory
                            }
                            if let preorderable = shoppingCartProduct!["isPreorderable"] as? String {
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
            } else {
                print("")
            }
            
        successBlock?(resultServiceCall as [String:Any])

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
        let deteted = UserCurrentSession.sharedInstance.coreDataShoppingCart(predicateDeleted)
        if deteted.count > 0 {
            let serviceDelete = ShoppingCartDeleteProductsService()
            var arratUpcsDelete : [String] = []
            //var currentItem = 0
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            for itemDeleted in deteted {
                itemDeleted.status = NSNumber(value:CartStatus.synchronized.rawValue)
                do {
                    try context.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                arratUpcsDelete.append(itemDeleted.product.commerceItemId)
            }
            
            let dic = serviceDelete.builParamsMultiple(arratUpcsDelete)
            serviceDelete.callService(dic as [String:Any], successBlock: { (result:[String:Any]) -> Void in
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
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc("", upc:itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
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
                arrayUpcsUpdate.append(serviceUpdate.builParamSvc("", upc:itemUpdated.product.upc, quantity: itemUpdated.quantity.stringValue, comments: ""))
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
