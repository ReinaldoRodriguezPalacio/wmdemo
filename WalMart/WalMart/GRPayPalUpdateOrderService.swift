//
//  GRPayPalUpdateOrderService.swift
//  WalMart
//
//  Created by Alonso Salcido on 03/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPaypalUpdateOrderService: GRBaseService{
    
    func buildParamsConfirmOrder(params:NSDictionary) -> NSDictionary{
       return ["paymentType": "-1",
        "trackingNumber": params["trackingNumber"] as! String,
        "authorizationId": params["authorizationId"] as! String,
        "correlationId": params["correlationId"] as! String,
        "deliveryDate": params["deliveryDate"] as! String,
        "placedDate":params["placedDate"] as! String,
        "deliveryTypeString": params["deliveryTypeString"] as! String,
        "paymentTypeString": "PayPal"]
    }
    
    
    func callServiceConfirmOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(buildParamsConfirmOrder(params), successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
    func buildParamsCancelOrder(params:NSDictionary) -> NSDictionary{
        
        let leapRequest: NSDictionary = ["zipCode": "3100","storeId": 3848,"businessId": "WM"]
        
        let slot: NSDictionary = ["date": 1441040520831,"storeId": 3848,"slotId": 238,"transactionId": 14200,"businessId": "WM","leapRequest": leapRequest,"orderId": 14753774]
        
        return ["slot": slot,"device": "25","paymentType": "-1","deliveryType": "3","trackingNumber": "14753774","deliveryDate": "31/08/2015","placedDate":"31/08/2015","deliveryTypeString": "Entrega Programada - $44","paymentTypeString": "PayPal"]
    }
    
    
    func callServiceCancelOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(buildParamsCancelOrder(params), successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}