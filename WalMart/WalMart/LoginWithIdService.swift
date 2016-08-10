//
//  LoginWithIdService.swift
//  WalMart
//
//  Created by Joel Juarez on 27/07/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class LoginWithIdService : LoginWithEmailService {
    
    func buildParams(idUser:String) -> NSDictionary {
        let lowCaseUser = idUser.lowercaseString
        return ["profileId":lowCaseUser]
    }
    
    
    
    
}