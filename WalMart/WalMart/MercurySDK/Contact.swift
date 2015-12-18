//
//  Contact.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

public enum ContactMean : Int {
    case Email = 1
    case Home = 2
    case Work = 3
    case Mobile = 4
}


public class  Contact : EVObject {
    
    public var mean : Int? = nil
    public var value : String? = nil
    public var ext : String? = nil
    
}