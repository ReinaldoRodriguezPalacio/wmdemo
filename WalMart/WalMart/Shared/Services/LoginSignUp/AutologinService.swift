//
//  AutologinService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 22/12/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class AutologinService : BaseService {

    
    func callService(params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService([:], successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    
    }
    
    
}
