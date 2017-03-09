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

    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
//                successBlock!(resultCall)
                successBlock!([:])
            }, errorBlock: { (error:NSError) -> Void in
                //successBlock!([:])
                errorBlock!(error)
                print("Error review:;:::::::: \(error)")
                
        })
    }
    
    override func serviceUrl() -> (String){
        return super.serviceUrl() + "/"  + self.addressId!
    }
    
    
}
    
    
    
    
    
    
    

