//
//  GRSendOrderService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/18/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRSendOrderService : BaseService {

    func buildParams(total:Double, month:String, year:String, day:String, comments:String, paymentType:String, addressID:String, device:String, slotId:Int, deliveryType:String, correlationId:String, hour:String, pickingInstruction:String, deliveryTypeString:String, authorizationId:String, paymentTypeString:String,isAssociated:Bool,idAssociated:String,dateAdmission:String,determinant:String,isFreeShipping:Bool,promotionIds:String,appId:String,totalDiscounts:Double) -> NSDictionary {
        
        return ["total":total, "month":month, "year":year, "day":day, "comments":comments, "paymentType":paymentType, "AddressID":addressID, "device":device, "slotId":slotId, "deliveryType":deliveryType, "correlationId":correlationId, "hour":hour, "pickingInstruction":pickingInstruction, "deliveryTypeString":deliveryTypeString, "authorizationId":authorizationId, "paymentTypeString":paymentTypeString,"associatedDiscount":["isAssociated":isAssociated,"idAssociated":idAssociated,"dateAdmission":dateAdmission,"determinant":determinant,"isFreeShipping":isFreeShipping],"promotionIds":promotionIds,"appId":appId,"totalDiscounts":totalDiscounts]
        
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    

}