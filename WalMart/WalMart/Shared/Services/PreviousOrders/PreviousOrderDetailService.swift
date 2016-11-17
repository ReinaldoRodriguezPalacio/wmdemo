//
//  PreviousOrderDetailService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class PreviousOrderDetailService : BaseService {
    
    let JSON_ORDERSDETAIL_RESULT = "responseObject"
    
    func callService(_ trackingNumber:String,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let serviceURL = serviceUrl() //"\(serviceUrl())/\(trackingNumber)" //QUITAR COMENTARIO
        let params: [[String:Any]] = []
        self.callGETService(serviceURL,params:params, successBlock: { (resultCall:[String:Any]) -> Void in
            let itemResult = resultCall[self.JSON_ORDERSDETAIL_RESULT] as! [String:Any]
            successBlock!(itemResult)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
        
    }
    
}
