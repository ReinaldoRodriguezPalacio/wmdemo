//
//  GRTimeBands.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 19/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRTimeBands: BaseService {
    
    func buildParams(date:String,addressId:String) -> NSDictionary {
        return ["date":date,"addressId":addressId,"channelType":"20"]
    }
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
          self.jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
           
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }


}





