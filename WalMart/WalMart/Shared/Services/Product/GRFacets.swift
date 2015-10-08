//
//  GRGetFacets.swift
//  WalMart
//
//  Created by Joel Juarez on 07/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRFacets : GRBaseService {
    
    func callService(storeId:String,stringSearch:String,idFamily:String, successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams: ["storeID":"","pText":stringSearch,"idFamily":idFamily,"idLine":""], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(requestParams params:AnyObject, successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            let arrayCall = resultCall["brands"] as! NSArray
            successBlock!(arrayCall)
            }) { (error:NSError) -> Void in
                print("Error: \(error)")
                errorBlock!(error)
        }
    }
    

}