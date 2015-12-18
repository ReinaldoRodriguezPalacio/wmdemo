//
//  PaymentMethod.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

public class PaymentMethod : EVObject {
    
    public var id : Int? = nil
    public var paymentMethodCode : String? = nil
    public var cardNumber : String? = nil
    public var cardExpiryDate : String? = nil
    public var cardSecurityNumber : String? = nil

}