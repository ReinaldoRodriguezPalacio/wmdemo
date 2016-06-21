//
//  Param.swift
//  WalMart
//
//  Created by neftali on 24/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class Param: NSManagedObject {

    @NSManaged var key: String
    @NSManaged var value: String
    @NSManaged var user: WalmartMG.User
    @NSManaged var idUser: String

}
