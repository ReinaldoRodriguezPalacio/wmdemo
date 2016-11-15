//
//  OccupationsService.swift
//  WalMart
//
//  Created by Ingenieria de Soluciones on 05/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class OccupationsService : BaseService {
    
    

    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let empty: [String:Any] = [:]
            self.callGETService(empty as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    

}
