//
//  GRProductByTicket.swift
//  WalMart
//
//  Created by neftali on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRProductByTicket: GRBaseService {

    func buildParams(ticket:String) -> [String:AnyObject] {
        //{"number":"GQ9$JAQ+9B+-ORE5"}
        return ["number":ticket] as [String:AnyObject]
    }

    func callService(params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print(params)
        self.callPOSTService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

    override func validateCodeMessage(response:NSDictionary) -> NSError? {
        if let codeMessage = response["codeMessage"] as? NSNumber {
            let message = response["message"] as! NSString
            if codeMessage.integerValue == -12 {
                print("WARNING : Response with warning \(message)")
                return nil
            }
            if codeMessage.integerValue != 0 {
                print("ERROR : Response with error \(message)")
                return NSError(domain: ERROR_SERIVCE_DOMAIN, code: codeMessage.integerValue, userInfo: [NSLocalizedDescriptionKey:message])
            }
        }
        return nil
    }

    override func needsToLoginCode() -> Int {
        return -100
    }
    
    override func needsLogin() -> Bool {
        return true
    }

}
