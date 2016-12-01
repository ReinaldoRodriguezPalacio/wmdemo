//
//  GRDiscountAssociate.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRDiscountActiveService: GRBaseService{
    
    
    func callService(_ succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callGETService([:],successBlock: { (resultCall:[String:Any]) -> Void in
             succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}
