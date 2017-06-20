//
//  AddItemWishlistService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class AddItemWishlistService : BaseService {
    
    var mustUpdateWishList : Bool = true
    
    func buildParams(_ UPC:String,quantity:String,comments:String,desc:String,imageurl:String,price:String,isActive:String,onHandInventory:String,isPreorderable:String,category: String,sellerId:String?,sellerName: String?,offerId:String?) -> [[String:Any]] {
        
        var params = ["comments":comments,"quantity":quantity,"upc":UPC,"desc":desc,"imageURL":imageurl,"price":price,"isActive":isActive,"isPreordeable":isPreorderable,"onHandInventory":onHandInventory,"category":category]
        if sellerId != nil {
            params["sellerId"] = sellerId
        }
        
        if sellerName != nil {
            params["sellerName"] = sellerName
        }
        
        if offerId != nil {
           params["offerId"] = offerId
        }
        
        return [params]
    }
    
    func callService(_ UPC:String,quantity:String,comments:String,desc:String,imageurl:String,price:String,isActive:String,onHandInventory:String,isPreorderable:String,category:String,sellerId:String?,sellerName: String?,offerId:String?,successBlock: (([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(buildParams(UPC, quantity: quantity, comments: comments,desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable,category:category,sellerId: sellerId,sellerName: sellerName,offerId: offerId),mustUpdateWishList:true,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(_ UPC:String,quantity:String,comments:String,desc:String,imageurl:String,price:String,isActive:String,onHandInventory:String,isPreorderable:String,category:String,mustUpdateWishList:Bool,sellerId:String?,sellerName: String?,offerId:String?,successBlock: (([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(buildParams(UPC, quantity: quantity, comments: comments,desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable,category:category,sellerId: sellerId,sellerName: sellerName,offerId: offerId),mustUpdateWishList:mustUpdateWishList,successBlock: successBlock, errorBlock: errorBlock)
    }

    
    
    
    func builParamSvc(_ upc:String,quantity:String,comments:String) -> [String:Any] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }

    
    func callService(_ params:[[String:Any]], mustUpdateWishList:Bool, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        if UserCurrentSession.hasLoggedUser() {
            //Se actualza la lista del usuario
            var itemsSvc : [[String:Any]] = []
            for itemSvc in params {
                let upc = itemSvc["upc"] as! String
                let quantity = itemSvc["quantity"] as! String
                itemsSvc.append(self.builParamSvc(upc,quantity:quantity,comments:""))
            }
            self.callPOSTService(itemsSvc, successBlock: { (resultCall:[String:Any]) -> Void in
                if mustUpdateWishList {
                    let serviceWish = UserWishlistService()
                    serviceWish.callService({ (wishlist:[String:Any]) -> Void in
                        successBlock!([:])
                        }, errorBlock: { (error:NSError) -> Void in
                            successBlock!([:])
                    })
                } else {
                    successBlock!([:])
                }
                }) { (error:NSError) -> Void in
                    errorBlock!(error)
            }
        } else {
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock)
        }
    }
    
    func callCoreDataService(_ params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for product in params as! [[String:Any]] {
            //Se actualza la lista del usuario
            
            let serviceWish = UserWishlistService()
            serviceWish.callService({ (wishlist:[String:Any]) -> Void in

                }, errorBlock: { (error:NSError) -> Void in
            })
            var wishlistProduct : Wishlist
            var predicate = NSPredicate(format: "product.upc == %@ && user == nil",product["upc"] as! NSString)
            if UserCurrentSession.hasLoggedUser() {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! NSString,UserCurrentSession.sharedInstance.userSigned!)
            }
            let array : [Wishlist] =  self.retrieve("Wishlist",sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]
            if array.count == 0 {
                wishlistProduct = NSEntityDescription.insertNewObject(forEntityName: "Wishlist", into: context) as! Wishlist
                let productBD =  NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
                wishlistProduct.product = productBD
            }else{
                wishlistProduct = array[0]
            }
            
            if let sellerId = product["sellerId"] as? String {
                wishlistProduct.product.sellerId = sellerId
            }
            
            if let sellerName = product["sellerName"] as? String {
                wishlistProduct.product.sellerName = sellerName
            }
            
            if let offerId = product["offerId"] as? String {
                wishlistProduct.product.offerId = offerId
            }
            
            wishlistProduct.product.upc = product["upc"] as! String
            wishlistProduct.product.price = product["price"] as! NSString
            wishlistProduct.product.desc = product["desc"] as! String
            wishlistProduct.product.img = product["imageURL"] as! String
            
            wishlistProduct.product.isActive = product["isActive"] as! String
            wishlistProduct.product.isPreorderable = product["isPreordeable"] as! String
            wishlistProduct.product.onHandInventory = product["onHandInventory"] as! String
            wishlistProduct.product.department = product["category"] as! String
            
            wishlistProduct.status = NSNumber(value: WishlistStatus.created.rawValue as Int)
            if UserCurrentSession.hasLoggedUser() {
                wishlistProduct.user  = UserCurrentSession.sharedInstance.userSigned!
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
    }

}
