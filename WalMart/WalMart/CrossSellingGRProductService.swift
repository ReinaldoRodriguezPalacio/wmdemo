//
//  CrossSellingGRProductService.swift
//  WalMart
//
//  Created by Vantis on 27/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//
import Foundation


class CrossSellingGRProductService : BaseService {
    
    let JSON_CROSSSELL_RESULT = "responseArray"
    
    func callService(_ UPC:String,successBlock:(([[String:Any]]?) -> Void)?, errorBlock:((NSError) -> Void)?) {
        let UPC: AnyObject? = nil
        self.callService(requestParams:UPC as AnyObject,successBlock: successBlock, errorBlock: errorBlock)
    }
    
    
    func callService(requestParams params:Any,successBlock:(([[String:Any]]?) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let resultObject =  resultCall["upcs"] as? [[String:Any]] {
                successBlock!(resultObject)
                return
            }
            successBlock!(nil)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
}
