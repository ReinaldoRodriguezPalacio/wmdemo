//
//  File.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 16/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class GROrderByEmailService : GRBaseService {
 
    
    func buildParams(_ total:String,month:String,year:String,day:String,device:String,comments:String,paymentType:String,pickingInstruction:String,AddressID:String,deliveryTypeString:String,deliveryType:String,hour:String) -> [String:Any] {
        return ["total":[["total":total,"month":month,"year":year,"day":day,"device":device,"comments":comments,"paymentType":paymentType,"pickingInstruction":pickingInstruction,"AddressID":AddressID,"deliveryTypeString":deliveryTypeString,"deliveryType":deliveryType,"hour":hour,]]]
    
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    
    
}
 
    
    
    
    
    
    
