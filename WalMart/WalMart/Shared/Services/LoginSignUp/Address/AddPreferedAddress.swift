//
//  AddPreferedAddress.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class AddPreferedAddress : BaseService {
    
    var code : String? = nil
    
    func buildParams(zipCode:String) {
        self.code = zipCode
    }
    func buildParamsInvoice(idAddressParam:String) -> [String:AnyObject] {
        
        return ["addressId":idAddressParam]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
//    override func serviceUrl() -> (String){
//        return super.serviceUrl() + "/"  + self.code!
//    }
    
}