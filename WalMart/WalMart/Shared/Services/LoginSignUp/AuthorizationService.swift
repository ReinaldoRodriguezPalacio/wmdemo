//
//  AuthorizationService.swift
//  WalMart
//
//  Created by Joel Juarez on 24/11/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import AFNetworking


class AuthorizationService : GRBaseService {
    
    
    override func callGETService(_ params: Any, successBlock: (([String:Any]) -> Void)?, errorBlock: ((NSError) -> Void)?) {
        super.callGETService(params, successBlock: { (response:[String:Any]) in
            print("ok Response Service")
            successBlock!(response)
        }, errorBlock: { (error:NSError) in
            print("ERROR:: \(error.localizedDescription)")
            errorBlock!(error)
        })
        
    }
    
    
    override func getManager() -> AFHTTPSessionManager {
        
        var jsessionIdSend = ""
        var jSessionAtgIdSend = UserCurrentSession.sharedInstance.JSESSIONATG
        
        
        if let param1 = CustomBarViewController.retrieveParamNoUser(key: "JSESSIONID") {
            //print("PARAM JSESSIONID ::"+param1.value)
            jsessionIdSend = param1.value
        }
        if let param2 = CustomBarViewController.retrieveParamNoUser(key: "JSESSIONATG") {
            //print("PARAM JSESSIONATG ::" + param2.value)
            jSessionAtgIdSend = param2.value
        }
        
        
        if UserCurrentSession.hasLoggedUser() && shouldIncludeHeaders() {
            
            let timeInterval = NSDate().timeIntervalSince1970
            let timeStamp  = String(NSNumber(value:(timeInterval * 1000)).intValue) // Time in milis "1400705132881"//
            let uuid  = NSUUID().uuidString //"e0fe3951-963e-4edf-a655-4ec3922b1116"//
            let strUsr  = "ff24423eefbca345" + timeStamp + uuid // "f3062afbe4c4a8ea2fc730687d0e9f818c7f9a23"//
            
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            
            AFStatic.managerGR.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
            AFStatic.managerGR.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
            AFStatic.managerGR.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control") // .sha1()

            print(":::::::AuthorizationService:::::::")
            print(jsessionIdSend)
             print(":::::::AuthorizationService:::::::")
            //AFStatic.managerGR.requestSerializer.setValue("JSESSIONID=\(jsessionIdSend)", forHTTPHeaderField:"Cookie")
            AFStatic.managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
            
        } else{
            print(":::::::AuthorizationService:::::::")
            print(jsessionIdSend)
            print(":::::::AuthorizationService:::::::")
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            //AFStatic.managerGR.requestSerializer.setValue("JSESSIONID=\(jsessionIdSend)", forHTTPHeaderField:"Cookie")
            AFStatic.managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
        }
        
        return AFStatic.managerGR
    }
    

}
