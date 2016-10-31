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
    
    func buildParams(_ idProfile:String) -> NSDictionary {
        return ["profileId":idProfile]
    }
    
    func callService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService([], successBlock: { (resultCall:NSDictionary) -> Void in
            
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                    successBlock!(resultCall)
                }
                else{
                    let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    errorBlock!(errorDom)
                }
            }
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
}

