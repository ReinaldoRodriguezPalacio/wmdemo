//
//  ValidateAssociateService.swift
//  WalMart
//
//  Created by Joel Juarez on 27/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class ValidateAssociateService : BaseService {
    
    func buildParams(idAssociated:String,dateAdmission: String,determinant: String) -> NSDictionary {

        return ["idAssociated":idAssociated,"dateAdmission":dateAdmission,"determinant":determinant]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            
            successBlock!(resultCall)
            
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
}