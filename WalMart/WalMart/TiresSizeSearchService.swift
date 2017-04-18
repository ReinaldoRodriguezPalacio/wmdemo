//
//  TiresSizeSearchService.swift
//  WalMart
//
//  Created by Vantis on 15/03/17.
//  Copyright © 2017 Vantis All rights reserved.
//

import UIKit
import CoreData

class TiresSizeSearchService: BaseService {
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let params: [String:Any] = [:]
        self.callGETService(params,
                            successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseArray"] as? [Any] {
                                    UserDefaults.standard.setValue(values, forKey: "medidas")
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
