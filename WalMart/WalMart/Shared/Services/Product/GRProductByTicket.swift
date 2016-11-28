//
//  GRProductByTicket.swift
//  WalMart
//
//  Created by neftali on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRProductByTicket: GRBaseService {

    func buildParams(_ ticket:String) -> [String:Any] {
        //{"number":"GQ9$JAQ+9B+-ORE5"}
        return ["number":ticket] as [String:Any]
    }

    func callService(_ params:AnyObject, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print(params)
        self.callPOSTService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
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

    override func validateCodeMessage(_ response:[String:Any]) -> NSError? {
        if let codeMessage = response["codeMessage"] as? NSNumber {
            let message = response["message"] as! NSString
            if codeMessage.intValue == -12 {
                print("WARNING : Response with warning \(message)")
                return nil
            }
            if codeMessage.intValue != 0 {
                print("ERROR : Response with error \(message)")
                return NSError(domain: ERROR_SERIVCE_DOMAIN, code: codeMessage.intValue, userInfo: [NSLocalizedDescriptionKey:message])
            }
        }
        return nil
    }

    override func needsToLoginCode() -> Int {
        return -1005
    }

}
