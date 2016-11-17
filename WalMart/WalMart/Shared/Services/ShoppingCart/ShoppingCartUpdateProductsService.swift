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
    
    func callService(_ params:  [[String:Any]],updateSC:Bool, successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        
        if UserCurrentSession.hasLoggedUser() {
            var itemsSvc : [[String:Any]] = []
            var upcSend = ""
            for itemSvc in params {
                let upc = itemSvc["productId"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                let comments = itemSvc["itemComment"] as! String
                //Add skuId
                itemsSvc.append(builParamSvc("",upc:upcSend,quantity:quantity,comments:comments))
            }
            self.callPOSTService(itemsSvc, successBlock: { (resultCall:[String:Any]) -> Void in
                
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
    
    
    override func callService(_ params: [[String:Any]], successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
       self.callService(params,updateSC:false, successBlock: successBlock, errorBlock: errorBlock)
    }
    
}
