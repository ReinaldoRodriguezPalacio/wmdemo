//
//  DefaultListService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 23/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class DefaultListService : GRBaseService {
    
    let fileName = "grdefaultlist.json"
    
    override init() {
        super.init()
        self.urlForSession = true
    }
    
    
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:],
            successBlock: { (resultCall:[String:Any]) -> Void in
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
    
    
    func getDefaultContent() -> [Any] {
        var response : [Any] = []
        let values = self.getDataFromFile(self.fileName as NSString)
        if values != nil {
            response = values![JSON_KEY_RESPONSEARRAY] as! [Any]
        }else{
          self.callService({ (responses:[String : Any]) in
            response = self.getDefaultContent()
          }, errorBlock: { (error:NSError) in
            
          })
        }
      
        return response
    }

    
    
    
    
}
