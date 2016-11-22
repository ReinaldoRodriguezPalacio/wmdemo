//
//  LoginWithEmail.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginWithEmailService : BaseService {
    
    var loginIdGR = ""
    
    
    func buildParams(_ email:String,password: String) -> [String:Any] {
        let lowCaseUser = email.lowercased()
        return ["email":lowCaseUser]
    }
  
   
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        if !UserCurrentSession.sharedInstance.userSignedOnService {
            UserCurrentSession.sharedInstance.userSignedOnService = true
            self.callPOSTService(params, successBlock: { (loginResult:[String:Any]) -> Void in
                self.jsonFromObject(loginResult as AnyObject!)
                if let codeMessage = loginResult["codeMessage"] as? NSNumber {
                    if codeMessage.intValue == 0 &&  UserCurrentSession.hasLoggedUser(){
                        let cadUserId : NSString? = UserCurrentSession.sharedInstance.userSigned!.idUser
                        if cadUserId != nil && cadUserId != "" && cadUserId?.length > 0 {
                            let idUser = loginResult["idUser"] as! String
                            
                            let profileService = UserProfileService()
                            profileService.callService(profileService.buildParams(idUser), successBlock:{ (resultCall:[String:Any]?) in
                                UserCurrentSession.sharedInstance.createUpdateUser(loginResult, profileResult: resultCall!)
                                successBlock!(resultCall!)
                                UserCurrentSession.sharedInstance.userSignedOnService = false
                                }
                                , errorBlock: {(error: NSError) in
                                    errorBlock!(error)
                                    UserCurrentSession.sharedInstance.userSignedOnService = false
                            })
                        }else {
                            UserCurrentSession.sharedInstance.userSigned = nil
                            UserCurrentSession.sharedInstance.deleteAllUsers()
                        }
                    }
                    else{
                        let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                        errorBlock!(errorDom)
                    }
                }
                }) { (error:NSError) -> Void in
                    errorBlock!(error)
                    UserCurrentSession.sharedInstance.userSignedOnService = false
            }
        } else {
            successBlock?([:])
        }
        
    }

    
    func callServiceForSocialApps(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                    let resultLogin = resultCall
                     let idUser = resultLogin["idUser"] as! String
                    let profileService = UserProfileService()
                    profileService.callService(profileService.buildParams(idUser), successBlock:{ (resultCall:[String:Any]?) in
                        UserCurrentSession.sharedInstance.createUpdateUser(resultLogin, profileResult: resultCall!)
                        successBlock!(resultCall!)
                        UserCurrentSession.sharedInstance.userSignedOnService = false
                        }
                        , errorBlock: {(error: NSError) in
                            errorBlock!(error)
                            UserCurrentSession.sharedInstance.userSignedOnService = false
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
