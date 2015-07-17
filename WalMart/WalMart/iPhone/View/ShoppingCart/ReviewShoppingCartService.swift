//
//  ReviewShoppingCartService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ReviewShoppingCartService : BaseService {
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!([:])
            }, errorBlock: { (error:NSError) -> Void in
                successBlock!([:])
                println("Error review:;:::::::: \(error)")
                
        })
    }

    
}