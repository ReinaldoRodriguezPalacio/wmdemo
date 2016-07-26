//
//  User.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import CoreData


class User : NSManagedObject {
    
    //Walmart MG
    @NSManaged var cartId: NSString
    @NSManaged var email: NSString
    @NSManaged var idUser: NSString
    @NSManaged var login: NSString
    @NSManaged var lastLogin: NSDate
    @NSManaged var maximumAmount: NSNumber
    @NSManaged var profile: Profile
    @NSManaged var productsInCart: NSSet
    
    @NSManaged var lists: NSMutableSet?

}