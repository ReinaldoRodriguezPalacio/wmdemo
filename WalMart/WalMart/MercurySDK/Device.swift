//
//  Device.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


public class Device : EVObject {
    
    public var id : String? = nil
    public var macAddress : String? = nil
    public var version : String? = nil
    public var systemName : String? = nil
    public var model : String? = nil
    public var localizedMode : String? = nil
    public var identifierForVendor : String? = nil
    public var pushToken : String? = nil
    public var status : String? = nil
    public var serialNumber : String? = nil
    public var imei : String? = nil
    
}