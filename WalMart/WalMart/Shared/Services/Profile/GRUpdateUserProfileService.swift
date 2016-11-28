//
//  File.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRUpdateUserProfileService : GRBaseService {
    
    
    func buildParams(_ name:String,lastName:String,sex:String,birthDate:String,maritalStatus:String,profession:String,phoneWorkNumber:String,workNumberExtension:String,phoneHomeNumber:String,homeNumberExtension:String,cellPhone:String,allowMarketingEmail:String,user:String,password:String,newPassword:String,maximumAmount:Int,device:String) -> [String:Any] {
        return ["name":name, "lastName":lastName, "sex":sex, "birthDate":birthDate, "maritalStatus":maritalStatus, "profession":profession,"phoneWorkNumber":phoneWorkNumber,"workNumberExtension":workNumberExtension,"phoneHomeNumber":phoneHomeNumber,"homeNumberExtension":homeNumberExtension,"cellPhone":cellPhone,"allowMarketingEmail":allowMarketingEmail, "isReply": "1","device":device,"user":["password":password,"newPassword":newPassword,"maximumAmount":maximumAmount]]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //jsonFromObject(params)
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
    
    
}


