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
    
    func buildParamsLine(familyId:String) -> NSDictionary {
        return ["id":familyId]
    }
    
    func callService(requestParams params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print("Call service :: ::LineService ")
        self.callPOSTService(buildParamsLine(params as! String), successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                print("Error LineService: \(error)")
                errorBlock!(error)
        }
    }
    
}