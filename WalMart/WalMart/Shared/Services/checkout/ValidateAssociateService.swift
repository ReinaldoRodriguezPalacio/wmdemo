//
//  ValidateAssociateService.swift
//  WalMart
//
//  Created by Joel Juarez on 27/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class ValidateAssociateService : BaseService {
    
    func buildParams(idAssociated:String?,determinant: String?) -> NSDictionary {

        return ["idAssociated":idAssociated!,"determinant":determinant!]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
}
