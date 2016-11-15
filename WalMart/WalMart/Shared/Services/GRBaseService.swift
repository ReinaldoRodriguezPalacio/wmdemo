//
//  GRBaseService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class GRBaseService : BaseService {
    
    override func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        var serviceConfigDictionary = ConfigServices.ConfigIdMG
        if self.urlForSession {
            serviceConfigDictionary = UserCurrentSession.hasLoggedUser() ? ConfigServices.ConfigIdGRSign : ConfigServices.ConfigIdMG
        }
        
//        if useSignalsServices {
//            if UserCurrentSession.hasLoggedUser() &&  self.urlForSession {
//                //serviceConfigDictionary = ConfigServices.ConfigIdGRSignalsSing
//            }else{
//                //serviceConfigDictionary = ConfigServices.ConfigIdGRSignals
//            }
//        }
        
        
        let services = Bundle.main.object(forInfoDictionaryKey: serviceConfigDictionary) as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        //println(serviceURL)
        return serviceURL
    }

    override func getManager() -> AFHTTPSessionManager {
        if shouldIncludeHeaders() { // UserCurrentSession.hasLoggedUser() &&
            let timeInterval = Date().timeIntervalSince1970
            let timeStamp  = String(NSNumber(value: (timeInterval * 1000) as Double).intValue) // Time in milis "1400705132881"//
            let uuid  = UUID().uuidString //"e0fe3951-963e-4edf-a655-4ec3922b1116"//
            let strUsr  = "ff24423eefbca345" + timeStamp + uuid // "f3062afbe4c4a8ea2fc730687d0e9f818c7f9a23"//
            
            if AFStatic.managerGR.requestSerializer == nil {
                AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            }
            
            AFStatic.managerGR.requestSerializer!.setValue(timeStamp, forHTTPHeaderField: "timestamp")
            AFStatic.managerGR.requestSerializer!.setValue(uuid, forHTTPHeaderField: "requestID")
            AFStatic.managerGR.requestSerializer!.setValue(strUsr.sha1(), forHTTPHeaderField: "control") // .sha1()
            
//            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: serviceUrl())!)
//            let headers = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
//            for key in headers.keys {
//                let strKey = key as NSString
//                let strVal = headers[key] as NSString
//                AFStatic.managerGR.requestSerializer!.setValue(strVal, forHTTPHeaderField:strKey)
//            }
            
        } else{
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
        }
        return AFStatic.managerGR
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }

    static func getUseSignalServices() ->Bool{
        return Bundle.main.object(forInfoDictionaryKey: "useSignalsServices") as! Bool
    }
    
}
