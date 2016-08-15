//
//  GRUpdateItemListService.swift
//  WalMart
//
//  Created by neftali on 12/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUpdateItemListService: GRBaseService {
    
    func buildParams(upc upc:String, quantity:Int) -> [AnyObject] {
        return [self.buildProductObject(upc: upc, quantity: quantity)]
    }
    
    func buildProductObject(upc upc:String, quantity:Int) -> [String:AnyObject] {
        return ["upc":upc, "quantity":quantity, "comments":"", "longDescription": "", "pesable": "", "equivalenceByPiece": "", "promoDescription": "", "productIsInStores": ""]
    }
    
    func buildItemMustang(sku:String,quantity:Int) -> NSDictionary {
        return ["skuId":sku,"quantity":quantity]
        
    }
    
    func buildItemMustangObject(idList idList:String, upcs:NSDictionary) -> NSDictionary {
        return ["idList":idList,"items":[upcs]]
    }

    
    func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params)
        self.callPOSTService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                //self.manageList(resultCall) //Mustang
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

}
