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
    var isFreeShiping: String?
    
    func buildParams(_ numProducts:String,addressId:String,nightHours:String,isFreeShiping:String) -> [String:Any] {
        return ["numProducts":numProducts, "addressId":addressId, "nightHours":nightHours,"isFreeShiping":isFreeShiping]
        //return ["numProducts":numProducts, "addressId":addressId, "nightHours":nightHours]
    }
    
    func setParams(_ numProducts:String, addressId:String,isFreeShiping:String) {
        self.numProducts = numProducts
        self.addressId = addressId
        self.isFreeShiping = isFreeShiping
    }
    
    func callService(requestParams params:AnyObject, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(buildParams(self.numProducts!,addressId:self.addressId!,nightHours:"true",isFreeShiping:self.isFreeShiping!))
        self.callPOSTService(buildParams(self.numProducts!,addressId:self.addressId!,nightHours:"true",isFreeShiping:self.isFreeShiping!), successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }

    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
 
    
}



    
