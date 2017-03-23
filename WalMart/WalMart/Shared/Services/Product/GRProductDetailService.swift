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
    
    init(dictionary:[String:Any]){
        super.init()
        self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    
    let JSON_PRODUCTDETAIL_RESULT = "responseObject"
    
    func buildParams(_ upc:String,eventtype:String,stringSearch:String,position:String) -> Any{
        if useSignalsServices {
            let channel = IS_IPAD ? "ipad" : "iphone"
            return ["upc":upc,"parameter":["eventtype": eventtype,"collection":"dah","channel": channel,"q":stringSearch,"position":position]]
        }
        return upc
    }
    
    func callService(_ UPC:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams:UPC as AnyObject,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:Any,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            //let resultObject = resultCall[self.JSON_PRODUCTDETAIL_RESULT] as [String:Any]
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsLogin() -> Bool {
        return false
    }
  

    
}
