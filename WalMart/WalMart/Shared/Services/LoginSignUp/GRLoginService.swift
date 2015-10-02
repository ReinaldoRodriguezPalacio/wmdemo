//
//  GRLoginService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class GRLoginService : GRBaseService {
    
    func buildParams(email:String,password: String) -> NSDictionary {
        let idDevice = UIDevice.currentDevice().identifierForVendor!.UUIDString
        return ["email":email,"password":password,"identifierDevice":idDevice]
    }
    
    func buildParamsUserId() -> NSDictionary {
        return ["email":"","password":"","idUser":UserCurrentSession.sharedInstance().userSigned!.idUserGR]
    }

    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            let newResultCall = NSMutableDictionary(dictionary: resultCall)
            successBlock!(newResultCall)
           // successBlock!(resultCall)
            
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    override func needsLogin() -> Bool {
            return false
    }
    
    
}