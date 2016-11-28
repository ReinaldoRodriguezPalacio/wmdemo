//
//  ValidateAssociateService.swift
//  WalMart
//
//  Created by Joel Juarez on 27/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class ValidateAssociateService : BaseService {
    
    func buildParams(_ idAssociated:String?,dateAdmission: String?,determinant: String?) -> [String:Any] {

        return ["idAssociated":idAssociated!,"dateAdmission":dateAdmission!,"determinant":determinant!]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
}
