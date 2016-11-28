//
//  AddReferedCustumerService.swift
//  WalMart
//
//  Created by Joel Juarez on 06/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class AddReferedCustumerService : GRBaseService {
    func buildParamsRefered(_ emailRef:String,nameRef:String,isReferedAutorized:Bool) -> [String:Any] {
        return [ "emailRef":emailRef,  "nameRef": nameRef,  "isReferedAutorized":isReferedAutorized]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    
}
