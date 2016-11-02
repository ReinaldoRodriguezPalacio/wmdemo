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
    
    func buildParams(_ email:String,password: String) -> NSDictionary {
        let idDevice = UIDevice.current.identifierForVendor!.uuidString
        let lowCaseUser = email.lowercased()
        return ["email":lowCaseUser,"password":password,"identifierDevice":idDevice]
    }

    func callService(_ params:NSDictionary,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                    let resultLogin = resultCall
                    let idUser = resultLogin["idUser"] as! String
                    let profileService = UserProfileService()
                    profileService.callService(profileService.buildParams(idUser), successBlock: { (resultCall:[String:Any]) -> Void in
                         UserCurrentSession.sharedInstance.createUpdateUser(resultLogin, profileResult: resultCall)
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
