//
//  SEmultipleSearchListService.swift
//  WalMart
//
//  Created by Vantis on 24/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SEmultipleSearchListService: BaseService {
    
    func callService(params: [String], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.setManagerTempHeader()
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseArray"] as? [Any] {
                                     print(values)
                                }
                                successBlock?(resultCall)
                                return
        }, errorBlock: { (error:NSError) -> Void in
            errorBlock?(error)
            return
        }
        )
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
