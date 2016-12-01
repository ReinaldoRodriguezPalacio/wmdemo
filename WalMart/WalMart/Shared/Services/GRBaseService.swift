//
//  GRBaseService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class GRBaseService : BaseService {
    
    override func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
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
        
        
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey(serviceConfigDictionary) as! NSDictionary
        let environmentServices = services[environment] as! [String:AnyObject]
        let serviceURL =  environmentServices[serviceName] as! String
        //println(serviceURL)
        return serviceURL
    }

    override func getManager() -> AFHTTPSessionManager {
        
        var jsessionIdSend = UserCurrentSession.sharedInstance().JSESSIONID
        var jSessionAtgIdSend = UserCurrentSession.sharedInstance().JSESSIONATG
        
        if jsessionIdSend == "" {
            if let param1 = CustomBarViewController.retrieveParamNoUser("JSESSIONID") {
                print("PARAM JSESSIONID ::"+param1.value)
                jsessionIdSend = param1.value
            }
            if let param2 = CustomBarViewController.retrieveParamNoUser("JSESSIONATG") {
                print("PARAM JSESSIONATG ::" + param2.value)
                jSessionAtgIdSend = param2.value
            }
        }
        
        
        if UserCurrentSession.hasLoggedUser() && shouldIncludeHeaders() {
            
            let timeInterval = NSDate().timeIntervalSince1970
            let timeStamp  = String(NSNumber(double:(timeInterval * 1000)).integerValue) // Time in milis "1400705132881"//
            let uuid  = NSUUID().UUIDString //"e0fe3951-963e-4edf-a655-4ec3922b1116"//
            let strUsr  = "ff24423eefbca345" + timeStamp + uuid // "f3062afbe4c4a8ea2fc730687d0e9f818c7f9a23"//
            
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
        
            AFStatic.managerGR.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
            AFStatic.managerGR.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
            AFStatic.managerGR.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control") // .sha1()
            //session --
            print("URL:: \(self.serviceUrl())")
            print("send::sessionID -- \(UserCurrentSession.sharedInstance().JSESSIONID) ATGID -- \(UserCurrentSession.sharedInstance().JSESSIONATG)")
            AFStatic.managerGR.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
            AFStatic.managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
            
        } else{
            //session --
            print("URL:: \(self.serviceUrl())")
            AFStatic.managerGR.requestSerializer = AFJSONRequestSerializer() as  AFJSONRequestSerializer
            print("send::sessionID -- \(UserCurrentSession.sharedInstance().JSESSIONID) ATGID -- \(UserCurrentSession.sharedInstance().JSESSIONATG)")
            AFStatic.managerGR.requestSerializer.setValue(jsessionIdSend, forHTTPHeaderField:"JSESSIONID")
            AFStatic.managerGR.requestSerializer.setValue(jSessionAtgIdSend, forHTTPHeaderField:"JSESSIONATG")
        }
        return AFStatic.managerGR
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }

    static func getUseSignalServices() ->Bool{
        return NSBundle.mainBundle().objectForInfoDictionaryKey("useSignalsServices") as! Bool
    }
    
}