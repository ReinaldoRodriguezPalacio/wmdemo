//
//  GRZipCodeService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRZipCodeService : GRBaseService {
    
    var code : String? = nil
    
    func buildParams(_ zipCode:String) {
        self.code = zipCode
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func serviceUrl() -> (String){
        return super.serviceUrl() + "/"  + self.code!
    }
    
    
    override func needsLogin() -> Bool {
        return false
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
}
