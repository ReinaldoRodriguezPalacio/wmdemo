//
//  ForgotPasswordService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 30/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ForgotPasswordService : BaseService {
    
    
    func buildParams(_ email:String) -> [String : Any] {
        return ["login":email]
    }
    
    func callService(requestParams params:AnyObject,successBlock:(([String : Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String : Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}

