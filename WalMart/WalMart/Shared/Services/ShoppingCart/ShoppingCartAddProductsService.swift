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


    class func maxItemsInShoppingCart(_ useDefault:Bool, onHandInventory:Int) -> Int {
        return useDefault ? ShoppingCartParams.maxProducts : onHandInventory
    }
    
    
    func builParam(_ skuId:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String) -> [String:Any] {
        return ["comments":comments as AnyObject,"quantity":quantity as AnyObject,"skuId":skuId as AnyObject,"upc":upc as AnyObject,"desc":desc as AnyObject,"price":price as AnyObject,"imageURL":imageURL as AnyObject,"onHandInventory":onHandInventory,"isPreorderable":isPreorderable]
    }
    
    func builParam(_ skuId:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,pesable:NSString,isPreorderable:String,category:String) -> [String:Any] {
        return ["comments":comments as AnyObject,"quantity":quantity as AnyObject,"skuId":skuId as AnyObject,"upc":upc as AnyObject,"desc":desc as AnyObject,"price":price as AnyObject,"imageURL":imageURL as AnyObject,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable,"isPreorderable":isPreorderable,"category":category]
    }
    
    func builParams(_ skuId:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,pesable:NSString,parameter:[String:Any]?) -> [[String:Any]] {
        if useSignals && parameter != nil{
            parameterSend = parameter! as AnyObject?
            return [["comments":comments as AnyObject,"quantity":quantity as AnyObject,"skuId":skuId as AnyObject,"upc":upc as AnyObject,"desc":desc as AnyObject,"price":price as AnyObject,"imageURL":imageURL as AnyObject,"onHandInventory":onHandInventory,"pesable":pesable,"isPreorderable":isPreorderable,"category":category,"parameter":parameter!]]
        }
        return [["comments":comments as AnyObject,"quantity":quantity as AnyObject,"skuId":skuId as AnyObject,"upc":upc as AnyObject,"desc":desc as AnyObject,"price":price as AnyObject,"imageURL":imageURL as AnyObject,"onHandInventory":onHandInventory,"pesable":pesable,"isPreorderable":isPreorderable,"category":category]]
    }
    
    func builParamSvc(_ skuId:String,upc:String,quantity:String,comments:String) -> NSDictionary {
        //return ["comments":comments,"quantity":quantity,"upc":upc]
        return ["catalogRefIds": skuId, "productId": upc, "quantity": quantity, "orderedUOM": "EA", "itemComment": "EA","orderedQTYWeight": "6"]
    }
    
    func builParam(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,isPreorderable:String) -> [String:Any] {
        return ["comments":comments as AnyObject,"quantity":quantity as AnyObject,"upc":upc as AnyObject,"desc":desc as AnyObject,"price":price as AnyObject,"imageURL":imageURL as AnyObject,"onHandInventory":onHandInventory,"wishlist":wishlist as AnyObject]
    }
    
    func buildProductObject(_ upcsParams:NSDictionary) -> AnyObject {
        
        if useSignals  && self.parameterSend != nil {
            return   ["items":upcsParams,"parameter":self.parameterSend!]
            
        }
        return upcsParams
    }

    
    func callService(_ skuid:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String,pesable:NSString,parameter:[String:Any]?,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(builParams(skuid,upc:upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,category:category, pesable:pesable, parameter:parameter) as AnyObject, successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(_ skuid:String,upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,isPreorderable:String,category:String, pesable:NSString ,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(skuid,upc:upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,isPreorderable: isPreorderable,category:category,pesable:pesable,parameter: nil) as AnyObject, successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(_ params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if UserCurrentSession.hasLoggedUser() {
            
            //var itemsSvc : [String:Any]
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
                        UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                            successBlock!(resultCall)
                        })
                    }else{
                        
                        successBlock!(resultCall)
                    }
                    }) { (error:NSError) -> Void in
                        errorBlock!(error)
                }
            } else {
            
                let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upcSend)
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
                            UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                                UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                                successBlock!([:])
                            })
                        }else{
                            successBlock!([:])
                        }
                        }) { (error:NSError) -> Void in
                            if (UserCurrentSession.sharedInstance.hasPreorderable()) {// is preorderable
                                //let items  = UserCurrentSession.sharedInstance.itemsMG!["items"] as? NSArray
                                let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
                                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                                errorBlock?(error)
                                return
                            } else {
                                for product in params as! NSArray {
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
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    func callCoreDataService(_ params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !self.isInCart {
            if (UserCurrentSession.sharedInstance.hasPreorderable()) {// is preorderable
                //let items  = UserCurrentSession.sharedInstance.itemsMG!["items"] as? NSArray
                let message = NSLocalizedString("mg.preorderanble.item",  comment: "")
                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                errorBlock?(error)
                return
            } else {
                for product in params as! NSArray {
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
        
        for product in params as! NSArray {
            
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
            cartProduct.quantity = NSNumber(value: quantityStr.integerValue as Int)
            
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
            cartProduct.product.type = NSNumber(pesable.integerValue)
            if let comment  = product["comments"] as? NSString {
                cartProduct.note = comment.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            //
            cartProduct.status = NSNumber(value: statusForProduct() as Int)
            cartProduct.type = ResultObjectType.Mg.rawValue
            if let category = product["category"] as? String {
                cartProduct.product.department = category
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
