//
//  GRCategoryService.swift
//  WalMart
//
//  Created by neftali on 22/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class GRCategoryService: GRBaseService {
    let fileName = "grcategories.json"
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                self.saveDictionaryToFile(resultCall, fileName:self.fileName)
                successBlock?(resultCall)
                 self.loadKeyFieldCategories( resultCall[JSON_KEY_RESPONSEARRAY] as! [[String:AnyObject]], type: ResultObjectType.Groceries.rawValue);
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

    
    func getCategoriesContent() -> [[String:AnyObject]] {
        var response : [[String:AnyObject]] = []
        let values = self.getDataFromFile(self.fileName)
        if values != nil {
            response = values![JSON_KEY_RESPONSEARRAY] as! [[String:AnyObject]]
            response.sortInPlace({ (one:[String : AnyObject], second:[String : AnyObject]) -> Bool in
                let firstString = one["description"] as! String?
                let secondString = second["description"] as! String?
                return firstString!.localizedCaseInsensitiveCompare(secondString!) == NSComparisonResult.OrderedAscending
            })
        }
        return response
    }

    
}
