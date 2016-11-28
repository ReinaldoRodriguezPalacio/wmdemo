//
//  GRPayPalFuturePaymentService.swift
//  WalMart
//
//  Created by Alonso Salcido on 03/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPayPalFuturePaymentService: GRBaseService{
    
    func buildParams(_ contractId:String) -> [String:Any]{
        return ["contractId":contractId]
    }
    
    func callService(_ contractId: String, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
            self.jsonFromObject(buildParams(contractId))
        self.callPOSTService(buildParams(contractId), successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}
