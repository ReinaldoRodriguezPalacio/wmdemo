//
//  UserListDetailService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 05/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class UserListDetailService: BaseService {
    
    
    func buildParams(idList:String) -> NSDictionary {
        return ["giftlistId":idList]
    }
    
    
    func callService(params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params,
                             successBlock: { (resultCall:NSDictionary) -> Void in
                                let  responseObject  =  resultCall["responseObject"] as? NSDictionary
                                successBlock?(responseObject!["giftlist"] as! NSDictionary)
                                return
            },
                             errorBlock: { (error:NSError) -> Void in
                                errorBlock?(error)
                                return
            }
        )
    }
    
    
    
}