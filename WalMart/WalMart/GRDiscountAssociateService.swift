//
//  GRDiscountAssociate.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRDiscountAssociateService: BaseService{
    
    var associateNumber: String?
    var dateAdmission: String?
    var determinant: String?
    var total:String?
    
    func buildParams(_ associateNumber:String, startDate:String, determinant: String, total: String) -> [String:Any]{
        return ["isAssociated":true,"idAssociated":associateNumber,"dateAdmission":startDate, "determinant":determinant, "total":total]
    }
    
    func setParams(_ params:[String:String])
    {
        self.associateNumber = params[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        self.dateAdmission = params[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
        self.determinant = params[NSLocalizedString("checkout.discount.determinant", comment:"")]
        self.total = params[NSLocalizedString("checkout.discount.total", comment:"")]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
         //self.jsonFromObject(buildParams(self.associateNumber!, startDate: self.dateAdmission!, determinant: self.determinant!,total: self.total!))
        let empty: Dictionary<String,Any> = [:]
        self.callGETService(empty as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
           
             succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}
