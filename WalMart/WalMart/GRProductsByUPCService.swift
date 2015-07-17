//
//  GRProductsByUPCService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/05/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRProductsByUPCService : GRBaseService {
    
    
    let JSON_ITEMS_RESULT = "items"
    
    
    func buildParamService(upc:String,quantity:String) -> [String:String] {
        return ["upc":upc,"quantity":quantity]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsLogin() -> Bool {
        return false
    }
    
    
}