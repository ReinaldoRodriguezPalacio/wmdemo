//
//  Store.swift
//  WalMart
//
//  Created by neftali on 03/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class Store: NSManagedObject {

    @NSManaged var businessID: String?
    @NSManaged var storeID: String?
    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var telephone: String?
    @NSManaged var manager: String?
    @NSManaged var zipCode: String?
    @NSManaged var latSpan: NSNumber?
    @NSManaged var lonSpan: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var opens: String?

}
