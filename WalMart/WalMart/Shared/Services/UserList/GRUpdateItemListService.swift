//
//  GRUpdateItemListService.swift
//  WalMart
//
//  Created by neftali on 12/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUpdateItemListService: GRBaseService {
    
    func buildParams(upc:String, quantity:Int) -> [Any] {
        return [self.buildProductObject(upc: upc, quantity: quantity) as AnyObject]
    }
    
    func buildProductObject(upc:String, quantity:Int) -> [String:Any] {
        return ["upc":upc as AnyObject, "quantity":quantity as AnyObject, "comments":"" as AnyObject, "longDescription": "" as AnyObject, "pesable": "" as AnyObject, "equivalenceByPiece": "" as AnyObject, "promoDescription": "" as AnyObject, "productIsInStores": ""]
    }
    
    func buildItemMustang(_ upc:String,sku:String,quantity:Int) -> [String:Any] {
        return ["upc":upc,"skuId":sku,"quantity":quantity]
        
    }
    
    func buildItemMustangObject(idList:String, upcs:[String:Any]) -> [String:Any] {
        return ["idList":idList,"items":[upcs]]
    }

    
    func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params as AnyObject!)
        self.callPOSTService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
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
