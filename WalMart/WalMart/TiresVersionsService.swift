//
//  TiresVersionsService.swift
//  WalMart
//
//  Created by Reinaldo Rodriguez Palacio on 21/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class TiresVersionsService: BaseService {
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        var versiones:[String]=[]
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseObject"] as? [Any] {
                                    for idx in 0 ..< values.count {
                                        if let item = values[idx] as? [String:Any] {
                                            let version = item["version"] as? String
                                            if version == nil {
                                                continue
                                            }
                                            versiones.append(version!)
                                        }
                                    }
                                    UserDefaults.standard.setValue(versiones.sorted(), forKey: "versiones")
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
