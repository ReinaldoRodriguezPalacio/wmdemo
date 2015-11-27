//
//  ReferedCustomerService.swift
//  WalMart
//
//  Created by Joel Juarez on 06/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedCustomerService : GRBaseService {
    
    
    func callService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:],
            successBlock: { (resultCall:NSDictionary) -> Void in
                self.jsonFromObject(resultCall)
                
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