//
//  GRDeliveryTypeService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRDeliveryTypeService : GRBaseService {
    
    var numProducts: String?
    var addressId: String?
    
    func buildParams(numProducts:String,addressId:String,nightHours:String) -> NSDictionary {
        return ["numProducts":numProducts, "addressId":addressId, "nightHours":nightHours]
    }
    
    func setParams(numProducts:String, addressId:String) {
        self.numProducts = numProducts
        self.addressId = addressId
    }
    
    func callService(requestParams params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        
        self.callPOSTService(buildParams(self.numProducts!,addressId:self.addressId!,nightHours:"true"), successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }

    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
 
    
}



    