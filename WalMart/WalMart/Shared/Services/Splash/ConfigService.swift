//
//  ConfigService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/19/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ConfigService : BaseService {
        
    let fileName = "confog.json"
    
    
    
    func callService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    func getConfoigContent() -> [String:AnyObject] {
        let values = getDataFromFile(fileName) as? [String:AnyObject]
        if let grCategory = values?["groceriescategoryproduct"] as? [String:AnyObject] {
            return grCategory
        }
        return [:]
    }
    
}
