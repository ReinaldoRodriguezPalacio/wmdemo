//
//  TiresModelsService.swift
//  WalMart
//
//  Created by Vantis on 15/03/17.
//  Copyright © 2017 Vantis All rights reserved.
//

import UIKit
import CoreData

class TiresModelsService: BaseService {
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        var models:[String]=[]
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
