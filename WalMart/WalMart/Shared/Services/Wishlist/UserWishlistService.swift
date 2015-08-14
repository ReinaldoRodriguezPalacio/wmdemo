//
//  UserWishlistService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

struct WishlistService {
    static var shouldupdate : Bool = true
}


class UserWishlistService : BaseService {
    
    let JSON_WISHLIST_RESULT = "responseObject"
    
    func callService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
       
        if UserCurrentSession.sharedInstance().userSigned != nil {
             self.synchronizeWishListFromCoreData({ () -> Void in
                self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
                    
                    
                    var itemResult = resultCall[self.JSON_WISHLIST_RESULT] as! NSDictionary
                    var itemWishList = itemResult["items"] as! [AnyObject]
                    
                    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    let user = UserCurrentSession.sharedInstance().userSigned
                    
                    let predicate = NSPredicate(format: "user == %@ ", user!)
                    let array : [Wishlist] =  (self.retrieve("Wishlist" as NSString as String,sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]) as [Wishlist]
                    for itemWishlist in array {
                        context.deleteObject(itemWishlist)
                    }
                    
                    let predicateSinUsr = NSPredicate(format: "user == nil ")
                    let arraySinUsr : [Wishlist] =  (self.retrieve("Wishlist" as NSString as String,sortBy:nil,isAscending:true,predicate:predicateSinUsr) as! [Wishlist]) as [Wishlist]
                    for itemWishlist in arraySinUsr {
                        context.deleteObject(itemWishlist)
                    }
                    
                    var error: NSError? = nil
                    context.save(&error)
                    
                    var itemsInWishlist : [AnyObject] = []
                    
                    for wishlistDicProduct in itemWishList {
                        
                        var dictWishListProduct = wishlistDicProduct as! [String:AnyObject]
                        dictWishListProduct["type"] = ResultObjectType.Mg.rawValue
                        itemsInWishlist.append(dictWishListProduct)
                        
                        var wishlistProduct : Wishlist!
                        let upc = wishlistDicProduct["upc"] as! String
                        var desc = ""
                        if let descVal = wishlistDicProduct["description"] as? NSString {
                            desc = descVal as String
                        }
                        var price = ""
                        if let priceVal = wishlistDicProduct["price"] as? NSString {
                            price = priceVal as String
                        } else {
                            continue
                        }
                        
                        var imageUrl = ""
                        if let images = wishlistDicProduct["imageUrl"] as? NSArray {
                            imageUrl = images[0] as! String
                        }
                        
                        let isActive = wishlistDicProduct["isActive"] as! String
                        let onHandInventory = wishlistDicProduct["onHandInventory"] as! String
                        
                        var isPreordeable  = "false"
                        if let preordeable  = wishlistDicProduct["isPreorderable"] as? String {
                            isPreordeable = preordeable
                        }
                        
                        wishlistProduct = NSEntityDescription.insertNewObjectForEntityForName("Wishlist" as String, inManagedObjectContext: context) as! Wishlist
                        wishlistProduct.product = NSEntityDescription.insertNewObjectForEntityForName("Product" as String, inManagedObjectContext: context) as! Product
                        wishlistProduct.product.upc = upc
                        wishlistProduct.product.desc = desc
                        wishlistProduct.product.price = price
                        wishlistProduct.product.img = imageUrl
                        wishlistProduct.product.isActive = isActive
                        wishlistProduct.product.isPreorderable = isPreordeable
                        wishlistProduct.product.onHandInventory = onHandInventory
                        wishlistProduct.user = user!
                        
                    }
                    

                    
                    var result = ["items":itemsInWishlist]
                    
                    context.save(&error)
                    
                    successBlock!(result)
                    }) { (error:NSError) -> Void in
                        errorBlock!(error)
                }
                }, errorBlock: { (error:NSError) -> Void in
                    
             })
        } else {
            callCoreDataService(successBlock, errorBlock:errorBlock)
        }
    }
    
    func callCoreDataService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var predicate = NSPredicate(format: "user == nil AND status != %@",NSNumber(integer: WishlistStatus.Deleted.rawValue))
        if UserCurrentSession.sharedInstance().userSigned != nil {
            predicate = NSPredicate(format: "user == %@ AND status != %@", UserCurrentSession.sharedInstance().userSigned!,NSNumber(integer: WishlistStatus.Deleted.rawValue))
        }
        var array  =  (self.retrieve("Wishlist" as NSString as String,sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]) as [Wishlist]
        
        var returnDictionary = [:]
        var items : [AnyObject] = []
        var subtotal : Double = 0.0
        var totalQuantity = 0
        for itemWL in array {
            let dictItem = ["upc":itemWL.product.upc,"description":itemWL.product.desc,"price":itemWL.product.price,"imageUrl":[itemWL.product.img],"isActive":itemWL.product.isActive,"onHandInventory":itemWL.product.onHandInventory,"isPreorderable":itemWL.product.isPreorderable]
            items.append(dictItem)
        }
        
        returnDictionary = ["items":items]
        successBlock!(returnDictionary)
    }
    
    
    
    func synchronizeWishListFromCoreData(successBlock:(() -> Void), errorBlock:((NSError) -> Void)?){
        let predicateDeleted = NSPredicate(format: "status == %@", NSNumber(integer:WishlistStatus.Deleted.rawValue))
        let deteted = Array(UserCurrentSession.sharedInstance().userSigned!.wishlist.filteredSetUsingPredicate(predicateDeleted)) as! [Wishlist]
        if deteted.count > 0 {
            let serviceDelete = DeleteItemWishlistService()
            var arratUpcsDelete : [String] = []
            for itemDeleted in deteted {
                serviceDelete.callServiceWithParams(["parameter":[itemDeleted.product.upc]], successBlock: { (result:NSDictionary) -> Void in
                    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    
                    for wl in deteted {
                        context.deleteObject(wl)
                    }
                    
                    var error: NSError? = nil
                    context.save(&error)
                    
                    
                    self.synchronizeAddedWishlistFromCoreData(successBlock, errorBlock:errorBlock)
                    
                    }, errorBlock: { (error:NSError) -> Void in
                        if error.code != -100 {
                            self.synchronizeAddedWishlistFromCoreData (successBlock, errorBlock:errorBlock)
                        }
                })
            }
            
        } else {
           synchronizeAddedWishlistFromCoreData (successBlock, errorBlock:errorBlock)
        }
        
    }
    
    func synchronizeAddedWishlistFromCoreData (successBlock:(() -> Void), errorBlock:((NSError) -> Void)?) {
        let predicateUpdated = NSPredicate(format: "status == %@", NSNumber(integer:WishlistStatus.Created.rawValue))
        let added = UserCurrentSession.sharedInstance().WishlistWithoutUser()
        if added != nil {
        if added!.count > 0 {
            let serviceUpdate = ShoppingCartAddProductsService()
            var arrayUpcsUpdate : [AnyObject] = []
            
            for itemAdded in added! {
                let serviceWishList = AddItemWishlistService()
                serviceWishList.callService(itemAdded.product.upc, quantity: "1", comments: "",desc:itemAdded.product.desc,imageurl:itemAdded.product.img,price:itemAdded.product.price as String,isActive:itemAdded.product.isActive,onHandInventory:itemAdded.product.onHandInventory,isPreorderable:itemAdded.product.isPreorderable,mustUpdateWishList:false, successBlock: { (result:NSDictionary) -> Void in
                        successBlock()
                    }) { (error:NSError) -> Void in
                        successBlock()
                }
            }
        }else{
            successBlock()
        }

          
        } else {
            successBlock()
        }
        
    }
    
}
