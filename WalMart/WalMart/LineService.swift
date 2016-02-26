//
//  LineService.swift
//  WalMart
//
//  Created by Joel Juarez on 25/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class LineService : BaseService {
    
    override init() {
        super.init()
    }
    
    func callService(requestParams params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params)
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                print("Error LineService: \(error)")
                errorBlock!(error)
        }
    }
    
}