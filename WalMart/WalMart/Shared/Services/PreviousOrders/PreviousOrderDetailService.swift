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
    
    func callService(trackingNumber:String,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let serviceURL = serviceUrl() //"\(serviceUrl())/\(trackingNumber)" //QUITAR COMENTARIO
        self.callGETService(serviceURL,params:[:], successBlock: { (resultCall:NSDictionary) -> Void in
            let itemResult = resultCall[self.JSON_ORDERSDETAIL_RESULT] as! NSDictionary
            successBlock!(itemResult)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
        
    }
    
}