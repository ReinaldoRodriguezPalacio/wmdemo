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
    
    
    func buildParams(_ userPreferences:[String],onlyTelephonicAlert:String,abandonCartAlert:Bool,telephonicSmsAlert:Bool,mobileNumber:String,receivePromoEmail:String,forOBIEE:Bool,acceptConsent:Bool,receiveInfoEmail:Bool) -> [String:Any] {
        
        return ["userPreferences":userPreferences, "onlyTelephonicAlert":onlyTelephonicAlert,"abandonCartAlert":abandonCartAlert,"telephonicSmsAlert":telephonicSmsAlert,"mobileNumber":mobileNumber,"receivePromoEmail":receivePromoEmail,"forOBIEE":forOBIEE,"acceptConsent":acceptConsent,"receiveInfoEmail":receiveInfoEmail]
    }
    
    
    func callService(requestParams params:AnyObject,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in

            self.getPreferences({ (result:[String : Any]) in
                successBlock!(resultCall)
            }, errorBlock: { (error:NSError) in
                 errorBlock!(error)
            })
            
        }) { (error:NSError) -> Void in
            errorBlock!(error)
        }
    }
    
    
    func getPreferences(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ){
        let servicePreference  = GetPreferencesService()
        servicePreference.callService({ (result:[String:Any]) in
            successBlock!(result)
        }, errorBlock: { (error:NSError) in
            errorBlock!(error)
        })
        
        
    }
}
