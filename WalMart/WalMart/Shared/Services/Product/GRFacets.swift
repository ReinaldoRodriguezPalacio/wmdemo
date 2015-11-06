//
//  GRGetFacets.swift
//  WalMart
//
//  Created by Joel Juarez on 07/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRFacets : GRBaseService {
    
    override init() {
        super.init()
        self.urlForSession = true
    }
    
    
    func callService(storeId:String,stringSearch:String,idFamily:String,idLine:String, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams: ["storeID":"","pText":stringSearch,"idFamily":idFamily,"idLine":idLine], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(requestParams params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                print("Error: \(error)")
                errorBlock!(error)
        }
    }
    

}