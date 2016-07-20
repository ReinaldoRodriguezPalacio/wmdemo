//
//  LoginWithEmail.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class LoginWithEmailService : BaseService {
    
    var loginIdGR = ""
    
    
    func buildParams(email:String,password: String) -> NSDictionary {
        let lowCaseUser = email.lowercaseString
        return ["email":lowCaseUser]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !UserCurrentSession.sharedInstance().userSignedOnService {
            UserCurrentSession.sharedInstance().userSignedOnService = true
            self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                    if codeMessage.integerValue == 0 &&  UserCurrentSession.hasLoggedUser(){
                        let resultCallMG = resultCall
                        let cadUserId : NSString? = UserCurrentSession.sharedInstance().userSigned!.idUserGR
                        if cadUserId != nil && cadUserId != "" && cadUserId?.length > 0 {
                            let serviceGr = GRLoginService()
                            serviceGr.callService(serviceGr.buildParamsUserId(), successBlock:{ (resultCall:NSDictionary?) in
                                UserCurrentSession.sharedInstance().createUpdateUser(resultCallMG, userDictionaryGR: resultCall!)
                                successBlock!(resultCall!)
                                UserCurrentSession.sharedInstance().userSignedOnService = false
                                }
                                , errorBlock: {(error: NSError) in
                                    errorBlock!(error)
                                    UserCurrentSession.sharedInstance().userSignedOnService = false
                            })
                        }else {
                            UserCurrentSession.sharedInstance().userSigned = nil
                            UserCurrentSession.sharedInstance().deleteAllUsers()
                        }
                    }
                    else{
                        let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                        //let message = resultCall["message"] as! String
                        //let error = NSError()
                        //error.setValue(message, forKey:codeMessage)
                        errorBlock!(errorDom)
                    }
                }
                }) { (error:NSError) -> Void in
                    errorBlock!(error)
                    UserCurrentSession.sharedInstance().userSignedOnService = false
            }
        } else {
            successBlock?([:])
        }
        
    }

    
    func callServiceForSocialApps(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.integerValue == 0 {
                    let resultCallMG = resultCall
                    let serviceGr = GRLoginService()
                    serviceGr.callService(["email":"","password":"","idUser":resultCall["idUser"] as! String], successBlock:{ (resultCall:NSDictionary?) in
                        UserCurrentSession.sharedInstance().createUpdateUser(resultCallMG, userDictionaryGR: resultCall!)
                        successBlock!(resultCall!)
                        UserCurrentSession.sharedInstance().userSignedOnService = false
                        }
                        , errorBlock: {(error: NSError) in
                            errorBlock!(error)
                            UserCurrentSession.sharedInstance().userSignedOnService = false
                    })                }
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