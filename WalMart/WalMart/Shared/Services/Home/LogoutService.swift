//
//  LogoutService.swift
//  WalMart
//
//  Created by Orlando on 09/11/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class LogoutService : BaseService {

    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
                            successBlock: { (resultCall:[String:Any]) -> Void in
                                self.jsonFromObject(resultCall as AnyObject!)
                                UserDefaults.standard.removeObject(forKey: "JSESSIONID")
                                UserDefaults.standard.removeObject(forKey: "JSESSIONIDMG")
                                UserDefaults.standard.removeObject(forKey: "JSESSIONIDGR")
                                successBlock?(resultCall)
                                return
            },
                            errorBlock: { (error:NSError) -> Void in
                                errorBlock?(error)
                                return
            }
        )
    }
    
    
    
}
