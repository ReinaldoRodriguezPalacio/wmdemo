//
//  AuthorizationService.swift
//  WalMart
//
//  Created by Joel Juarez on 24/11/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class AuthorizationService : GRBaseService {
    
    
    override func callGETService(_ params: Any, successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        super.callGETService(params, successBlock: { (response:[String:Any]) in
            successBlock!(response)
        }, errorBlock: { (error:NSError) in
            errorBlock!(error)
        })
        
    }
    
    
}
