//
//  GRAddressesByIDService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressesByIDService : GRBaseService {
    
    
    var addressId : String? = nil
    
    func buildParams(_ addressId:String) {
        self.addressId = addressId
    }

    
    func callService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
       
        let params: NSDictionary = [:]
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                successBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                successBlock!([:])
                print("Error review:;:::::::: \(error)")
                
        })
    }
    
    override func serviceUrl() -> (String){
        return super.serviceUrl() + "/"  + self.addressId!
    }
    
    
}
    
    
    
    
    
    
    

