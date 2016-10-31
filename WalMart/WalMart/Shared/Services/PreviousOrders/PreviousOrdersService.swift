//
//  PreviousOrdersService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class PreviousOrdersService : BaseService {
    
    let JSON_ORDERS_RESULT = "responseArray"
    
    func callService(_ successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
            let itemResult = resultCall[self.JSON_ORDERS_RESULT] as! NSArray
            successBlock!(itemResult)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}
