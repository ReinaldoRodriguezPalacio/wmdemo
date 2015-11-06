//
//  AddReferedCustumer.swift
//  WalMart
//
//  Created by Joel Juarez on 06/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class AddReferedCustumer : GRBaseService {
    
    
    func buildParamsRefered(emailRef:String,nameRef:String,isReferedAutorized:Bool) -> NSDictionary {
        return [ "emailRef":emailRef,  "nameRef": nameRef,  "isReferedAutorized":isReferedAutorized]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    
}