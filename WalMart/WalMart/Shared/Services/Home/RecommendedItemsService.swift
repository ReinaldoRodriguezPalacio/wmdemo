//
//  RecommendedItemsService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class RecommendedItemsService : BaseService {
    
    let fileName = "recommended.json"
    let JSON_RECOMMENDED_ITEMS = "responseArray"

    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            NSNotificationCenter.defaultCenter().postNotificationName(UpdateNotification.HomeUpdateServiceEnd.rawValue, object: nil)
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    func getRecommendedContent() -> [[String:AnyObject]] {
        var response : [[String:AnyObject]] = []
        let values = getDataFromFile(fileName)
        if values != nil {
            if values!.count > 0 {
                response = values![JSON_RECOMMENDED_ITEMS] as! [[String:AnyObject]]
            }
        }
        return response
    }
    
}