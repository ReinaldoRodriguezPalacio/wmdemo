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
    
    
    
    init(dictionary:NSDictionary){
        super.init()
        //self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }


    class func maxItemsInShoppingCart(useDefault:Bool, onHandInventory:Int) -> Int {
        return useDefault ? ShoppingCartParams.maxProducts : onHandInventory
    }
    
    
    func builParam(skuId:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"skuId":skuId,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable]
    }
    
    func builParam(skuId:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,pesable:NSString,isPreorderable:String,category:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"skuId":skuId,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable,"isPreorderable":isPreorderable,"category":category]
    }
    
    func builParams(skuId:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,pesable:NSString,parameter:[String:AnyObject]?) -> [[String:AnyObject]] {
        if useSignals && parameter != nil{
            parameterSend = parameter!
            return [["comments":comments,"quantity":quantity,"skuId":skuId,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"pesable":pesable,"isPreorderable":isPreorderable,"category":category,"parameter":parameter!]]
        }
        return [["comments":comments,"quantity":quantity,"skuId":skuId,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"pesable":pesable,"isPreorderable":isPreorderable,"category":category]]
    }
    
    func builParamSvc(skuId:String,upc:String,quantity:String,comments:String) -> NSDictionary {
        //return ["comments":comments,"quantity":quantity,"upc":upc]
        return ["catalogRefIds": skuId, "productId": upc, "quantity": quantity, "orderedUOM": "EA", "itemComment": "EA","orderedQTYWeight": "6"]
    }
    
    func builParam(upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,isPreorderable:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist]
    }
    
    func buildProductObject(upcsParams:NSDictionary) -> AnyObject {
        
        if useSignals  && self.parameterSend != nil {
            return   ["items":upcsParams,"parameter":self.parameterSend!]
            
        }
        return upcsParams
    }

    
    func callService(skuid:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,pesable:NSString,parameter:[String:AnyObject]?,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(builParams(skuid,upc:upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,category:category, pesable:pesable, parameter:parameter), successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(skuid:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String, pesable:NSString ,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(skuid,upc:upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,category:category,pesable:pesable,parameter: nil), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if UserCurrentSession.hasLoggedUser() {
            
            //var itemsSvc : [String:AnyObject]
            var itemsSvc : NSDictionary?
           
           
            var upcSend = ""
            for itemSvc in params as! NSArray {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                //itemsSvc.append(builParamSvc(upc,quantity:quantity,comments:"") as! [String : AnyObject])
                //Add skuId
                let skuid = itemSvc["skuId"] as! String
                itemsSvc = builParamSvc(skuid,upc:upc,quantity:quantity,comments:"")
            }
            
            if itemsSvc!.count > 1 {
                
                print("callPOSTService::")
                print(self.jsonFromObject(itemsSvc))
                self.callPOSTService(itemsSvc!, successBlock: { (resultCall:NSDictionary) -> Void in
                    
                    
                    if self.updateShoppingCart() {
                        UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
                            successBlock!(resultCall)
                        })
                    }else{
                        
                        successBlock!(resultCall)
                    }
                    }) { (error:NSError) -> Void in
                        errorBlock!(error)
                }
            } else {
            
                let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upcSend)
                if !hasUPC {
                    var send  : AnyObject?
                    if useSignals  && self.parameterSend != nil{
                        send = buildProductObject(itemsSvc!)
                    }else{
                        send = itemsSvc
                    }
                    print("ShoppingCartAddProductsService::")
                    print(self.jsonFromObject(send!))
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
                            if (UserCurrentSession.sharedInstance().hasPreorderable()) {// is preorderable
                                //let items  = UserCurrentSession.sharedInstance().itemsMG!["items"] as? NSArray
                                let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
                                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                                errorBlock?(error)
                                return
                            } else {
                                for product in params as! NSArray {
                                    if let preorderable = product["isPreorderable"] as? String {
                                        if preorderable == "true" && !UserCurrentSession.sharedInstance().isEmptyMG() {
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
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    func callCoreDataService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !self.isInCart {
            if (UserCurrentSession.sharedInstance().hasPreorderable()) {// is preorderable
                //let items  = UserCurrentSession.sharedInstance().itemsMG!["items"] as? NSArray
                let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                errorBlock?(error)
                return
            } else {
                for product in params as! NSArray {
                    if let preorderable = product["isPreorderable"] as? String {
                        if preorderable == "true" && !UserCurrentSession.sharedInstance().isEmptyMG() {
                            let message = NSLocalizedString("mg.preorderanble.item.add",  comment: "")
                            let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                            errorBlock?(error)
                            return
                        }
                    }
                }
            }
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
            //new items
            cartProduct.product.comments = "" //product["comments"] as! String
            cartProduct.product.equivalenceByPiece = "" //product["equivalenceByPiece"] as! String
            cartProduct.product.promoDescription = "" //product["onHandInventory"] as! String
            cartProduct.product.saving = "" //product["savingsAmount"] as! String
            cartProduct.product.stock = true //product["lowStock"] as! String
            //  cartProduct.product.idLine = ""
            var nameLine = "Otros"
            if let lineObj = product["line"] as? NSDictionary {
                nameLine = lineObj["name"] as! String
            }
            cartProduct.product.nameLine = nameLine
            var pesable : NSString = "0"
            if let pesableP = product["pesable"] as? String {
                pesable = pesableP
            }
            cartProduct.product.type = pesable.integerValue
            if let comment  = product["comments"] as? NSString {
                cartProduct.note = comment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            //
            cartProduct.status = NSNumber(integer: statusForProduct())
            cartProduct.type = ResultObjectType.Mg.rawValue
            if let category = product["category"] as? String {
                cartProduct.product.department = category
            }

            if UserCurrentSession.hasLoggedUser() {
                cartProduct.user  = UserCurrentSession.sharedInstance().userSigned!
            }
        }
        do {
            try context.save()
        } catch {
           print("Error saving context callCoreDataService ")
        }
    
        
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