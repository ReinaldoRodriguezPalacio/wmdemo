//
//  AuthorizationService.swift
//  WalMart
//
//  Created by Joel Juarez on 24/11/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class AuthorizationService : GRBaseService {
    
    
    override func callGETService(params: AnyObject, successBlock: ((NSDictionary) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        super.callGETService(params, successBlock: { (response:NSDictionary) in
            print("ok Response Service")
            successBlock!(response)
        }, errorBlock: { (error:NSError) in
            print("ERROR:: \(error.localizedDescription)")
            errorBlock!(error)
        })
        
    }
    

}