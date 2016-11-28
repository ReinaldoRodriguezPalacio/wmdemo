//
//  CrossSellingProductService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class CrossSellingProductService : BaseService {
    
    let JSON_CROSSSELL_RESULT = "responseArray"
    
    func callService(_ UPC:String,successBlock:((NSArray?) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams:UPC as AnyObject,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSArray?) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let resultObject =  resultCall[self.JSON_CROSSSELL_RESULT] as? NSArray {
                successBlock!(resultObject)
                return
            }
            successBlock!(nil)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}
