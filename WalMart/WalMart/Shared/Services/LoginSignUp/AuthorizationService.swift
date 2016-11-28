//
//  AuthorizationService.swift
//  WalMart
//
//  Created by Joel Juarez on 24/11/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class AuthorizationService : GRBaseService {
    
    
    override func callGETService(_ params: AnyObject, successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        super.callGETService(params, successBlock: { (response:[String:Any]) in
            print("ok Response Service")
            successBlock!(response)
        }, errorBlock: { (error:NSError) in
            print("ERROR:: \(error.localizedDescription)")
            errorBlock!(error)
        })
        
    }
    

}
