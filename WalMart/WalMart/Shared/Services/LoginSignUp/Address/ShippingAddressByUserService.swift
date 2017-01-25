//
//  GetShippingAddressService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShippingAddressByUserService : BaseService {
    
    let JSON_RESULT = "responseObject"
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        let params: [String:AnyObject] = [:]
        self.callGETService(afManager,serviceURL:self.serviceUrl(),params:params as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}
