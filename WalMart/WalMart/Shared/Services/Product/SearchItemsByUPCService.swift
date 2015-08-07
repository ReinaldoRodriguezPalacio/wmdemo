//
//  SearchItemsByUPCService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class SearchItemsByUPCService : BaseService {
    
    func buildParams(upcs:[String]) -> [String:AnyObject] {
        return ["upc":upcs]
    }
    
    func callService(upcs:[String],successJSONBlock:((JSON) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        callPOSTService(buildParams(upcs), successBlock: { (result:NSDictionary) -> Void in
            
            
            var newItemsArray = Array<AnyObject>()
            if let items = result["responseArray"] as? NSArray {
                //println(items)
                self.saveKeywords(items) //Creating keywords
                for var idx = 0; idx < items.count; idx++ {
                    var item = items[idx] as! [String:AnyObject]
                    item["type"] = ResultObjectType.Mg.rawValue
                    newItemsArray.append(item)
                }
            }
            successJSONBlock!(JSON(newItemsArray))
            
            
        }, errorBlock: errorBlock)
        //callPOSTService(buildParams(upcs), successBlock: successBlock, errorBlock: errorBlock)
    }
    
}