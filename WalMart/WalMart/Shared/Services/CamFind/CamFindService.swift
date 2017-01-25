//
//  CamFindService.swift
//  WalMart
//
//  Created by Ingenieria de soluciones on 7/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import AFNetworking

class CamFindService : BaseService {

    func buildParams(_ image: UIImage) -> [String:Any] {
        let data = UIImageJPEGRepresentation(image, 1.0) as AnyObject
        let language = "es-MX"
        let params: [String:Any]  = ["image_request[image]": data,"image_request[language]": language,"image_request[locale]": language]
        return params
    }
    
    func callService(_ paramsDic: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
        manager.requestSerializer.setValue("CloudSight \(self.getCamFindAPIKey())", forHTTPHeaderField: "Authorization")
        
        self.callPOSTServiceCam(manager, params: paramsDic,
            successBlock: { (resultDic: [String:Any]) -> Void in
                let resDic = [ "token" : resultDic["token"] as! String] as [String:Any]
                successBlock!(resDic)
            })
            { (error:NSError) -> Void in
                //ERROOR
        }
    }
    
    func checkImg(_ tokenStr: String, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
        manager.requestSerializer.setValue("CloudSight \(self.getCamFindAPIKey())", forHTTPHeaderField: "Authorization")
        
        let urlStr = "https://api.cloudsightapi.com/image_responses/\(tokenStr)?\(ConfigServices.camfindparams)" as String
        let empty: [String:Any] = [:]
        self.callGETService(manager, serviceURL: urlStr, params: empty as AnyObject,
            successBlock: { (resultF: [String:Any]) -> Void in
                //
                successBlock!(resultF)
            }) { (error:NSError) -> Void in
                //
                errorBlock!(error)
        }
    }
    
    func getCamFindAPIParameters() -> [String:Any] {
        return  Bundle.main.object(forInfoDictionaryKey: "WMCamFindAPI") as! [String:Any]
    }
    
    func getCamFindAPIKey() -> String{
        let apiParemeters = self.getCamFindAPIParameters()
        return  apiParemeters["CamFindAPIKey"] as! String
    }
}
