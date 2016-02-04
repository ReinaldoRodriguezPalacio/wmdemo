//
//  ShoppingCartDeleteProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/9/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


class ShoppingCartDeleteProductsService : BaseService {
 
    func builParams(upc:String) -> [String:AnyObject] {
        return ["parameter":[upc]]
    }
    

    func builParamsMultiple(upcs:[String]) -> [String:AnyObject] {
        return ["parameter":upcs]
    }

    
    
    
    func callCoreDataService(upc:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataServiceWithParams(builParams(upc), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if UserCurrentSession.hasLoggedUser() {
            self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                //let shoppingService = ShoppingCartProductsService()
                //shoppingService.callService([:], successBlock: successBlock, errorBlock: errorBlock)
                
                //let parameter = params["parameter"] as! NSArray
                if successBlock != nil {
                    successBlock!([:])
                }
                }) { (error:NSError) -> Void in
                    if errorBlock != nil {
                        errorBlock!(error)
                    }
            }
         } else {
            callCoreDataServiceWithParams(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    func callCoreDataServiceWithParams(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let parameter = params["parameter"] as! NSArray
        if parameter.count > 0 {
            for paramItem in parameter {
                let upc = paramItem as! NSString
                
                let predicate = NSPredicate(format: "product.upc == %@ ",upc)
                let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                
                for cartDelete in array {
                    cartDelete.status = NSNumber(integer:CartStatus.Deleted.rawValue)
                }
                do {
                    try context.save()
                } catch let error1 as NSError {
                    print(error1.description)
                }
            }
        }
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
}