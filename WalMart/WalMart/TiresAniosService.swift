//
//  TiresAniosService.swift
//  WalMart
//
//  Created by Reinaldo Rodriguez Palacio on 18/03/17.
//  Copyright © 2017 Vantis All rights reserved.
//

import UIKit
import CoreData

class TiresAniosService: BaseService {
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        var anios:[String]=["2016"]
        UserDefaults.standard.setValue(anios, forKey: "anios")
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseArray"] as? [Any] {
                                    anios=[]
                                    for idx in 0 ..< values.count {
                                        if let item = values[idx] as? [String:Any] {
                                            anios = item["anos"] as! [String]
                                        }
                                    }
                                    UserDefaults.standard.setValue(anios.sorted(), forKey: "anios")
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
