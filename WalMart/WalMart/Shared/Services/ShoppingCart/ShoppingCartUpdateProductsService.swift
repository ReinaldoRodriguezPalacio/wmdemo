//
//  ShoppingCartUpdateProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/19/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShoppingCartUpdateProductsService : ShoppingCartAddProductsService {
    
    override func statusForProduct() -> Int {
        return CartStatus.updated.rawValue
    }
    
    override func updateShoppingCart() -> Bool {
        return false
    }
    
    func callService(_ params: AnyObject,updateSC:Bool, successBlock: ((NSDictionary) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        
        if UserCurrentSession.hasLoggedUser() {
            var itemsSvc : [[String:AnyObject]] = []
            var upcSend = ""
            for itemSvc in params as! NSArray {
                let upc = itemSvc["productId"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                let comments = itemSvc["itemComment"] as! String
                //Add skuId
                itemsSvc.append(builParamSvc("",upc:upcSend,quantity:quantity,comments:comments) as! [String : AnyObject])
            }
            self.callPOSTService(itemsSvc, successBlock: { (resultCall:NSDictionary) -> Void in
                
                if updateSC {
                    let shoppingService = ShoppingCartProductsService()
                    shoppingService.callService([:], successBlock: successBlock, errorBlock: errorBlock)
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
    
    
    override func callService(_ params: AnyObject, successBlock: ((NSDictionary) -> Void)?, errorBlock: ((NSError) -> Void)?) {
       self.callService(params,updateSC:false, successBlock: successBlock, errorBlock: errorBlock)
    }
    
}
