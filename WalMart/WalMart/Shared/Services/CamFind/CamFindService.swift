//
//  CamFindService.swift
//  WalMart
//
//  Created by Ingenieria de soluciones on 7/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class CamFindService : BaseService {

    func buildParams(image: UIImage) -> NSDictionary {
        let data = UIImageJPEGRepresentation(image, 1.0)
        return ["image_request[image]": data,"image_request[language]": "es-MX","image_request[locale]": "es-MX"]
    }
    
    func callService(paramsDic: NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        var manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
        manager.requestSerializer!.setValue("CloudSight 9TkLWImiPApnIGSv8NT_sg", forHTTPHeaderField: "Authorization")
        
        self.callPOSTServiceCam(manager, params: paramsDic,
            successBlock: { (resultDic: NSDictionary) -> Void in
                let resDic = [ "token" : resultDic.objectForKey("token") as String] as NSDictionary
                successBlock!(resDic)
            })
            { (error:NSError) -> Void in
                //ERROOR
        }
    }
    
    func checkImg(tokenStr: String, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        var manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
        manager.requestSerializer!.setValue("CloudSight 9TkLWImiPApnIGSv8NT_sg", forHTTPHeaderField: "Authorization")
        
        let urlStr = "https://api.cloudsightapi.com/image_responses/\(tokenStr)" as String
        self.callGETService(manager, serviceURL: urlStr, params: [:],
            successBlock: { (resultF: NSDictionary) -> Void in
                //
                successBlock!(resultF)
            }) { (error:NSError) -> Void in
                //
                errorBlock!(error)
        }
    }
}
