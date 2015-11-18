//
//  File.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 15/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRUpdateUserProfileService : GRBaseService {
    
    
    func buildParams(name:String,lastName:String,sex:String,birthDate:String,maritalStatus:String,profession:String,phoneWorkNumber:String,workNumberExtension:String,phoneHomeNumber:String,homeNumberExtension:String,cellPhone:String,allowMarketingEmail:String,user:String,password:String,newPassword:String,maximumAmount:Int) -> NSDictionary {
        return ["name":name, "lastName":lastName, "sex":sex, "birthDate":"01/01/0001", "maritalStatus":maritalStatus, "profession":profession,"phoneWorkNumber":phoneWorkNumber,"workNumberExtension":workNumberExtension,"phoneHomeNumber":phoneHomeNumber,"homeNumberExtension":homeNumberExtension,"cellPhone":cellPhone,"allowMarketingEmail":allowMarketingEmail, "isReply": "1","user":["password":password,"newPassword":newPassword,"maximumAmount":maximumAmount]]
        //New param :    device  descomentar en Desarrollo
//        return ["name":name, "lastName":lastName, "sex":sex, "birthDate":"01/01/0001", "maritalStatus":maritalStatus, "profession":profession,"phoneWorkNumber":phoneWorkNumber,"workNumberExtension":workNumberExtension,"phoneHomeNumber":phoneHomeNumber,"homeNumberExtension":homeNumberExtension,"cellPhone":cellPhone,"allowMarketingEmail":allowMarketingEmail, "isReply": "1","device": "11","user":["password":password,"newPassword":newPassword,"maximumAmount":maximumAmount]]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
    
    
}


