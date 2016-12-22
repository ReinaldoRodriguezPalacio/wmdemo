//
//  DefaultListService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 23/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class DefaultListService : BaseService {
    
    let fileName = "grdefaultlist.json"
    
    override init() {
        super.init()
        self.urlForSession = true
    }
    
    
    
    func callService(successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:],
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                self.saveDictionaryToFile(resultCall, fileName:self.fileName)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    
    func getDefaultContent() -> [[String:AnyObject]] {
        var response : [[String:AnyObject]] = []
        let values = self.getDataFromFile(self.fileName)
        if values != nil {
            response = values![JSON_KEY_RESPONSEARRAY] as! [[String:AnyObject]]
        }
        return response
    }

    
    
    
    
}