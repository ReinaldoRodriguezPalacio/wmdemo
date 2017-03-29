//
//  GRBaseService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import AFNetworking

class GRBaseService : BaseService {
    
    override func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        var serviceConfigDictionary = ConfigServices.ConfigIdGR
        if self.urlForSession {
            serviceConfigDictionary = UserCurrentSession.hasLoggedUser() ? ConfigServices.ConfigIdGRSign : ConfigServices.ConfigIdGR
        }
        
        if useSignalsServices {
            if UserCurrentSession.hasLoggedUser() &&  self.urlForSession {
                serviceConfigDictionary = ConfigServices.ConfigIdGRSignalsSing
            }else{
                serviceConfigDictionary = ConfigServices.ConfigIdGRSignals
            }
        }
        
        
        let services = Bundle.main.object(forInfoDictionaryKey: serviceConfigDictionary) as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        //println(serviceURL)
        return serviceURL
    }
    
    override func getManager() -> AFHTTPSessionManager {
        
        
        let managerGR = AFHTTPSessionManager()
        managerGR.requestSerializer = AFJSONRequestSerializer()
        managerGR.responseSerializer = AFJSONResponseSerializer()
        managerGR.responseSerializer.acceptableContentTypes = nil
        managerGR.securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        managerGR.securityPolicy.allowInvalidCertificates = true
        managerGR.securityPolicy.validatesDomainName = false
        managerGR.requestSerializer.httpShouldHandleCookies = true
        
        var jSessionAtgIdSend = UserCurrentSession.sharedInstance.JSESSIONATG
        
        if jSessionAtgIdSend == "" {
            if let param2 = CustomBarViewController.retrieveParamNoUser(key: "JSESSIONATG") {
                //print("PARAM JSESSIONATG ::" + param2.value)
                jSessionAtgIdSend = param2.value
            }
        }
        
        
        if UserCurrentSession.hasLoggedUser() && shouldIncludeHeaders() {
            
            let timeInterval = NSDate().timeIntervalSince1970
            let timeStamp  = String(NSNumber(value:(timeInterval * 1000)).intValue) // Time in milis "1400705132881"//
            let uuid  = NSUUID().uuidString //"e0fe3951-963e-4edf-a655-4ec3922b1116"//
            let strUsr  = "ff24423eefbca345" + timeStamp + uuid // "f3062afbe4c4a8ea2fc730687d0e9f818c7f9a23"//
            
            managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            
            managerGR.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
            managerGR.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
            managerGR.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control") // .sha1()
            managerGR.requestSerializer.setValue(getCookieFromUserDefaults(), forHTTPHeaderField:"Cookie")
            managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
            
        } else{
            //session --
            managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            managerGR.requestSerializer.setValue(getCookieFromUserDefaults(), forHTTPHeaderField:"Cookie")
            managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
        }
        return managerGR
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }
    
    static func getUseSignalServices() ->Bool{
        return Bundle.main.object(forInfoDictionaryKey: "useSignalsServices") as! Bool
    }
    
    override func getKeyForCookie() -> String {
        return "JSESSIONID"
    }
    
    
}
