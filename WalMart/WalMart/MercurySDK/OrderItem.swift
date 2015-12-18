//
//  OrderItem.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 28/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

public enum OrderItemUnit : String {
    case Pice = "1"
    case Gram = "2"
    case Kilogram = "3"
    case Ton = "4"
    case yard = "5"
    case Liter = "6"
}

public class OrderItem : EVObject  {
    
    public var id : String? = nil
    public var itemId : String? = nil
    public var name : String? = nil
    public var unitSalePrice : Double? = nil
    public var totalPrice : Double? = nil
    public var upc : String? = nil
    public var shortDescription : String? = nil
    public var longDescription : String? = nil
    public var thumbnailImage : String? = nil
    public var quantity : Int? = nil
    public var unitType : String? = nil
    public var comments : String? = nil
    public var additionType : String? = nil
    public var orderItemStatus : String? = nil
    public var marketplace : String? = nil
    public var modelNumber : String? = nil
    public var stock : String? = nil
    public var status : String? = nil
    public var aisle : String? = nil
    public var consecutive : Int? = nil

}