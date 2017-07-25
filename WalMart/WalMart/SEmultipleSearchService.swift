//
//  SEmultipleSearchService.swift
//  WalMart
//
//  Created by Vantis on 24/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SEmultipleSearchService: BaseService {
    
    func callService(params: [String], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
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
    
    
}
