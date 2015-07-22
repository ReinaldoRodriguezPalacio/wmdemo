//
//  Profile.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 18/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import CoreData

class Profile : NSManagedObject {
    
    //Walmart MG
    @NSManaged var allowMarketingEmail: NSString
    @NSManaged var allowTransfer: NSString
    @NSManaged var idProfile: NSString
    @NSManaged var lastName: NSString
    @NSManaged var lastName2: NSString
    @NSManaged var minimumAmount: NSNumber
    @NSManaged var name: NSString
    @NSManaged var token: NSString
    
    @NSManaged var user : User
    
    
    //Groceries
    @NSManaged var birthDate: NSString
    @NSManaged var cellPhone: NSString
    @NSManaged var homeNumberExtension: NSString
    @NSManaged var maritalStatus: NSString
    @NSManaged var phoneHomeNumber: NSString
    @NSManaged var phoneWorkNumber: NSString
    @NSManaged var profession: NSString
    @NSManaged var sex: NSString
    @NSManaged var workNumberExtension: NSString
    
    
}
