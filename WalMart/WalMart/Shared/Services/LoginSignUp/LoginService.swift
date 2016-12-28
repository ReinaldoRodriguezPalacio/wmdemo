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
        self.callPOSTService(params, successBlock: { (resultLoginCall:[String:Any]) -> Void in
            if let codeMessage = resultLoginCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                   var accessTokenVO =  resultLoginCall["accessTokenVO"] as! [String:Any]
                    print(accessTokenVO["refreshToken"] as! NSString)
                    print(accessTokenVO["accessToken"] as! NSString)
                    
                    CustomBarViewController.addOrUpdateParamNoUser(key: "ACCESS_TOKEN", value: accessTokenVO["accessToken"] as! String)
                    CustomBarViewController.addOrUpdateParamNoUser(key: "REFESH_TOKEN", value: accessTokenVO["accessToken"] as! String)

                   
                    // let resultLogin = resultCall
                    let idUser = resultLoginCall["idUser"] as! String
                    let profileService = UserProfileService()
                    profileService.callService(profileService.buildParams(idUser), successBlock: { (resultCall:[String:Any]) -> Void in
                        UserCurrentSession.sharedInstance.createUpdateUser(resultLoginCall, profileResult: resultCall)
                        successBlock!(resultCall)
                    }, errorBlock: { (errorGR:NSError) -> Void in
                        errorBlock!(errorGR)
                    })
                }else{
                    let error = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    errorBlock!(error)
                }
            }
            
        }, errorBlock: { (error:NSError) -> Void in
            errorBlock!(error)
        })
    }
    
 
}
