//
//  User.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


public class UserMerc : EVObject {
    
    public var id : String? = nil
    public var userName : String? = nil
    public var password : String? = nil
    public var email : String? = nil
    public var person : Person? = nil
    
    public var application : Application? = nil
    public var devices : [Device]? = nil

    
}