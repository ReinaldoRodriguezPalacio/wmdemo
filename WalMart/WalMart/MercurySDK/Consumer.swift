//
//  Consumer.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

public class Consumer : EVObject {
    
    public var id : String? = nil
    public var rating : String? = nil
    public var ratingImage : String? = nil
    public var picture : String? = nil
    public var user : UserMerc? = nil
    public var customerPaymentMethods : [PaymentMethod]? = nil
      
}