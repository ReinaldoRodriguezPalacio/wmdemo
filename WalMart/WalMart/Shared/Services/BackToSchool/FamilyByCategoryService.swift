//
//  FamilyByCategoryService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 24/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class FamilyByCategoryService: BaseService {
    
    func callService(requestParams params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
        }) { (error:NSError) -> Void in
            print("Error LineService: \(error)")
            errorBlock!(error)
        }
    }
    
}