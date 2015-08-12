//
//  GRDiscountAssociate.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRDiscountAssociateService: GRBaseService{
    
    var associateNumber: String?
    var startDate: String?
    var determinant: String?
    
    func buildParams(associateNumber:String, startDate:String, determinant: String) -> NSDictionary{
         return ["noAsociado":associateNumber,"fechaIngreso":startDate, "determinante":determinant]
    }
    
    func setParams(params:[String:String])
    {
        self.associateNumber = params[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        self.startDate = params[NSLocalizedString("checkout.discount.startDate", comment:"")]
        self.determinant = params[NSLocalizedString("checkout.discount.determinant", comment:"")]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(buildParams(self.associateNumber!, startDate: self.startDate!, determinant: self.determinant!), successBlock: { (resultCall:NSDictionary) -> Void in
             succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}