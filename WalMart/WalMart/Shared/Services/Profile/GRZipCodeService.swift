//
//  GRZipCodeService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRZipCodeService : BaseService {
    
    var code : String? = nil
    
    func buildParams(zipCode:String) -> NSDictionary{
       return ["zipCode":zipCode]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    override func needsLogin() -> Bool {
        return false
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
}