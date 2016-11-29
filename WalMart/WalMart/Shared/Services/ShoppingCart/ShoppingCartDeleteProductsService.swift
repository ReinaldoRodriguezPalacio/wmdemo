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
 
    func builParams(_ upc:String) -> [String:Any] {
        return ["parameter":[upc]]
    }
    

    func builParamsMultiple(_ upcs:[String]) -> [String:Any] {
        return ["parameter":upcs]
    }

    
    
    
    func callCoreDataService(_ upc:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callCoreDataServiceWithParams(builParams(upc), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if UserCurrentSession.hasLoggedUser() {
            self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
                //let shoppingService = ShoppingCartProductsService()
                //shoppingService.callService([:], successBlock: successBlock, errorBlock: errorBlock)
                
                //let parameter = params["parameter"] as! [Any]
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
    
    func callCoreDataServiceWithParams(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let parameter = params["parameter"] as! [Any]
        if parameter.count > 0 {
            for paramItem in parameter {
                let upc = paramItem as! NSString
                var predicate = NSPredicate(format: "product.upc == %@ AND user == nil ",upc)
                if UserCurrentSession.hasLoggedUser() {
                    predicate  = NSPredicate(format: "product.upc == %@ AND user == %@ ",upc,UserCurrentSession.sharedInstance().userSigned!)
                }
                let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
                
                for cartDelete in array {
                    cartDelete.status = NSNumber(value: CartStatus.deleted.rawValue as Int)
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
