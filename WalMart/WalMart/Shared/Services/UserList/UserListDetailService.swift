//
//  UserListDetailService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 05/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class UserListDetailService: GRBaseService {
    
    
    func buildParams(_ idList:String) -> [String:Any] {
        return ["giftlistId":idList]
    }
    
    
    func callService(_ params:AnyObject, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                let  responseObject  =  resultCall["responseObject"] as? [String:Any]
                                successBlock?(responseObject!["giftlist"] as! [String:Any])
                                return
            },
                             errorBlock: { (error:NSError) -> Void in
                                errorBlock?(error)
                                return
            }
        )
    }
    
    
    
}
