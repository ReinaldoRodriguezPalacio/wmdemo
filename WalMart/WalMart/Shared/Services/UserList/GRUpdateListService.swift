//
//  GRUpdateListService.swift
//  WalMart
//
//  Created by neftali on 10/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUpdateListService: BaseService {
    
    func buildParams(_ idList:String,name:String) -> [String:Any] {

        return ["idList":idList,"newName":name]
    }

    func callService(_ params:AnyObject, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print(params)
        self.callPOSTService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
                //self.jsonFromObject(resultCall)
                successBlock?(resultCall as [String:Any])
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

}
