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
    
    func callService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let afManager = getManager()
        self.setManagerTempHeader()
        self.callGETService(afManager,serviceURL:self.serviceUrl(),params:[:], successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    func setManagerTempHeader() {
        let timeInterval = NSDate().timeIntervalSince1970
        let timeStamp  = String(NSNumber(double:(timeInterval * 1000)).integerValue)
        let uuid  = NSUUID().UUIDString
        let strUsr  = "ff24423eefbca345" + timeStamp + uuid
        AFStatic.manager.requestSerializer!.setValue(timeStamp, forHTTPHeaderField: "timestamp")
        AFStatic.manager.requestSerializer!.setValue(uuid, forHTTPHeaderField: "requestID")
        AFStatic.manager.requestSerializer!.setValue(strUsr.sha1(), forHTTPHeaderField: "control")
    }
    
}