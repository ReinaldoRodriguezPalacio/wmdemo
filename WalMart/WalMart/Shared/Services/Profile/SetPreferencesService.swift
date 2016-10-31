//
//  SetPreferencesService.swift
//  WalMart
//
//  Created by Joel Juarez on 03/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

enum OnlyAlertPreferences : String {
    case onlySubstituteAvailable =  "onlySubstituteAvailable"
    case onlyOrderedProducts = "onlyOrderedProducts"
    case receiveCallConfirmation = "receiveCallConfirmation"
}


class SetPreferencesService : BaseService {
    
    
    func buildParams(_ userPreferences:NSArray,onlyTelephonicAlert:String,abandonCartAlert:Bool,telephonicSmsAlert:Bool,mobileNumber:String,receivePromoEmail:String,forOBIEE:Bool,acceptConsent:Bool,receiveInfoEmail:Bool) -> NSDictionary {
        
        return ["userPreferences":userPreferences, "onlyTelephonicAlert":onlyTelephonicAlert,"abandonCartAlert":abandonCartAlert,"telephonicSmsAlert":telephonicSmsAlert,"mobileNumber":mobileNumber,"receivePromoEmail":receivePromoEmail,"forOBIEE":forOBIEE,"acceptConsent":acceptConsent,"receiveInfoEmail":receiveInfoEmail]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            self.getPreferences({ (result:NSDictionary) in
                successBlock!(resultCall)
            })
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    
    func getPreferences(_ successBlock:((NSDictionary) -> Void)?){
        let servicePreference  = GetPreferencesService()
        servicePreference.callService({ (result:NSDictionary) in
            successBlock!(result)
        }, errorBlock: { (error:NSError) in
            
        })
        
        
    }
}
