//
//  GRProductDetailService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class GRProductDetailService : GRBaseService {
    var useSignals = false
    
    override init() {
        super.init()
        self.urlForSession = true
        self.useSignalsServices = self.useSignals
        print(self.useSignals)
    }
    
    init(dictionary:NSDictionary){
        super.init()
        self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    
    let JSON_PRODUCTDETAIL_RESULT = "responseObject"
    
    func callService(UPC:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams:UPC,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            //let resultObject = resultCall[self.JSON_PRODUCTDETAIL_RESULT] as NSDictionary
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsLogin() -> Bool {
        return false
    }
  

    
}