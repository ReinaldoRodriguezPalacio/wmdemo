//
//  GRRecentProductsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRRecentProductsService : GRBaseService  {
    
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callGETService([:], successBlock: { (resultCall:[String:Any]) -> Void in
            self.jsonFromObject(resultCall)
            successBlock!(resultCall)
           
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    
}
