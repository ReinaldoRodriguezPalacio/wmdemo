//
//  OccupationsService.swift
//  WalMart
//
//  Created by Ingenieria de Soluciones on 05/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class OccupationsService : BaseService {
    
    

    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([], successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    

}