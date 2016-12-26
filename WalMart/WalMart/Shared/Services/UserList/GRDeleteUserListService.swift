//
//  GRDeleteUserListService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRDeleteUserListService: BaseService {

    var listId: String?
    
    func buildParams(_ idList:String) -> [String:Any]! {
        return ["idList":idList as Any]
    }
    
    func callService(_ params:[String : Any]?, successBlock:(([String : Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params!,
            successBlock: { (resultCall:[String : Any]) -> Void in
                successBlock?(resultCall)
                return
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

    
}
