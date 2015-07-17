//
//  GRAddressByUserService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressByUserService : GRBaseService {
    
    func callService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callGETService([:],
            successBlock: { (resultCall:NSDictionary) -> Void in
                successBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                successBlock!([:])
                println("Error review:;:::::::: \(error)")
            }
        )
    }
    
}



    
