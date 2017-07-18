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
        var models:[String] = []
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseArray"] as? [Any] {
                                    for idx in 0 ..< values.count {
                                        if let item = values[idx] as? [String:Any] {
                                            let modelo = item["modelo"] as? String
                                            if modelo == nil {
                                                continue
                                            }
                                            models.append(modelo!)
                                        }
                                    }
                                    UserDefaults.standard.setValue(models.sorted(), forKey: "modelos")
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
