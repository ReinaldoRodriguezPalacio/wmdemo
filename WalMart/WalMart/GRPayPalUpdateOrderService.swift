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
       return ["paymentType": params["paymentType"] as! String,
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
        
        return ["slot": params["slot"] as! String,
            "device": params["device"] as! String,
            "paymentType": params["paymentType"] as! String,
            "deliveryType": params["deliveryType"] as! String,
            "trackingNumber": params["trackingNumber"] as! String,
            "deliveryDate": params["deliveryDate"] as! String,
            "placedDate":params["placedDate"] as! String,
            "deliveryTypeString": params["deliveryTypeString"] as! String,
            "paymentTypeString": params["paymentTypeString"] as! String]
    }
    
    
    func callServiceCancelOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(buildParamsCancelOrder(params), successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}