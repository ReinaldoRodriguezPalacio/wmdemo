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
        var idDevice = UIDevice.currentDevice().identifierForVendor.UUIDString
        let lowCaseUser = email.lowercaseString
        return ["email":lowCaseUser,"password":password,"identifierDevice":idDevice]
    }

    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.integerValue == 0 {
                    var resultCallMG = resultCall

                    let grLoginService = GRLoginService()
                    grLoginService.callService(params, successBlock: { (resultCallGR:NSDictionary) -> Void in
                         UserCurrentSession.sharedInstance().createUpdateUser(resultCallMG, userDictionaryGR: resultCallGR)
                        successBlock!(resultCall)
                        }, errorBlock: { (errorGR:NSError) -> Void in
                            errorBlock!(errorGR)
                    })
                }
                else{
                    let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    let message = resultCall["message"] as String
                    var error = NSError()
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