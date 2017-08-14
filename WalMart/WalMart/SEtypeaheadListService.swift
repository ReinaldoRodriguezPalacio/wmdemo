//
//  SEtypeaheadListService.swift
//  WalMart
//
//  Created by Vantis on 18/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SEtypeaheadListService: BaseService {
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
                            successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["searchTerms"] as? [Any] {
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
