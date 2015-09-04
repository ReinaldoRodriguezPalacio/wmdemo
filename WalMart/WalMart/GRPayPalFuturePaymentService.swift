//
//  GRPayPalFuturePaymentService.swift
//  WalMart
//
//  Created by Alonso Salcido on 03/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPayPalFuturePaymentService: GRBaseService{
    
    func buildParams(contractId:String) -> NSDictionary{
        return ["contractId":contractId]
    }
    
    func callService(contractId: String, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(buildParams(contractId), successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}