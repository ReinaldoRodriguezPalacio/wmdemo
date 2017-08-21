//
//  SEabcService.swift
//  WalMart
//
//  Created by Vantis on 18/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class SEabcService: BaseService {
    
    let fileName = "abc.json"
    
    
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService("", successBlock: { (resultCall:[String:Any]) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    
    func getAbcContent() -> [String:Any] {
        if let values = getDataFromFile(fileName as NSString) {
            if let grCategory = values["groceriescategoryproduct"] as? [String:Any] {
                return grCategory
            }
        }
        return [:]
    }
    
}
