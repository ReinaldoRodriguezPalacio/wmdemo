//
//  RegistryService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class SignUpService : BaseService {
    
    func buildParamsWithMembershipAndBirthDate(_ username:String,password: String,name:String,lastName:String,allowMarketingEmail:String,birthdate:String,gender:String,allowTransfer:String) -> [String:Any] {
        let lowCaseUser = username.lowercased()
        return ["email":lowCaseUser,"password":password,"firstName":name,"lastName":lastName,"allowMarketingEmail":allowMarketingEmail == "true" ? "Si":"No","forOBIEE":allowTransfer,"birthdate":birthdate,"gender":gender]
    }
    
    func buildParamsWithMembership(_ username:String,password: String,name:String,lastName:String,allowMarketingEmail:String,allowTransfer:String) -> [String:Any] {
        let lowCaseUser = username.lowercased()
        return ["email":lowCaseUser,"password":password,"firstName":name,"lastName":lastName,"allowMarketingEmail":allowMarketingEmail == "true" ? "Si":"No","forOBIEE":allowTransfer == "true" ? "Si":"No"]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}
