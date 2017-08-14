//
//  SEabcService.swift
//  WalMart
//
//  Created by Vantis on 18/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class SEabcService: BaseService {
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let params: [String:Any] = [:]
        self.callGETService(params,
                            successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["abclist"] as? [Any] {
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
