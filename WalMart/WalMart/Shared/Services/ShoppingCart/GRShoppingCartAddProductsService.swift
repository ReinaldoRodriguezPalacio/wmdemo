//
//  GRShoppingCartAddProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRShoppingCartAddProductsService : GRBaseService {
    var useSignals = false
    var parameterSend:[String:Any]?
    
    override init() {
        super.init()
    }
    
    
    init(dictionary:[String:Any]){
        super.init()
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    func buildParams(_ quantity:String,upc:String,comments:String) -> [Any] {
        let quantityInt : Int = Int(quantity)!
        return [["quantity":quantityInt,"upc":upc,"comments":comments]]
        //return [["items":["quantity":quantityInt,"upc":upc,"comments":comments],"parameter":["eventtype":"addticart","q":"busqueda","collection": "mg","channel":"ipad"]]]
    }
    
    func builParam(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory]
    }
    
    func builParams(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,pesable:NSString,parameter:[String:Any]?) -> [[String:Any]] {
        if useSignals && parameter != nil{
            self.parameterSend  = parameter
          return [["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"pesable":pesable,"parameter":parameter!]]
            
        }
        return [["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"pesable":pesable]]
    }
    
    func builParamSvc(_ upc:String,quantity:String,comments:String) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }
    
    func builParam(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,wishlist:Bool,pesable:NSString,isPreorderable:String,category:String) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc,"desc":desc,"price":price,"imageURL":imageURL,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable,"isPreorderable":isPreorderable,"category":category]
    }
    
  
    
    func callService(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,pesable:NSString,parameter:[String:Any]?,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(requestParams: builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,pesable:pesable,parameter: parameter) as AnyObject, successBlock: successBlock, errorBlock: errorBlock)
    }
    func callCoreDataService(_ upc:String,quantity:String,comments:String,desc:String,price:String,imageURL:String,onHandInventory:NSString,pesable:NSString,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataService(builParams(upc,quantity:quantity,comments:comments,desc:desc,price:price,imageURL:imageURL,onHandInventory:onHandInventory,pesable:pesable,parameter: nil) as AnyObject, successBlock: successBlock, errorBlock: errorBlock)
    }

    func callService(_ upc:String,quantity:String,comments:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callService(requestParams: buildParams(quantity,upc:upc,comments:comments), successBlock: successBlock,errorBlock:errorBlock)
    }

    func buildParams(_ products:[Any]) -> [String:Any] {
        return ["strArrImp":products]
    }
    
    func buildProductObject(upc:String, quantity:String, comments:String) -> Any {
        return ["quantity":quantity,"upc":upc,"comments":comments]
    }
    
    func buildProductObject(_ upcsParams:[Any]) -> Any {
        
        if useSignals  && self.parameterSend != nil {
            return   ["items":upcsParams,"parameter":self.parameterSend!]
            
        }
        return upcsParams as Any
    }
    
    
    
    
    func callService(requestParams params:Any, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params as AnyObject!)
        if UserCurrentSession.hasLoggedUser() {
            var itemsSvc : [Any] = []
            var itemsSvcUpdate : [Any] = []
            
            var upcSend = ""
            for itemSvc in params as! [[String:Any]] {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                print(upcSend)
                let quantity = itemSvc["quantity"] as! String
                var  comments = ""
                if let comment  = itemSvc["comments"] as? String {
                    comments = comment
                }
               
                
                let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upcSend)
                if hasUPC{
                // update
                    itemsSvcUpdate.append(itemSvc)
                }else{
                 //Add
                     itemsSvc.append(buildProductObject(upc: upc,quantity:quantity,comments:comments))
                }
                
            }

            //Service Add
            if itemsSvc.count > 0 {
                
                var send  : Any?
                if useSignals  && self.parameterSend != nil{
                    send = buildProductObject(itemsSvc)
                }else{
                    send = itemsSvc as Any?
                }
                self.callPOSTService(send!, successBlock: { (resultCall:[String:Any]) -> Void in
                    if self.updateShoppingCart() {
                        UserCurrentSession.sharedInstance.loadGRShoppingCart({ () -> Void in
                            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                            successBlock!([:])
                        })
                    }else{
                        successBlock!([:])
                    }
                }) { (error:NSError) -> Void in
                    errorBlock!(error)
                }
            
            }
            //Service Update
            if itemsSvcUpdate.count > 0 {
                
                let svcUpdateShoppingCart = GRShoppingCartUpdateProductsService()
                BaseController.sendAnalyticsAddOrRemovetoCart(params as! [Any],isAdd: true)
                svcUpdateShoppingCart.callService(itemsSvcUpdate,updateSC:true,successBlock:successBlock, errorBlock:errorBlock )
            }

        
        } else {
             successBlock!([:])
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    
    func callCoreDataService(_ params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        //BaseController.sendAnalyticsAddOrRemovetoCart(params as! [Any], isAdd: true)
        
        for product in params as! [[String:Any]] {
            
            var cartProduct : Cart
            var predicate = NSPredicate(format: "product.upc == %@ ",product["upc"] as! NSString)
            if UserCurrentSession.hasLoggedUser() {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! NSString,UserCurrentSession.sharedInstance.userSigned!)
            }
            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
            if array.count == 0 {
                cartProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart" as String, into: context) as! Cart
                let productBD =  NSEntityDescription.insertNewObject(forEntityName: "Product" as String, into: context) as! Product
                cartProduct.product = productBD
            }else{
                cartProduct = array[0]
            }
            let quantityStr = product["quantity"] as! NSString
            cartProduct.quantity = NSNumber(value: quantityStr.integerValue as Int)
            
            print("Product in shopping cart: \(product)")

            var pesable : NSString = "0"
            if let pesableP = product["pesable"] as? NSString {
                pesable = pesableP
            }
            cartProduct.product.upc = product["upc"] as! String
            cartProduct.product.price = product["price"] as! NSString
            cartProduct.product.desc = product["desc"] as! String
            cartProduct.product.img = product["imageURL"] as! String
            cartProduct.product.onHandInventory = product["onHandInventory"] as! String
            cartProduct.product.iva = ""
            cartProduct.product.baseprice = ""
            cartProduct.product.type = NSNumber(value: pesable.integerValue)
            cartProduct.status = NSNumber(value: statusForProduct() as Int)
            cartProduct.type = ResultObjectType.Groceries.rawValue
            
            if let comment  = product["comments"] as? NSString {
                cartProduct.note = comment.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            
            if UserCurrentSession.hasLoggedUser() {
                cartProduct.user  = UserCurrentSession.sharedInstance.userSigned!
            }
        }
        do {
            try context.save()
        } catch let error1 as NSError {
            print(error1.description)
        }
        
        WishlistService.shouldupdate = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ReloadWishList.rawValue), object: nil)
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func statusForProduct() -> Int {
        return CartStatus.created.rawValue
    }
    
    func updateShoppingCart() -> Bool {
        return true
    }

    override func needsToLoginCode() -> Int {
        return -100
    }
    
    
}
