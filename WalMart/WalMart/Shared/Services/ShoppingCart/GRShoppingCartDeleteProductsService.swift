//
//  ShoppingCartDeleteProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRShoppingCartDeleteProductsService : GRBaseService {
    
    func buildParams(_ upc:String) -> NSDictionary {
        return ["parameter":[upc]]
    }
    
    func builParams(_ upcArray:[String]) -> [String:Any] {
        return ["parameter":upcArray as AnyObject]
    }
    
    func callService(_ upcArray:[String],successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(requestParams: builParams(upcArray) as NSDictionary, successBlock: successBlock, errorBlock: errorBlock)
    }

    
    func callService(requestParams params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if UserCurrentSession.hasLoggedUser() {
            self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                    UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
                    if successBlock != nil {
                        successBlock!(resultCall)
                    }
                })
               
                }) { (error:NSError) -> Void in
                    if errorBlock != nil {
                        errorBlock!(error)
                    }
            }
        } else {
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }

    
    func callCoreDataServiceWithString(_ upc:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callCoreDataService(buildParams(upc), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callCoreDataService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let parameter = params["parameter"] as? [String] {
            if parameter.count > 0 {
                for upc in parameter {
                    var predicate = NSPredicate(format: "product.upc == %@ AND user == nil ",upc)
                    if UserCurrentSession.hasLoggedUser() {
                        predicate  = NSPredicate(format: "product.upc == %@ AND user == %@ ",upc,UserCurrentSession.sharedInstance().userSigned!)
                    }
                    let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                    
                    for cartDelete in array {
                        cartDelete.status = NSNumber(value: CartStatus.deleted.rawValue as Int)
                    }
                    var error: NSError? = nil
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        error = error1
                    }
                    if error != nil {
                        print(error)
                    }
                }
            }
        }
        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
                successBlock!([:])
        }
        
        
    }
    
    
    
    
    
}
