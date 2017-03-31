//
//  UpsellingProductService.swift
//  WalMart
//
//  Created by Daniel V on 31/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class UpsellingProductService : BaseService {
    let JSON_CROSSSELL_RESULT = "ProductListUpsell"
    
    func buildParamsMustang(_ skuId:String) -> [String : Any] {
        return ["storeId":UserCurrentSession.sharedInstance.storeId == nil ? "" :UserCurrentSession.sharedInstance.storeId!, "skuId":skuId, "displayList":["1"]]
    }
    
    func callService(requestParams params:Any,successBlock:(([[String:Any]]?) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.jsonFromObject(params as AnyObject!)
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let resultObject =  resultCall[self.JSON_CROSSSELL_RESULT] as? [[String:Any]] {
                successBlock!(resultObject)
                return
            }
            successBlock!(nil)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
}
