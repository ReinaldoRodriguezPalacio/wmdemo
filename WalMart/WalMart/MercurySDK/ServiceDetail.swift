//
//  ServiceType.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 08/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

public enum ServiceType : String {
    case VIP = "vip"
    case Normal = "normal"
    case Slots = "slots"
}

public class ServiceDetail : EVObject {

    public var serviceType : String? = nil
    public var deliveryDate : String? = nil
    public var idShopper : String? = nil
    public var idStore : String? = nil
    public var idTimeSlot : Int? = nil
    
    
}