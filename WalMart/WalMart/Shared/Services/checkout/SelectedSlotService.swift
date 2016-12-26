//
//  SelectedSlotService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 15/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SelectedSlotService: BaseService{

    func buildParams(_ deliveryType:String,selectedSlotId:String) -> [String:Any]{
        return ["deliveryType": deliveryType,"selectedSlotId": selectedSlotId]
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
