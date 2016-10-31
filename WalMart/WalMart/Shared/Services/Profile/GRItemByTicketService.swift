//
//  File.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRItemByTicketService : GRBaseService {
    
    
    
    
    func buildParams(_ number:String) -> NSDictionary {
        return ["number":[["number":number]]]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    
    
}

    
    
    
    
    
    
    
    
    
