//
//  GRPayPalUpdateOrderService.swift
//  WalMart
//
//  Created by Alonso Salcido on 03/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRPaypalUpdateOrderService: GRBaseService{
    
  
    
    
    func callServiceConfirmOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
    func callServiceCancelOrder(requestParams params:NSDictionary, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}