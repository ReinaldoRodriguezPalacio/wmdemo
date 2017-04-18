//
//  TiresMedidasSearchService.swift
//  WalMart
//
//  Created by Vantis on 21/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class TiresMedidasSearchService: BaseService {
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        var medidas:[String]=[]
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseObject"] as? [Any] {
                                    for idx in 0 ..< values.count {
                                        if let item = values[idx] as? [String:Any] {
                                            let medida = item["medida"] as? String
                                            if medida == nil {
                                                continue
                                            }
                                            medidas.append(medida!)
                                        }
                                    }
                                    UserDefaults.standard.setValue(medidas.sorted(), forKey: "medidas")
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
