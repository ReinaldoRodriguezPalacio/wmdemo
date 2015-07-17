//
//  Wishlist.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

enum WishlistStatus : Int {
    case Created = 1
    case Updated = 2
    case Deleted = 3
    case Synchronized = 4
}


class Wishlist : NSManagedObject {
    
    @NSManaged var status: NSNumber
    @NSManaged var product : Product
    @NSManaged var user : User
    
}