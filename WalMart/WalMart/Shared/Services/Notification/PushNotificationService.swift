//
//  PushNotificationService.swift
//  WalMart
//
//  Created by Alonso Salcido on 09/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class PushNotificationService :  BaseService {
    
    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let empty:[String : Any] = [:]
        self.callGETService(empty as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
                print("Error PushNotificationService:;:::::::: \(error)")
        })
    }
    
    
}
