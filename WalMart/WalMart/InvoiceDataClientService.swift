//
//  InvoiceDataClientService.swift
//  WalMart
//
//  Created by Vantis on 02/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class InvoiceDataClientService : BaseService {
    
    let JSON_RESULT = "findClientByRfcResponse"
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let parameters : [String:Any] = ["findClientByRfcRequest" : params]
        self.setManagerTempHeader()
        self.callPOSTService(parameters,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                let values = resultCall["findClientByRfcResponse"] as! [String:Any]
                                
                                //print(headerData)
                                //print(businessData)
                                successBlock?(values)
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
