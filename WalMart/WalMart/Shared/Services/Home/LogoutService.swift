//
//  LogoutService.swift
//  WalMart
//
//  Created by Orlando on 09/11/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class LogoutService : BaseService {
    
    let fileName = "logout.json"

    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
                            successBlock: { (resultCall:[String:Any]) -> Void in
                                self.jsonFromObject(resultCall as AnyObject!)
                                self.saveDictionaryToFile(resultCall, fileName:self.fileName)
                                successBlock?(resultCall)

                                return
            },
                            errorBlock: { (error:NSError) -> Void in
                                errorBlock?(error)
                                return
            }
        )
    }
    
    
    
}
