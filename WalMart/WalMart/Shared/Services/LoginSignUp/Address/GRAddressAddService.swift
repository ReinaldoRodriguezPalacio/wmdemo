//
//  GRAddressAddService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressAddService : GRBaseService {
    
    func buildParams(_ city:String,addressID:String,zipCode:String,street:String,innerNumber:String,state:String,county:String,neighborhoodID:String,phoneNumber:String,outerNumber:String,adName:String,reference1:String,reference2:String,storeID:String,storeName:String,operationType:String,preferred:Bool) -> NSMutableDictionary {

        return ["Name":adName, "State":state, "ZipCode":zipCode, "City":city, "County":county, "Street":street, "OuterNumber":outerNumber, "InnerNumber":innerNumber, "preferred":preferred,  "AddressID": addressID, "StoreID":storeID, "NeighborhoodID":neighborhoodID,"phoneNumber":phoneNumber, "Reference1":reference1, "Reference2":reference2, "operationType":operationType, "storeName":storeName]
       
    }
    
    func buildParamsPreferred(_ addressID:String,operationType:String,preferred:Bool) -> NSDictionary {
        return [ "preferred":preferred,  "AddressID": addressID,  "operationType":operationType]
    }
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsLogin() -> Bool {
        return false
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
    
}
