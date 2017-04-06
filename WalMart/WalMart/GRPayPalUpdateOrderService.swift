//
//  GRPayPalUpdateOrderService.swift
//  WalMart
//
//  Created by Alonso Salcido on 03/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPaypalUpdateOrderService: GRBaseService{
    
  
    
    
    func callServiceConfirmOrder(requestParams params:[String:Any], succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        
//        delay(2) {
//            if let path = Bundle.main.path(forResource: "paypalmockexamplecancel", ofType: "json"){
//                let jsonData =  try! Data(contentsOf: URL(fileURLWithPath:path))
//                let jsonResult = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
//                let resultJSON = jsonResult as! [String:Any]
//                if let errorResult = self.validateCodeMessage(resultJSON) {
//                    errorBlock!(errorResult)
//                    return
//                }
//                succesBlock!(resultJSON)
//            }
//        }

        
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
    func callServiceCancelOrder(requestParams params:[String:Any], succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        let jsonParams = JSON(params)
        let slot = jsonParams["slot"]
        let leapRequest = slot["leapRequest"]
        let fixedLeapRequest : [String:Any]  =  [ "zipCode": leapRequest["zipCode"].stringValue,
                                                    "storeId": leapRequest["storeId"].intValue,
                                                    "businessId": leapRequest["businessId"].stringValue]
        
        
        let fixedSlot : [String:Any]  = ["date": slot["date"].intValue,
                                                "storeId": slot["storeId"].intValue,
                                                "slotId": slot["slotId"].intValue,
                                                "transactionId": slot["transactionId"].intValue,
                                                "businessId": slot["businessId"].stringValue,
                                                "orderId": slot["orderId"].intValue,
                                                "leapRequest" : fixedLeapRequest]
        
        let fixedParamsToSend : [String:Any] = ["slot":fixedSlot,"device": jsonParams["device"].stringValue,"paymentType": jsonParams["deliveryType"].stringValue,"deliveryType": jsonParams["deliveryType"].stringValue, "trackingNumber": jsonParams["trackingNumber"].stringValue]
        
        
        self.callPOSTService(fixedParamsToSend, successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}
