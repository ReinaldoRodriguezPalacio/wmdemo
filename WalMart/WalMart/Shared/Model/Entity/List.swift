//
//  List.swift
//  WalMart
//
//  Created by neftali on 21/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class List: NSManagedObject {

    @NSManaged var idList: String?
    @NSManaged var name: String
    @NSManaged var countItem: NSNumber
    @NSManaged var user: WalmartMG.User
    @NSManaged var registryDate: Date?

    @NSManaged var products: NSMutableSet
}
