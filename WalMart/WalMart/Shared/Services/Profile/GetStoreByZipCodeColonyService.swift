//
//  GetStoreByZipCodeColonyService.swift
//  WalMart
//
//  Created by Joel Juarez Alcantara on 15/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class GetStoreByZipCodeColonyService : GRZipCodeService {
    var colony : String = ""
    
    func buildParams(_ zipCode:String,colony:String) {
        self.code = zipCode
        self.colony = colony
    }
    
    override func serviceUrl() -> (String){
        self.colony = self.colony.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return super.serviceUrl() + "/" + self.colony
    }
    

}
