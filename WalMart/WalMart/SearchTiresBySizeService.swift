//
//  SearchTiresBySizeService.swift
//  WalMart
//
//  Created by Vantis on 16/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class SearchTiresBySizeService: BaseService {
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseObject"] as? [Any] {
                                    
                                    //UserDefaults.standard.setValue(modelos, forKey: "modelos")
                                    //UserDefaults.standard.setValue(modandyears, forKey: "aniosBymodel")
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

