//
//  NotificationService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/25/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class NotificationService :  BaseService {
    
    func buildParams(token:String,identifierDevice:String) -> NSDictionary {
        return ["token":token,"identifierDevice":identifierDevice,"idDevice":"2","idApp":"1","idDeviceOS":"2","userDevice":""]
    }
    
    
    
    
}