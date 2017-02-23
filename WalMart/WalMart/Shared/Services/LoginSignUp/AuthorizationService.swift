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
            print("ok AuthorizationService ")
            successBlock!(response)
        }, errorBlock: { (error:NSError) in
            print("ERROR AuthorizationService:: \(error.localizedDescription)")
            errorBlock!(error)
        })
        
    }
    

}
