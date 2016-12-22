//
//  AuthorizationService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 22/12/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class AuthorizationService : BaseService {
    
    override func callGETService(params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ){
            self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            print("ok AuthorizationService")
            successBlock!(resultCall)
            }, errorBlock: { (error:NSError) in
                print("ERROR AuthorizationService:: \(error.localizedDescription)")
                errorBlock!(error)
        })
    }
    
}