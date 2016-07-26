//
//  UserProfileService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/07/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class UserProfileService : BaseService {
    
    func buildParams(idProfile:String) -> NSDictionary {
        return ["profileId":idProfile]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.integerValue == 0 {
                    successBlock!(resultCall)
                }
                else{
                    let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    //let message = resultCall["message"] as! String
                    //errorDom(message, forKey:codeMessage)
                    errorBlock!(errorDom)
                }
            }
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
}

