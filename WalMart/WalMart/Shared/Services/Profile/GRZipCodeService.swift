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
    
    func buildParams(_ zipCode:String) -> [String:Any]{
       return ["zipCode":zipCode]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
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
