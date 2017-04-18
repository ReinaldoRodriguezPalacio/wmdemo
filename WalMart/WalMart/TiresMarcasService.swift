//
//  TiresMarcasService.swift
//  WalMart
//
//  Created by Vantis on 15/03/17.
//  Copyright © 2017 Vantis All rights reserved.
//

import UIKit
import CoreData

class TiresMarcasService: BaseService {
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let params: [String:Any] = [:]
        var marcas: [String] = []
        self.callGETService(params,
                            successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseArray"] as? [Any] {
                                    for idx in 0 ..< values.count {
                                        if let item = values[idx] as? [String:Any] {
                                            let marca = item["marca"] as? String
                                            if marca == nil {
                                                continue
                                            }
                                            marcas.append(marca!)
                                        }
                                    }
                                    UserDefaults.standard.setValue(marcas.sorted(), forKey: "marcas")
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
