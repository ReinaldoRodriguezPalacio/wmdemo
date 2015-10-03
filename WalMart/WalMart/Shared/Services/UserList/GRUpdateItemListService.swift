//
//  GRUpdateItemListService.swift
//  WalMart
//
//  Created by neftali on 12/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUpdateItemListService: GRBaseService {

    //[{"upc": "0750105530007", "quantity": 3.0, "comments": "", "longDescription": "", "pesable": "", "equivalenceByPiece": "", "promoDescription": "", "productIsInStores": ""}]
    
    func buildParams(upc upc:String, quantity:Int) -> [AnyObject] {
        return [self.buildProductObject(upc: upc, quantity: quantity)]
    }
    
    func buildProductObject(upc upc:String, quantity:Int) -> [String:AnyObject] {
        return ["upc":upc, "quantity":quantity, "comments":"", "longDescription": "", "pesable": "", "equivalenceByPiece": "", "promoDescription": "", "productIsInStores": ""]
    }
    
    func callService(params:NSArray, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                //self.manageList(resultCall)
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
