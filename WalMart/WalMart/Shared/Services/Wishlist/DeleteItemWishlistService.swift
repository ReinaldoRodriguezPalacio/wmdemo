//
//  DeleteItemWishlistService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class DeleteItemWishlistService : BaseService {
    
    
    func buildParams(UPC:String) -> NSDictionary {
        return ["parameter":[UPC]]
    }
    
    func buildParamsMultipe(UPC:[String]) -> NSDictionary {
        return ["parameter":UPC]
    }

    
    func callService(UPC:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(buildParams(UPC),successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callCoreDataService(UPC:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callCoreDataService(buildParams(UPC),successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
         if UserCurrentSession.sharedInstance().userSigned != nil {
            self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                
                //Se actualza la lista del usuario
                let serviceWish = UserWishlistService()
                serviceWish.callService({ (wishlist:NSDictionary) -> Void in
                    }, errorBlock: { (error:NSError) -> Void in
                })
                successBlock!([:])
                }) { (error:NSError) -> Void in
                    errorBlock!(error)
            }
         }else{
             callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock)
        }
    }
    
    func callCoreDataService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let parameter = params["parameter"] as NSArray
        if parameter.count > 0 {
            for upcVal in parameter {
                let upc = upcVal as NSString
                var predicate = NSPredicate(format: "product.upc == %@ AND user == nil ",upc)
                if UserCurrentSession.sharedInstance().userSigned != nil {
                    predicate  = NSPredicate(format: "product.upc == %@ AND user == %@ ",upc,UserCurrentSession.sharedInstance().userSigned!)
                }
                let array : [Wishlist] =  self.retrieve("Wishlist" as NSString,sortBy:nil,isAscending:true,predicate:predicate) as [Wishlist]
                
                for wishlistDelete in array {
                    wishlistDelete.status = NSNumber(integer:WishlistStatus.Deleted.rawValue)
                }

            }
            var error: NSError? = nil
            context.save(&error)
                
        }
        let shoppingService = UserWishlistService()
        shoppingService.callCoreDataService(successBlock, errorBlock: errorBlock)
    }
    
}