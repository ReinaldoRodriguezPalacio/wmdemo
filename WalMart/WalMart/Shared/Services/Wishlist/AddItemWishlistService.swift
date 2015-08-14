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
    
    func buildParams(UPC:String,quantity:String,comments:String,desc:String,imageurl:String,price:String,isActive:String,onHandInventory:String,isPreorderable:String) -> NSArray {
        return [["comments":comments,"quantity":quantity,"upc":UPC,"desc":desc,"imageURL":imageurl,"price":price,"isActive":isActive,"isPreordeable":isPreorderable,"onHandInventory":onHandInventory]]
    }
    
    func callService(UPC:String,quantity:String,comments:String,desc:String,imageurl:String,price:String,isActive:String,onHandInventory:String,isPreorderable:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(buildParams(UPC, quantity: quantity, comments: comments,desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable),mustUpdateWishList:true,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(UPC:String,quantity:String,comments:String,desc:String,imageurl:String,price:String,isActive:String,onHandInventory:String,isPreorderable:String,mustUpdateWishList:Bool,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(buildParams(UPC, quantity: quantity, comments: comments,desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable),mustUpdateWishList:mustUpdateWishList,successBlock: successBlock, errorBlock: errorBlock)
    }

    
    
    
    func builParamSvc(upc:String,quantity:String,comments:String) -> [String:AnyObject] {
        return ["comments":comments,"quantity":quantity,"upc":upc]
    }

    
    func callService(params:NSArray, mustUpdateWishList:Bool, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        if UserCurrentSession.sharedInstance().userSigned != nil {
            //Se actualza la lista del usuario
            var itemsSvc : [[String:AnyObject]] = []
            for itemSvc in params as NSArray {
                let upc = itemSvc["upc"] as! String
                let quantity = itemSvc["quantity"] as! String
                itemsSvc.append(self.builParamSvc(upc,quantity:quantity,comments:""))
            }
            self.callPOSTService(itemsSvc, successBlock: { (resultCall:NSDictionary) -> Void in
                if mustUpdateWishList {
                    let serviceWish = UserWishlistService()
                    serviceWish.callService({ (wishlist:NSDictionary) -> Void in
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
    
    func callCoreDataService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for product in params as! NSArray {
            //Se actualza la lista del usuario
            
            let serviceWish = UserWishlistService()
            serviceWish.callService({ (wishlist:NSDictionary) -> Void in

                }, errorBlock: { (error:NSError) -> Void in
            })
            var wishlistProduct : Wishlist
            var predicate = NSPredicate(format: "product.upc == %@ && user == nil",product["upc"] as! NSString)
            if UserCurrentSession.sharedInstance().userSigned != nil {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! NSString,UserCurrentSession.sharedInstance().userSigned!)
            }
            let array : [Wishlist] =  self.retrieve("Wishlist",sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]
            if array.count == 0 {
                wishlistProduct = NSEntityDescription.insertNewObjectForEntityForName("Wishlist", inManagedObjectContext: context) as! Wishlist
                var productBD =  NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
                wishlistProduct.product = productBD
            }else{
                wishlistProduct = array[0]
            }

            wishlistProduct.product.upc = product["upc"] as! String
            wishlistProduct.product.price = product["price"] as! String
            wishlistProduct.product.desc = product["desc"] as! String
            wishlistProduct.product.img = product["imageURL"] as! String
            
            wishlistProduct.product.isActive = product["isActive"] as! String
            wishlistProduct.product.isPreorderable = product["isPreordeable"] as! String
            wishlistProduct.product.onHandInventory = product["onHandInventory"] as! String
            
            wishlistProduct.status = NSNumber(integer: WishlistStatus.Created.rawValue)
            if UserCurrentSession.sharedInstance().userSigned != nil {
                wishlistProduct.user  = UserCurrentSession.sharedInstance().userSigned!
            }
        }
        var error: NSError? = nil
        context.save(&error)
        
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
    }

}