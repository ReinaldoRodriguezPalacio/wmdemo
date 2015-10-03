//
//  GRPayPalUpdateOrderService.swift
//  WalMart
//
//  Created by Alonso Salcido on 03/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPaypalUpdateOrderService: GRBaseService{
    
  
    
    
    func callServiceConfirmOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
    func callServiceCancelOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        let jsonParams = JSON(params)
        let slot = jsonParams["slot"]
        let leapRequest = slot["leapRequest"]
        let fixedLeapRequest : [String:AnyObject]  =  [ "zipCode": leapRequest["zipCode"].stringValue,
                                                    "storeId": leapRequest["storeId"].intValue,
                                                    "businessId": leapRequest["businessId"].stringValue]
        
        
        let fixedSlot : [String:AnyObject]  = ["date": slot["date"].intValue,
                                                "storeId": slot["storeId"].intValue,
                                                "slotId": slot["slotId"].intValue,
                                                "transactionId": slot["transactionId"].intValue,
                                                "businessId": slot["businessId"].stringValue,
                                                "orderId": slot["orderId"].intValue,
                                                "leapRequest" : fixedLeapRequest]
        
        let fixedParamsToSend : [String:AnyObject] = ["slot":fixedSlot,"device": jsonParams["device"].stringValue,"paymentType": jsonParams["deliveryType"].stringValue,"deliveryType": jsonParams["deliveryType"].stringValue, "trackingNumber": jsonParams["trackingNumber"].stringValue]
        
        
        self.callPOSTService(fixedParamsToSend, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}