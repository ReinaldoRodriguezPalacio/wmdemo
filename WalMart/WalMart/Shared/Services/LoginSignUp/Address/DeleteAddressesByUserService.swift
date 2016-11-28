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
    
    func buildParams(_ idAddressParam:String) {
        self.idAddress = idAddressParam
    }
    
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func serviceUrl() -> (String){
        return super.serviceUrl() + "/"  + self.idAddress!
    }
    
    

}

