//
//  LogoutService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 27/01/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class LogoutService : BaseService {
    
    
    func callService(params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
        
    }
    
    
}
