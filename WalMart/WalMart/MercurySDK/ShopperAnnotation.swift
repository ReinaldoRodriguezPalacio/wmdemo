//
//  ShopperAnnotation.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 30/10/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ShopperAnnotation : NSObject, MKAnnotation {
    var title : String? = nil
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
 
}