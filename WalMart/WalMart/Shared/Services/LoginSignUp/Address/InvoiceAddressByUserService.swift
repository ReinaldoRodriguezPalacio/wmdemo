//
//  InvoiceAddressByUserService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 04/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class InvoiceAddressByUserService : BaseService {
    
    let JSON_RESULT = "responseObject"
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        let empty: [String:Any] = [:]
        self.callGETService(afManager,serviceURL:self.serviceUrl(),params:empty as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }

    
}
