//
//  File.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRAddressUpdateService : BaseService {
    
    func buildParams(_ city:String,addressID:String,zipCode:String,street:String,innerNumber:String,state:String,county:String,neighborhoodID:String,phoneNumber:String, name:String,lastName:String,outerNumber:String,reference1:String,reference2:String,storeID:String,operationType:String,preferred:String) -> [String:Any] {

        return ["city":city,"addressID":addressID,"street":street,"innerNumber":innerNumber,"state":state,"county":county,"neighborhoodID":neighborhoodID,"phoneNumber":phoneNumber,"user":[ "profile" : ["name":name,"lastName":lastName]],"outerNumber":outerNumber,"reference1":reference1,"reference2":reference2,"storeID":storeID,"operationType":operationType,"preferred":preferred]
    }
    
    func callService(requestParams params:AnyObject,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}
