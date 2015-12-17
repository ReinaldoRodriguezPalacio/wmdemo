//
//  Order.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


public class Order : EVObject {
    
    public var id : String? = nil
    public var orderStatus : String? = nil
    public var orderDate : String? = nil
    public var deliveryInstructions : String? = nil
    public var deliveryAddress : Address? = nil
    public var orderTotalCost : Double? = nil
    public var orderShipmentCost : Double? = nil
    public var deliveryTimeEstimated : String? = nil
    public var shopper : String? = nil
    public var ticket : String? = nil
    public var shipments : String? = nil
    public var orderRequestItems : [OrderItem]? = nil
    public var geolocation : String? = nil
    
    
}