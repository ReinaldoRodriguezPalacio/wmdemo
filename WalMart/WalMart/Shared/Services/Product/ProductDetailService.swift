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
    
    init(dictionary:[String:Any]){
        super.init()
        self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    


    func buildParams(_ upc:String,eventtype:String,stringSearching:String,position:String) -> AnyObject{
        if useSignalsServices {
            let channel = IS_IPAD ? "ipad" : "iphone"
            return ["upc":upc,"parameter":["eventtype": eventtype,"collection":"mg","channel": channel,"q":stringSearching,"position":position]]
        }
        return upc as AnyObject
    }
    
    func callService(_ UPC:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams:UPC as AnyObject,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print("BEFORE CALLSERVICE::")
        //self.jsonFromObject(params)
        
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            let resultObject = resultCall[self.JSON_PRODUCTDETAIL_RESULT] as! [String:Any]
            successBlock!(resultObject)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}
