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
            //session --
            //print("URL:: \(self.serviceUrl())")
            print("send::sessionID -- gr  \(jsessionIdSend) ATGID -- \(jSessionAtgIdSend)")
            
      
            
            AFStatic.managerGR.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
            AFStatic.managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
            
        } else{
            //session --
            //print("URL:: \(self.serviceUrl())")
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            print("send::sessionID -- gr \(jsessionIdSend) ATGID -- \(jSessionAtgIdSend)")
            AFStatic.managerGR.requestSerializer.setValue("JSESSIONID=\(jsessionIdSend)", forHTTPHeaderField:"Cookie")
            AFStatic.managerGR.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
            AFStatic.managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
        }
        
        let cookies = HTTPCookieStorage.shared.cookies(for: NSURL(string: serviceUrl())! as URL)
        let headers = HTTPCookie.requestHeaderFields(with: cookies!)
        for key in headers.keys {
            let strKey = key as NSString!
            let strVal = headers[key] as NSString!
            print(" GR____\(strKey) --- \(strVal)")
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
