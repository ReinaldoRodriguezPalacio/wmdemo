//
//  ValidateActiveReferedService.swift
//  WalMart
//
//  Created by Joel Juarez on 06/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ValidateActiveReferedService : BaseService {
       
    func callService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                successBlock!([:])
                print("Error review::::::::: \(error)")
        })
    }
}