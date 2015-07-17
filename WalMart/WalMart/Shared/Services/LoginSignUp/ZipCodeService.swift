//
//  ZipCodeService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ZipCodeService : BaseService {
    
    var code : String? = nil
    
    func buildParams(zipCode:String) {
        self.code = zipCode
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
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

    
}