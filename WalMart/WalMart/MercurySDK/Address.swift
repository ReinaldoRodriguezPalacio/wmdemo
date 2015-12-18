//
//  DeliveryAddress.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 28/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


public class Address : EVObject {
    
    
    public var id : String? = nil
    public var address : String? = nil
    public var city : String? = nil
    public var state : String? = nil
    public var postalCode : String? = nil
    public var country : String? = nil
    public var internalNumber : String? = nil
    public var externalNumber : String? = nil
    public var betweenStreet1 : String? = nil
    public var betweenStreet2 : String? = nil
    public var addressReference : String? = nil
    public var longitude : Double? = nil
    public var latitude : Double? = nil
    public var neighborhood : String? = nil
    
        
    
}