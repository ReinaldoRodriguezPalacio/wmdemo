//
//  LoginByTokenService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 26/12/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class LoginByTokenService : BaseService {
    
    func buildParams(refreshToken:String) -> [String:Any] {
        return ["refreshToken":refreshToken]
    }
    
    func callService(params:NSDictionary,successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
       
        var token : [String:Any] = ["refreshToken":""]
        if let refreshToken = CustomBarViewController.retrieveParamNoUser(key: "REFESH_TOKEN") {
            print("REFESH_TOKEN :: \(refreshToken.value)")
            token = ["refreshToken":refreshToken.value]
        }
        
        self.callPOSTService(token, successBlock: { (resultCall:[String:Any]) -> Void in
            print("succes LoginByTokenService")
            CustomBarViewController.addOrUpdateParamNoUser(key: "ACCESS_TOKEN", value: "Bearer \(resultCall["accessToken"] as! String)")
            
            let autologinService = AutologinService()
            autologinService.callService(params: [:], successBlock: { (result:[String:Any]) in
                successBlock!(resultCall)
                }, errorBlock: { (error:NSError) in
                    errorBlock!(error)
                    print("error autologinService:  \(error.localizedDescription)")
            })
            
        },errorBlock: { (error:NSError) -> Void in
            print("Error : LoginByTokenService \(error.localizedDescription)")
            errorBlock!(error)
        })
    }
    
    
    
}
