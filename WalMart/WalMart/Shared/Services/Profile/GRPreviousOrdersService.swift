//
//  GRPreviousOrdersService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/24/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPreviousOrdersService : GRBaseService  {
    
    let JSON_ORDERS_RESULT = "responseArray"
    
    func callService(successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
            let itemResult = resultCall[self.JSON_ORDERS_RESULT] as NSArray
            successBlock!(itemResult)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}