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
    
    
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    func getConfoigContent() -> [String:Any] {
        if let values = getDataFromFile(fileName as NSString) {
            if let grCategory = values["groceriescategoryproduct"] as? [String:Any] {
                return grCategory
            }
        }
        return [:]
    }
    
}
