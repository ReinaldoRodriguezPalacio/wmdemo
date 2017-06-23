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
    var isInCart: Bool = false
    override init() {
        super.init()
        //self.urlForSession = true
    }
    
    
    
    init(dictionary:[String:Any]){
        super.init()
        //self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }


    class func maxItemsInShoppingCart(_ useDefault:Bool, onHandInventory:Int) -> Int {
        return useDefault ? ShoppingCartParams.maxProducts : onHandInventory
    }
    
    
    func builParam(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable]
    }
    
    func builParams(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,parameter:[String:Any]?,sellerId:String?,sellerName: String?,offerId:String?) -> [[String:Any]] {
        
        var params: [String:Any] =  ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable,"category":category]
        
        if sellerId != nil && sellerId != "" {
            params["sellerId"] = sellerId
        }
        
        if sellerName != nil && sellerName != "" {
            params["sellerName"] = sellerName
        }
        
        if offerId != nil && offerId != ""{
            params["offerId"] = offerId
        }
        
        if useSignals && parameter != nil{
            parameterSend = parameter! as AnyObject?
            params["parameter"] = parameter!
            
            return [params]
        }
        
        return [params]
    }
    
    func builParamSvc(_ upc:String,quantity:String,comments:String) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }
    
    func builParam(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,isPreorderable:String) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist]
    }
    
    func buildProductObject(_ upcsParams:Any) -> Any {
        
        if useSignals  && self.parameterSend != nil {
            return   ["items":upcsParams,"parameter":self.parameterSend!]
            
        }
        return upcsParams
    }

    
    func callService(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,parameter:[String:Any]?,sellerId:String?,sellerName: String?,offerId:String?,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,category:category, parameter:parameter,sellerId: sellerId,sellerName: sellerName,offerId: offerId), successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,sellerId:String?,sellerName: String?,offerId:String?,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,category:category,parameter: nil,sellerId: sellerId,sellerName: sellerName,offerId: offerId), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(_ params:[[String:Any]],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        if UserCurrentSession.hasLoggedUser() {
            
            var itemsSvc : [[String:Any]] = []
            var itemsWishList : [String] = []
           
            var upcSend = ""
            for itemSvc in params {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                itemsSvc.append(builParamSvc(upc,quantity:quantity,comments:""))
                
                if  let _ = itemSvc["wishlist"] as? Bool {
                    itemsWishList.append(upc)
                }
             
            }
            if itemsSvc.count > 1 {
                
                let serviceParams = ["items": itemsSvc]
                self.callPOSTService(serviceParams, successBlock: { (resultCall:[String:Any]) -> Void in
                    
                    if self.updateShoppingCart() {
                        
                        let serviceWishDelete = DeleteItemWishlistService()
                        serviceWishDelete.callServiceWithParams(serviceWishDelete.buildParamsMultipe(itemsWishList), successBlock: { (result:[String : Any]) in
                              NotificationCenter.default.post(name: Notification.Name(rawValue: "RELOAD_WISHLIST"), object: nil)
                        }, errorBlock: { (error:NSError) in
                              print("error : \(error)")
                        })
//                        serviceWishDelete.callServiceWithParams(itemsWishList, successBlock: { (result:[String:Any]) -> Void in
//                            //Notification
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: "RELOAD_WISHLIST"), object: nil)
//                        }) { (error:NSError) -> Void in
//                            print("error : \(error)")
//                        }
                        
                        UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                            successBlock!([:])
                        })
                    }else{
                        
                        successBlock!([:])
                    }
                    }) { (error:NSError) -> Void in
                        errorBlock!(error)
                }
            } else {
                
                UserCurrentSession.sharedInstance.userHasUPCDeletedInShoppingCart(upcSend) // validate deleted product
                
                let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upcSend)
                
                if !hasUPC {
                    
                    var send: Any?
                    
                    if useSignals  && self.parameterSend != nil{
                        send = buildProductObject(itemsSvc)
                    } else {
                        send = ["items": itemsSvc]
                    }
                    
                    self.callPOSTService(send!, successBlock: { (resultCall:[String:Any]) -> Void in
                        
                        if self.updateShoppingCart() {
                            UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                                UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                                successBlock!([:])
                            })
                        } else {
                            successBlock!([:])
                        }
                        
                    }) { (error: NSError) -> Void in
                        
                        if (UserCurrentSession.sharedInstance.hasPreorderable()) { // is preorderable
                            let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
                            let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                            errorBlock?(error)
                            return
                        } else {
                            for product in params {
                                if let preorderable = product["isPreorderable"] as? String {
                                    if preorderable == "true" && !UserCurrentSession.sharedInstance.isEmptyMG() {
                                        let message = NSLocalizedString("mg.preorderanble.item.add",  comment: "")
                                        let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                                        errorBlock?(error)
                                        return
                                    }
                                }
                            }
                        }
                        
                        errorBlock!(error)
                    }
                    
                } else {
                    let svcUpdateShoppingCart = ShoppingCartUpdateProductsService()
                    svcUpdateShoppingCart.callService(params,updateSC:true,successBlock:successBlock, errorBlock:errorBlock )
                }
            }
            
        } else {
            callCoreDataService(params, successBlock: successBlock, errorBlock: errorBlock )
        }
    }
    
    func callCoreDataService(_ params:[[String:Any]],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !self.isInCart {
            if (UserCurrentSession.sharedInstance.hasPreorderable()) {// is preorderable
                //let items  = UserCurrentSession.sharedInstance.itemsMG!["items"] as? [Any]
                let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                errorBlock?(error)
                return
            } else {
                for product in params {
                    if let preorderable = product["isPreorderable"] as? String {
                        if preorderable == "true" && !UserCurrentSession.sharedInstance.isEmptyMG() {
                            let message = NSLocalizedString("mg.preorderanble.item.add",  comment: "")
                            let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                            errorBlock?(error)
                            return
                        }
                    }
                }
            }
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        for product in params {
            
            var cartProduct : Cart
            var predicate = NSPredicate(format: "product.upc == %@ ",product["upc"] as! String)
            if UserCurrentSession.hasLoggedUser() {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! String,UserCurrentSession.sharedInstance.userSigned!)
            }
            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
            if array.count == 0 {
                cartProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
                let productBD =  NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
                cartProduct.product = productBD
            }else{
                cartProduct = array[0]
            }
            let quantityStr = product["quantity"] as! NSString
            cartProduct.quantity = NSNumber(value: quantityStr.intValue)
            
            print("Product in shopping cart: \(product)")
            
            cartProduct.product.upc = product["upc"] as! String
            cartProduct.product.price = product["price"] as! NSString
            cartProduct.product.desc = product["desc"] as! String
            cartProduct.product.img = product["imageURL"] as! String
            cartProduct.product.onHandInventory = product["onHandInventory"] as! String
            cartProduct.product.iva = ""
            cartProduct.product.baseprice = ""
            cartProduct.product.isPreorderable =  product["isPreorderable"]  as? String == nil ? "false" : product["isPreorderable"] as! String
            cartProduct.status = NSNumber(value: statusForProduct() as Int)
            cartProduct.type = ResultObjectType.Mg.rawValue
            
            if let category = product["category"] as? String {
                cartProduct.product.department = category
            }
            
            if let sellerId = product["sellerId"] as? String {
                cartProduct.product.sellerId = sellerId
            }
            
            if let sellerName = product["sellerName"] as? String {
                cartProduct.product.sellerName = sellerName
            }
            
            if let offerId = product["offerId"] as? String {
                cartProduct.product.offerId = offerId
            }


            if UserCurrentSession.hasLoggedUser() {
                cartProduct.user  = UserCurrentSession.sharedInstance.userSigned!
            }
        }
        do {
            try context.save()
        } catch {
           print("Error saving context callCoreDataService ")
        }
        
        WishlistService.shouldupdate = true
        NotificationCenter.default.post(name: .reloadWishList, object: nil)
        
        if !UserCurrentSession.hasLoggedUser() {
            NotificationCenter.default.post(name: .successUpdateItemsInShoppingCart, object: nil)
        }
        
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func statusForProduct() -> Int {
        return CartStatus.created.rawValue
    }
    
    func updateShoppingCart() -> Bool {
        return true
    }

}
