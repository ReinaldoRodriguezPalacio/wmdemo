//
//  ProductService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailService : BaseService {
     var useSignals = false
    let JSON_PRODUCTDETAIL_RESULT = "responseObject"
    
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
    


    func buildParams(upc:String,collection:String) -> AnyObject{
        if useSignalsServices {
            let channel = IS_IPAD ? "ipad" : "iphone"
            return ["upc":upc,"params":["eventtype": "pdpview","collection":collection,"channel": channel]]
        }
        return upc
    }
    
    func callService(UPC:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams:UPC,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print("BEFORE CALLSERVICE::")
        self.jsonFromObject(params)
        
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            let resultObject = resultCall[self.JSON_PRODUCTDETAIL_RESULT] as! NSDictionary
            successBlock!(resultObject)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}
