//
//  RegistryService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class SignUpService : BaseService {
    
    func buildParamsWithMembership(_ username:String,password:String,name:String,lastName:String,allowMarketingEmail:String,birthdate:String,gender:String,allowTransfer:String,phoneHomeNumber:String,phoneWorkNumber:String,cellPhone:String) -> [String:Any] {
        
        print("***************************************************************")
        print(username)
        print(password)
        print(name)
        print(lastName)
        print(allowMarketingEmail)
        print(birthdate)
        print(gender)
        print(allowTransfer)
        print(phoneHomeNumber)
        print(phoneWorkNumber)
        print(cellPhone)
        print("***************************************************************")
        
        let lowCaseUser = username.lowercased()
        return ["email":lowCaseUser,"password":password,"profile":["name":name,"lastName":lastName,"allowMarketingEmail":"\(allowMarketingEmail)","birthdate":birthdate,"gender":gender,"allowTransfer":allowTransfer,"phoneHomeNumber":phoneHomeNumber,"phoneWorkNumber":phoneWorkNumber,"cellPhone":cellPhone]]
    }

    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
}
