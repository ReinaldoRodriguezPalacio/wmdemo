//
//  Person.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


public class Person : EVObject {
    
    public var id : String? = nil
    public var name : String? = nil
    public var secondName : String? = nil
    public var lastname : String? = nil
    public var secondLastName : String? = nil
    public var birthDate : String? = nil
    public var gender : String? = nil
    public var contact : [Contact]? = nil
    
    
    
}