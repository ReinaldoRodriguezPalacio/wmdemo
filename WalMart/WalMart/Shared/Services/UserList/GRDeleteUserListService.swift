//
//  GRDeleteUserListService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRDeleteUserListService: GRBaseService {

    var listId: String?

    func buildParams(_ idList:String?) {
        self.listId = idList
    }
    
    func callService(_ params:[String:Any]?, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callGETService([:],
            successBlock: { (resultCall:[String:Any]) -> Void in
                successBlock?(resultCall)
                return
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

    override func serviceUrl() -> String {
        return super.serviceUrl() + "/"  + self.listId!
    }

}
