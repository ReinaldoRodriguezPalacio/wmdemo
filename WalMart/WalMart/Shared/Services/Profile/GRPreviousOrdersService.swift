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
    
    func callService(_ successBlock:(([[String:Any]]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
            let itemResult = resultCall[self.JSON_ORDERS_RESULT] as! [[String:Any]]
            successBlock!(itemResult)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}
