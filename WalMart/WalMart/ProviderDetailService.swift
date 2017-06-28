//
//  ProviderDetailService.swift
//  WalMart
//
//  Created by Daniel V on 02/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProviderDetailService : BaseService {
  
    var sellerId: String = ""
    func buildParams(_ sellerId:String) {
        self.sellerId = sellerId
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    override func serviceUrl() -> (String){
        return super.serviceUrl() + "/"  + self.sellerId
    }
}
