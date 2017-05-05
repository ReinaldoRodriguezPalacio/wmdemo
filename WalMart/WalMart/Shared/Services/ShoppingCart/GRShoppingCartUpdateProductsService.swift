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
        return CartStatus.updated.rawValue
    }
    
    override func updateShoppingCart() -> Bool {
        return false
    }
    
    func callService(_ params: Any,updateSC:Bool, successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        if UserCurrentSession.hasLoggedUser() {
            var itemsSvc : [[String:Any]] = []
            var upcSend = ""
            for itemSvc in params as! [[String:Any]] {
                let upc = itemSvc["upc"] as! String
                upcSend = upc
                let quantity = itemSvc["quantity"] as! String
                let comments = itemSvc["comments"] as! String
                let baseUomcd = itemSvc["orderByPieces"] as! NSNumber
                itemsSvc.append(builParamSvc(upcSend,quantity:quantity,comments:comments,baseUomcd:baseUomcd.boolValue ? "EA" : "GM" ))
            }
            self.callPOSTService(itemsSvc, successBlock: { (resultCall:[String:Any]) -> Void in
                
                if updateSC {
                    UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                        successBlock!([:])
                    }
                } else {
                    successBlock!([:])
                }
                
            }) { (error:NSError) -> Void in
                    errorBlock!(error)
            }
            
        } else {
            callCoreDataService(params,successBlock:successBlock, errorBlock:errorBlock )
        }
    }
    
    
    func callService(_ params: AnyObject, successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        self.callService(params,updateSC:false, successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    
}
