//
//  Cart.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


enum CartStatus : Int {
    case created = 1
    case updated = 2
    case deleted = 3
    case synchronized = 4
}


class Cart : NSManagedObject {
    
    @NSManaged var status: NSNumber
    @NSManaged var user : User
    @NSManaged var product : Product
    @NSManaged var quantity: NSNumber
    @NSManaged var type : String
    @NSManaged var note: String?
    
}
