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
        self.callServiceWithParams(buildParams(UPC),successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callCoreDataService(UPC:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callCoreDataServiceWithParams(buildParams(UPC),successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callServiceWithParams(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
         if UserCurrentSession.hasLoggedUser() {
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
             callCoreDataServiceWithParams(params,successBlock:successBlock, errorBlock:errorBlock)
        }
    }
    
    func callCoreDataServiceWithParams(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let parameter = params["parameter"] as! NSArray
        if parameter.count > 0 {
            for upcVal in parameter {
                let upc = upcVal as! String
                var predicate = NSPredicate(format: "product.upc == %@ AND user == nil ",upc)
                if UserCurrentSession.hasLoggedUser() {
                    predicate  = NSPredicate(format: "product.upc == %@ AND user == %@ ",upc,UserCurrentSession.sharedInstance().userSigned!)
                }
                let array : [Wishlist] =  self.retrieve("Wishlist" as String,sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]
                
                for wishlistDelete in array {
                    wishlistDelete.status = NSNumber(integer:WishlistStatus.Deleted.rawValue)
                }

            }
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
                
        }
        let shoppingService = UserWishlistService()
        shoppingService.callCoreDataService(successBlock, errorBlock: errorBlock)
    }
    
}