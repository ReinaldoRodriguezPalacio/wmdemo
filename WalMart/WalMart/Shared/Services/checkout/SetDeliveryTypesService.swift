//
//  SetDeliveryTypesService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 13/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SetDeliveryTypeService : GRBaseService {
    
    func buildParams(_ deliveryType:String,addressID:String,idList:String) -> [String:Any] {
        
        return [ "deliveryType":deliveryType,"AddressID":addressID,"storeId":"","idList":idList]
    }
    
    func callService(requestParams params:Any, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock?(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock?(error)
        }
        
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
    
}

