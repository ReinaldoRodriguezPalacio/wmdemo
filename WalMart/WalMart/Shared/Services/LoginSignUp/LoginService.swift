//
//  LoginService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class LoginService : BaseService {
    
    func buildParams(email:String,password: String) -> NSDictionary {
        let idDevice = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let lowCaseUser = email.lowercaseString
        return ["email":lowCaseUser,"password":password,"identifierDevice":idDevice]
    }

    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.integerValue == 0 {
                    let resultLogin = resultCall
                    let loginProfile = resultLogin["profile"] as! NSDictionary
                    let profileService = UserProfileService()
                    profileService.callService(profileService.buildParams(loginProfile["idUser"] as! String), successBlock: { (resultCall:NSDictionary) -> Void in
                         UserCurrentSession.sharedInstance().createUpdateUser(resultLogin, profileResult: resultCall)
                        successBlock!(resultCall)
                        }, errorBlock: { (errorGR:NSError) -> Void in
                            errorBlock!(errorGR)
                    })
                }
                else{
                    let error = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    errorBlock!(error)
                }
            }

            }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    override func shouldIncludeHeaders() -> Bool {
        return false
    }
    
}