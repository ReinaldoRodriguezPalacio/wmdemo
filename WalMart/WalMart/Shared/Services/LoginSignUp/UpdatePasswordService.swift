//
//  UpdatePasswordService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 04/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class UpdatePasswordService : BaseService {
    
    func buildParams(_ password:String,newPassword:String) -> [String:Any] {
        return ["password":password,"newPassword":newPassword]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                    successBlock!(resultCall)
                }
                else{
                    let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    errorBlock!(errorDom)
                }
            }
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
}
