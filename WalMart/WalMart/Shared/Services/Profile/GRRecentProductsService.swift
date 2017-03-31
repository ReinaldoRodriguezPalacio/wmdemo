//
//  GRRecentProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRRecentProductsService: BaseService  {
    
    func buildParamsRecentProducts(profileId: String, storeId: String) -> [String:Any] {
        return ["profileId": profileId, "storeId": storeId]
    }
    
    func callService(requestParams params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print(params)
        self.callPOSTService(params, successBlock: { (resultCall: [String:Any]) -> Void in
            self.jsonFromObject(resultCall as AnyObject!)
            successBlock!(resultCall)
        }) { (error: NSError) -> Void in
            errorBlock!(error)
        }
    }
    
}
