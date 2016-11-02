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
    
    func buildParams(_ zipCode:String) {
        self.code = zipCode
    }
    func buildParamsInvoice(_ idAddressParam:String) -> [String:Any] {
        
        return ["addressId":idAddressParam as AnyObject]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
//    override func serviceUrl() -> (String){
//        return super.serviceUrl() + "/"  + self.code!
//    }
    
}
