//
//  ReviewShoppingCartService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRShoppingCartUpdateProductsService : GRShoppingCartAddProductsService {
    
    override func statusForProduct() -> Int {
        return CartStatus.Updated.rawValue
    }
    
    override func updateShoppingCart() -> Bool {
        return false
    }
    
    func callService(params: AnyObject,updateSC:Bool, successBlock: ((NSDictionary) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        if UserCurrentSession.hasLoggedUser() {
            var itemsSvc : [[String:AnyObject]] = []
            var upcSend = ""
            for itemSvc in params as! NSArray {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                let comments = itemSvc["comments"] as! String
                itemsSvc.append(builParamSvc(upcSend,quantity:quantity,comments:comments))
            }
            self.callPOSTService(itemsSvc, successBlock: { (resultCall:NSDictionary) -> Void in
                
             
                
                if updateSC {
                    let shoppingService = GRShoppingCartProductsService()
                    shoppingService.callService(requestParams: [:], successBlock: successBlock, errorBlock: errorBlock)
                }else{
                    successBlock!([:])
                }
                }) { (error:NSError) -> Void in
                    errorBlock!(error)
            }
            
        } else {
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    
    func callService(params: AnyObject, successBlock: ((NSDictionary) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        self.callService(params,updateSC:false, successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    
}