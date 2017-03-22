//
//  GetShippingAddressService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class AddressByUserService : BaseService {
    
    let JSON_RESULT = "responseObject"
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        self.setManagerTempHeader()
        self.callGETService(afManager,serviceURL:self.serviceUrl(),params:[:], successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
//            successBlock!([:])
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    func setManagerTempHeader() {
        let timeInterval = Date().timeIntervalSince1970
        let timeStamp  = String(NSNumber(value: (timeInterval * 1000) as Double).intValue)
        let uuid  = UUID().uuidString
        let strUsr  = "ff24423eefbca345" + timeStamp + uuid
        AFStatic.manager.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
        AFStatic.manager.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
        AFStatic.manager.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control")
    }
    
}
