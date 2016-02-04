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
    
    func buildParams(upc:String) -> NSDictionary {
        return ["parameter":[upc]]
    }
    
    func builParams(upcArray:[String]) -> [String:AnyObject] {
        return ["parameter":upcArray]
    }
    
    func callService(upcArray:[String],successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callService(requestParams: builParams(upcArray), successBlock: successBlock, errorBlock: errorBlock)
    }

    
    func callService(requestParams params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if UserCurrentSession.hasLoggedUser() {
            self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                UserCurrentSession.sharedInstance().loadGRShoppingCart({ () -> Void in
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

    
    func callCoreDataServiceWithString(upc:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callCoreDataService(buildParams(upc), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callCoreDataService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let parameter = params["parameter"] as? [String] {
            if parameter.count > 0 {
                for upc in parameter {
                    let predicate = NSPredicate(format: "product.upc == %@ ",upc)
                   
                    let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                    
                    for cartDelete in array {
                        cartDelete.status = NSNumber(integer:CartStatus.Deleted.rawValue)
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
        UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
                successBlock!([:])
        }
        
        
    }
    
    
    
    
    
}
