//
//  DeleteShippingAddressService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class DeleteAddressesByUserService : BaseService {
    
    var idAddress : String? = nil
    
    func buildParams(idAddressParam:String) -> [String:AnyObject] {
        self.idAddress = idAddressParam
        return ["addressId":idAddressParam]
    }
    
    func callService(params:[String:AnyObject],successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func serviceUrl() -> (String){
        return super.serviceUrl() + "/"  + self.idAddress!
    }
    
    

}

