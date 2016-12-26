//
//  AutologinService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 22/12/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class AutologinService : BaseService {

    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    
    }
    
    
}