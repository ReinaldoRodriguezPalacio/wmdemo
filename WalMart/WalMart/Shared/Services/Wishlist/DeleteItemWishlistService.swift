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
    
    
    func buildParams(_ UPC:String) -> [String:Any] {
        return ["parameter":[UPC]]
    }
    
    func buildParamsMultipe(_ UPC:[String]) -> [String:Any] {
        return ["parameter":UPC]
    }

    
    func callService(_ UPC:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callServiceWithParams(buildParams(UPC),successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callCoreDataService(_ UPC:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callCoreDataServiceWithParams(buildParams(UPC),successBlock: { (result:[String:Any]) -> Void in
            
            //Se actualza la lista del usuario
            self.callServiceWithParams(self.buildParams(UPC),successBlock: successBlock, errorBlock: errorBlock)
            }, errorBlock: errorBlock)
    }
    
    
    func callServiceWithParams(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
         if UserCurrentSession.hasLoggedUser() {
            self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
                
                //Se actualza la lista del usuario
                let serviceWish = UserWishlistService()
                serviceWish.callService({ (wishlist:[String:Any]) -> Void in
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
    
    func callCoreDataServiceWithParams(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        WishlistService.shouldupdate = true
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let parameter = params["parameter"] as! [Any]
        if parameter.count > 0 {
            for upcVal in parameter {
                let upc = upcVal as! String
                var predicate = NSPredicate(format: "product.upc == %@ AND user == nil ",upc)
                if UserCurrentSession.hasLoggedUser() {
                    predicate  = NSPredicate(format: "product.upc == %@ AND user == %@ ",upc,UserCurrentSession.sharedInstance.userSigned!)
                }
                let array : [Wishlist] =  self.retrieve("Wishlist" as String,sortBy:nil,isAscending:true,predicate:predicate) as! [Wishlist]
                
                for wishlistDelete in array {
                    wishlistDelete.status = NSNumber(value: WishlistStatus.deleted.rawValue as Int)
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
