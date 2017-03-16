//
//  GRLoginWithEmailService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/21/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRLoginWithEmailService : GRBaseService {

    var loginIdGR = ""
    
    func buildParams(_ email:String) -> [String:Any] {
        let lowCaseUser = email.lowercased()
        return ["email":lowCaseUser]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
   
    
    override func shouldIncludeHeaders() -> Bool {
        return false
    }
    
    override func needsLogin() -> Bool {
        return false
    }
    
}
