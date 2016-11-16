//
//  GRDeleteItemListService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRDeleteItemListService: GRAddItemListService {

    func buildParams(_ upc:String?) -> [String:Any]! {
        //{"parameter":["0750179163767"]}
        return ["parameter":[upc!]]
    }
    
    func buildParamsArray(_ upcs:[String]?) -> [String:Any]! {
        return ["parameter":upcs! as AnyObject]
    }
    
    func buildDeleteItemMustang(repositoryId sku:String) -> [String:Any]!{
        return ["repositoryId":sku as AnyObject]
    }
    
    func buildDeleteItemMustangObject(idList:String, upcs:[String:Any]) -> [String:Any] {
        return ["idList":idList,"items":[upcs]]
    }
    
    
    override func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.jsonFromObject(params as AnyObject!)
        self.callPOSTService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
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
