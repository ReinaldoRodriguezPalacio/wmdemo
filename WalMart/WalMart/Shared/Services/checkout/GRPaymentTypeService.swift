//
//  GRPaymentTypeService.swift
//  WalMart
//
//  Created by neftali on 03/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRPaymentTypeService: GRBaseService {

    
    func callService(_ payment:String, successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)?) {
        //let afManager = getManager()
        self.callService(requestParams: ["payment":payment,"isPaypalOn":true], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func callService(requestParams params:[String:Any], successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            let arrayCall = resultCall["responseArray"] as! NSArray
            successBlock!(arrayCall)
        }) { (error:NSError) -> Void in
            print("Error: \(error)")
            errorBlock!(error)
        }
    }
}
