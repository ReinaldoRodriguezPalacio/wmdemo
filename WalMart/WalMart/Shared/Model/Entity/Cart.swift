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
    case Created = 1
    case Updated = 2
    case Deleted = 3
    case Synchronized = 4
}


class Cart : NSManagedObject {
    
    @NSManaged var status: NSNumber
    @NSManaged var user : User
    @NSManaged var product : Product
    @NSManaged var quantity: NSNumber
    @NSManaged var type : String
    @NSManaged var note: String?
    
}