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
    
    func buildParams(email:String) -> NSDictionary {
        let lowCaseUser = email.lowercaseString
        return ["email":lowCaseUser]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            let newResultCall = NSMutableDictionary(dictionary: resultCall)
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                
            }
            successBlock!(newResultCall)
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