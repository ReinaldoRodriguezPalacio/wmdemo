//
//  SelectedSlotService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 15/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SelectedSlotService: GRBaseService{

    func buildParams(deliveryType:String,selectedSlotId:String) -> NSDictionary{
        return ["deliveryType": deliveryType,"selectedSlotId": selectedSlotId]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
}
