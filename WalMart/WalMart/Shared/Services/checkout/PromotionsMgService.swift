//
//  PromotionsMgService.swift
//  WalMart
//
//  Created by Joel Juarez on 28/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation



class PromotionsMgService : BaseService {
    
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            
            successBlock!(resultCall)
            
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}
