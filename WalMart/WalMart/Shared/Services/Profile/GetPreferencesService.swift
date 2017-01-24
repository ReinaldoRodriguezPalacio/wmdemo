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
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        self.callPOSTService(["profileId":UserCurrentSession.sharedInstance.userSigned!.profile.idProfile] as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    
    func getLocalPreferences(_ successBlock:(([String:Any]) -> Void)?,errorBlock:((NSError) -> Void)?){
        
        let values = self.getDataFromFile(fileName as NSString)
        if values != nil {
               successBlock!(values!)
        }else{
            self.callService({ (result:[String:Any]) in
                  successBlock!(result)
                
                }, errorBlock: { (error:NSError) in
                 errorBlock!(error)
            })
        }

    }
    
}

