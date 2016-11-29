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
    
    
    func buildParamServiceUpcs(_ upcs:[String]) -> [[String:String]] {
        var paramsForOneQuantity : [[String:String]] = []
        for upcSearch in upcs {
            paramsForOneQuantity.append(buildParamService(upcSearch, quantity: "1"))
        }
        return paramsForOneQuantity
    }
    
    func buildParamService(_ upc:String,quantity:String) -> [String:String] {
        return ["upc":upc,"quantity":quantity]
    }
    
    
    func callService(requestParams params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if params.count > 0 {
            //self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
            }
        }else{
            let error:NSError? =  NSError(domain: ERROR_SERIVCE_DOMAIN, code: -1, userInfo: [NSLocalizedDescriptionKey:"Sin upcs a  buscar"])
             errorBlock!(error!)
        }
    }
    
    override func needsLogin() -> Bool {
        return false
    }
    
    
}
