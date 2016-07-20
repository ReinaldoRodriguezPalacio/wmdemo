//
//  RegistryService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class SignUpService : BaseService {
    
    func buildParamsWithMembershipAndBirthDate(username:String,password: String,name:String,lastName:String,allowMarketingEmail:String,birthdate:String,gender:String,allowTransfer:String) -> NSDictionary {
        let lowCaseUser = username.lowercaseString
        return ["email":lowCaseUser,"password":password,"profile":["name":name,"lastName":lastName,"allowMarketingEmail":"\(allowMarketingEmail)","birthdate":birthdate,"gender":gender,"allowTransfer":allowTransfer]]
    }
    
    func buildParamsWithMembership(username:String,password: String,name:String,lastName:String,allowMarketingEmail:String,allowTransfer:String) -> NSDictionary {
        let lowCaseUser = username.lowercaseString
        return ["email":lowCaseUser,"password":password,"profile":["name":name,"lastName":lastName,"allowMarketingEmail":"\(allowMarketingEmail)","allowTransfer":allowTransfer]]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}