//
//  FamilyByCategoryService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 24/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class FamilyByCategoryService: BaseService {
    
    func callService(requestParams params:AnyObject, successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            let arrayCall = resultCall["responseArray"] as! NSArray
            successBlock!(arrayCall)
        }) { (error:NSError) -> Void in
            print("Error: \(error)")
            errorBlock!(error)
        }
    }
    
}