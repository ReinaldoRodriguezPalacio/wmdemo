//
//  RemoveCouponService.swift
//  WalMart
//
//  Created by Daniel V on 06/04/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class RemoveCouponService:BaseService {
    
    func buildParameter(_ couponCode:String) -> [String:Any] {
        
        return ["couponCode":couponCode,"cartEmpty":" true"]
        //OR
        //return ["couponCode":"dclm814b54"]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
        }, errorBlock: { (error:NSError) -> Void in
            errorBlock!(error)
        })
    }
    
}
