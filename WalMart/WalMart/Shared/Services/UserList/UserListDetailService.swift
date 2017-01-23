//
//  UserListDetailService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 05/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class UserListDetailService: BaseService {
    
    
    func buildParams(_ idList:String) -> [String:Any] {
        return ["giftlistId":idList,"idStore":UserCurrentSession.sharedInstance.storeId == nil ? "" :UserCurrentSession.sharedInstance.storeId!]
    }
    
    
    func callService(_ params:AnyObject, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                let  responseObject  =  resultCall["giftlist"] as? [String:Any]
                                successBlock?(responseObject!)
                                return
            },
                             errorBlock: { (error:NSError) -> Void in
                                errorBlock?(error)
                                return
            }
        )
    }
    
    
    
}
