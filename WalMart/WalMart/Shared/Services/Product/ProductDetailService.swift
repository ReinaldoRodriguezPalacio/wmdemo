//
//  ProductService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailService : BaseService {
    
    let JSON_PRODUCTDETAIL_RESULT = "responseObject"
    var useSignals = false
    
    init(dictionary:NSDictionary){
        super.init()
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    
    func callService(UPC:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams:UPC,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            let resultObject = resultCall[self.JSON_PRODUCTDETAIL_RESULT] as! NSDictionary
            successBlock!(resultObject)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}
