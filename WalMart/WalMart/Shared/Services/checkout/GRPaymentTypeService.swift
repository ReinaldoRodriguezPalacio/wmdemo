//
//  GRPaymentTypeService.swift
//  WalMart
//
//  Created by neftali on 03/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRPaymentTypeService: BaseService {

    
    func callService(_ payment:String, successBlock:(([[String:Any]]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callService(requestParams: ["payment":payment], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(requestParams params:[String:Any], successBlock:(([[String:Any]]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            let arrayCall = resultCall["responseArray"] as! [[String:Any]]
            successBlock!(arrayCall)
        }) { (error:NSError) -> Void in
            print("Error: \(error)")
            errorBlock!(error)
        }
    }
}
