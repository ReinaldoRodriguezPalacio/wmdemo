//
//  GRDeleteItemListService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRDeleteItemListService: GRAddItemListService {

    func buildParams(upc:String?) -> [String:AnyObject]! {
        //{"parameter":["0750179163767"]}
        return ["parameter":[upc!]]
    }
    
    func buildParamsArray(upcs:[String]?) -> [String:AnyObject]! {
        return ["parameter":upcs!]
    }
    
    override func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                self.manageList(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

}
