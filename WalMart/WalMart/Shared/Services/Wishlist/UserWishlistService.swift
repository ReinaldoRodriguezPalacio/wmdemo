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
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
       
        if UserCurrentSession.hasLoggedUser() {
             self.synchronizeWishListFromCoreData({ () -> Void in
                self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
                    
                    
                    let itemResult = resultCall[self.JSON_WISHLIST_RESULT] as! [String:Any]
                    let itemWishList = itemResult["items"] as! [[String:Any]]
                    
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    let user = UserCurrentSession.sharedInstance.userSigned
                    
                    let predicate = NSPredicate(format: "user == %@ ", user!)
                    let array : [Wishlist] =  (self.retrieve("Wishlist" as String,sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]) as [Wishlist]
                    for itemWishlist in array {
                        context.delete(itemWishlist)
                    }
                    
                    let predicateSinUsr = NSPredicate(format: "user == nil ")
                    let arraySinUsr : [Wishlist] =  (self.retrieve("Wishlist" as String,sortBy:nil,isAscending:true,predicate:predicateSinUsr) as! [Wishlist]) as [Wishlist]
                    for itemWishlist in arraySinUsr {
                        context.delete(itemWishlist)
                    }
                    
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        print(error1.description)
                    } catch {
//                        fatalError()
                    }
                    
                    var itemsInWishlist : [[String:Any]] = []
                    
                    for wishlistDicProduct in itemWishList {
                        
                        var dictWishListProduct = wishlistDicProduct 
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
                        if let images = wishlistDicProduct["imageUrl"] as? [Any] {
                            imageUrl = images[0] as! String
                        }
                        
                        let isActive = wishlistDicProduct["isActive"] as! String
                        let onHandInventory = wishlistDicProduct["onHandInventory"] as! String
                        
                        var isPreordeable  = "false"
                        if let preordeable  = wishlistDicProduct["isPreorderable"] as? String {
                            isPreordeable = preordeable
                        }

                        var category  = ""
                        if let categoryVal  = wishlistDicProduct["department"] as? String {
                            category = categoryVal
                        }

                        wishlistProduct = NSEntityDescription.insertNewObject(forEntityName: "Wishlist" as String, into: context) as! Wishlist
                        wishlistProduct.product = NSEntityDescription.insertNewObject(forEntityName: "Product" as String, into: context) as! Product
                        wishlistProduct.product.upc = upc
                        wishlistProduct.product.desc = desc
                        wishlistProduct.product.price = price as NSString
                        wishlistProduct.product.img = imageUrl
                        wishlistProduct.product.isActive = isActive
                        wishlistProduct.product.isPreorderable = isPreordeable
                        wishlistProduct.product.onHandInventory = onHandInventory
                        wishlistProduct.product.department = category
                        wishlistProduct.user = user!
                        
                        if let offers = wishlistDicProduct["offers"] as? [Any] {
                            if let offer = offers.first as? [String:Any] {
                                wishlistProduct.product.sellerId = offer["sellerId"] as? String
                                wishlistProduct.product.sellerName = offer["name"] as? String
                                wishlistProduct.product.offerId = offer["offerId"] as? String
                            }
                        }
                        
                    }
                    

                    
                    let result = ["items":itemsInWishlist]
                    
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        print(error1.description)
                    } catch {
//                        fatalError()
                    }
                    
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
    
    func callCoreDataService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        //let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var predicate = NSPredicate(format: "user == nil AND status != %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@", UserCurrentSession.sharedInstance.userSigned!,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }
        let array  =  (self.retrieve("Wishlist" as String,sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]) as [Wishlist]
        
        var returnDictionary: [String:Any] = [:]
        var items : [[String:Any]] = []
        //var subtotal : Double = 0.0
        //var totalQuantity = 0
        for itemWL in array {
            let dictItem: [String:Any] = ["upc":itemWL.product.upc,"description":itemWL.product.desc,"price":itemWL.product.price,"imageUrl":[itemWL.product.img],"isActive":itemWL.product.isActive,"onHandInventory":itemWL.product.onHandInventory,"isPreorderable":itemWL.product.isPreorderable,"category":itemWL.product.department]
            items.append(dictItem)
        }
        
        returnDictionary = ["items":items]
        successBlock!(returnDictionary)
    }
    
    
    
    func synchronizeWishListFromCoreData(_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?){
        let predicateDeleted = NSPredicate(format: "status == %@", NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        let deteted = Array(UserCurrentSession.sharedInstance.userSigned!.wishlist.filtered(using: predicateDeleted)) as! [Wishlist]
        if deteted.count > 0 {
            let serviceDelete = DeleteItemWishlistService()
            for itemDeleted in deteted {
                serviceDelete.callServiceWithParams(["parameter":[itemDeleted.product.upc]], successBlock: { (result:[String:Any]) -> Void in
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    
                    for wl in deteted {
                        context.delete(wl)
                    }
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        print(error1.description)
                    } catch {
//                        fatalError()
                    }
                    
                    
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
    
    func synchronizeAddedWishlistFromCoreData (_ successBlock:@escaping (() -> Void), errorBlock:((NSError) -> Void)?) {
        //let predicateUpdated = NSPredicate(format: "status == %@", NSNumber(integer:WishlistStatus.Created.rawValue))
        let added = UserCurrentSession.sharedInstance.WishlistWithoutUser()
        if added != nil {
        if added!.count > 0 {
            //let serviceUpdate = ShoppingCartAddProductsService()
            //var arrayUpcsUpdate : [Any] = []
            
            for itemAdded in added! {
                let serviceWishList = AddItemWishlistService()
                serviceWishList.callService(itemAdded.product.upc, quantity: "1", comments: "",desc:itemAdded.product.desc,imageurl:itemAdded.product.img,price:itemAdded.product.price as String,isActive:itemAdded.product.isActive,onHandInventory:itemAdded.product.onHandInventory,isPreorderable:itemAdded.product.isPreorderable,category:itemAdded.product.department,mustUpdateWishList:false,sellerId: itemAdded.product.sellerId,sellerName: itemAdded.product.sellerName,offerId: itemAdded.product.offerId,successBlock: { (result:[String:Any]) -> Void in
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
