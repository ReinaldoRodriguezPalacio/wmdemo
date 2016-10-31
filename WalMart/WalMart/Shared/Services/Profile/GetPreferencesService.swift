//
//  GetPreferencesService.swift
//  WalMart
//
//  Created by Joel Juarez on 03/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class GetPreferencesService : BaseService  {
    
    let fileName =  "preferences.json"
    
    func callService(_ successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([:], successBlock: { (resultCall:NSDictionary) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    
    func getLocalPreferences(_ successBlock:((NSDictionary) -> Void)?,errorBlock:((NSError) -> Void)?){
        
        let values = self.getDataFromFile(fileName)
        if values != nil {
               successBlock!(values!)
        }else{
            self.callService({ (result:NSDictionary) in
                  successBlock!(result)
                
                }, errorBlock: { (error:NSError) in
                 errorBlock!(error)
            })
        }

    }
    
}

