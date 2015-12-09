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
    var dateAdmission: String?
    var determinant: String?
    var total:String?
    
    func buildParams(associateNumber:String, startDate:String, determinant: String, total: String) -> NSDictionary{
         return ["idAssociated":associateNumber,"dateAdmission":startDate, "determinant":determinant, "total":total]
    }
    
    func setParams(params:[String:String])
    {
        self.associateNumber = params[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        self.dateAdmission = params[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
        self.determinant = params[NSLocalizedString("checkout.discount.determinant", comment:"")]
        self.total = params[NSLocalizedString("checkout.discount.total", comment:"")]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callGETService(buildParams(self.associateNumber!, startDate: self.dateAdmission!, determinant: self.determinant!,total: self.total!), successBlock: { (resultCall:NSDictionary) -> Void in
             succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}