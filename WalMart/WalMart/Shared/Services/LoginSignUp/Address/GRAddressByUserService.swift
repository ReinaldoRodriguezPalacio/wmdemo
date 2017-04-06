//
//  GRAddressByUserService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressByUserService : GRBaseService {
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callGETService([:],
            successBlock: { (resultCall:[String:Any]) -> Void in
                successBlock!(resultCall)
//                successBlock!([:])
            }, errorBlock: { (error:NSError) -> Void in
                successBlock!([:])
                print("Error review:;:::::::: \(error)")
            }
        )
    }
    
}



    
