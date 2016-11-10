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

    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
                            successBlock: { (resultCall:NSDictionary) -> Void in
                                self.jsonFromObject(resultCall)
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