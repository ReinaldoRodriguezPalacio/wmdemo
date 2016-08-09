//
//  Product.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class Product : NSManagedObject {
    
    @NSManaged var upc: String
    @NSManaged var img : String
    @NSManaged var desc : String
    @NSManaged var price : NSString
    @NSManaged var iva : String
    @NSManaged var baseprice : String
    @NSManaged var isActive : String
    @NSManaged var isPreorderable : String
    @NSManaged var onHandInventory : String
    @NSManaged var quantity : NSNumber
    @NSManaged var type : NSNumber
    @NSManaged var department : String
    @NSManaged var nameLine : String
    @NSManaged var comments : String
    @NSManaged var equivalenceByPiece : String
    @NSManaged var promoDescription : String
    @NSManaged var saving : String
    @NSManaged var stock : Bool
    
    
    @NSManaged var cart : Cart
    @NSManaged var list: List
    
}