//
//  ReviewShoppingCartService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ReviewShoppingCartService : BaseService {
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!([:])
            }, errorBlock: { (error:NSError) -> Void in
                successBlock!([:])
                print("Error review:;:::::::: \(error)")
                
        })
    }

    
}
