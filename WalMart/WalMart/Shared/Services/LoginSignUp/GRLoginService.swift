//
//  GRLoginService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class GRLoginService : GRBaseService {
    
    func buildParams(_ email:String,password: String) -> [String:Any] {
        let idDevice = UIDevice.current.identifierForVendor!.uuidString
        return ["email":email,"password":password,"identifierDevice":idDevice]
    }
    
    func buildParamsUserId() -> [String:Any] {
        return ["email":"","password":"","idUser":UserCurrentSession.sharedInstance.userSigned!.idUserGR]
    }

    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            self.jsonFromObject(resultCall)

            let newResultCall =  resultCall
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
