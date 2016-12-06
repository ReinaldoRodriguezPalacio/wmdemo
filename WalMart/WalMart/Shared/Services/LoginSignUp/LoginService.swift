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
    
    func buildParams(_ email:String,password: String) -> [String:Any] {
        let idDevice = UIDevice.current.identifierForVendor!.uuidString
        let lowCaseUser = email.lowercased()
        return ["email":lowCaseUser,"password":password,"identifierDevice":idDevice]
    }

    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
       let _ = self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                    let resultCallMG = resultCall

                    let grLoginService = GRLoginService()
                    grLoginService.callService(params, successBlock: { (resultCallGR:[String:Any]) -> Void in
                         UserCurrentSession.sharedInstance.createUpdateUser(resultCallMG, userDictionaryGR: resultCallGR)
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
    
    func callServiceByEmail(params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
      let _ = self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                    let resultCallMG = resultCall
                    
                    let grLoginWithEmailService = GRLoginWithEmailService()
                    grLoginWithEmailService.callService(["email":params["email"]!], successBlock: { (resultCallGR:[String:Any]) -> Void in
                        UserCurrentSession.sharedInstance.createUpdateUser(resultCallMG, userDictionaryGR: resultCallGR)
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
