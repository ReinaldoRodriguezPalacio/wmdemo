//
//  DisplaySlotsService.swift
//  WalMart
//
//  Created by Joel Juarez on 08/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class DisplaySlotsService: BaseService{


//    Request for homeDelivery-Taxi
//    {
//    "deliveryType": "homeDeliveryTaxi"
//    }
//    
//    Request for StorePickUp and Click & Collect
//    {
//    "deliveryType": " storePickUp "
//    }
    
    
    func buildParamsHomeDelivery(_ deliveryType:String) -> [String:Any]{
        return ["deliveryType":deliveryType]
    }
    
    func buildParamsStorePickUp(_ storePickUp:String) -> [String:Any]{
        return ["deliveryType":storePickUp]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }

}

