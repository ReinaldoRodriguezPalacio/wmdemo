//
//  ReferedCustomerService.swift
//  WalMart
//
//  Created by Joel Juarez on 06/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedCustomerService : GRBaseService {
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let empty: [String:Any] = [:]
        self.callGETService(empty as AnyObject,
            successBlock: { (resultCall:[String:Any]) -> Void in
                self.jsonFromObject(resultCall as AnyObject!)
                
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
