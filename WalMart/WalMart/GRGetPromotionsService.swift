//
//  GRGetPromotionsService.swift
//  WalMart
//
//  Created by Alonso Salcido on 30/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRGetPromotionsService: GRBaseService{
    
    var isAssociated: String?
    var idAssociated: String?
    var dateAdmission: String?
    var determinant: String?
    var total:String?
    
    func buildParams(isAssociated: String,associateNumber:String, startDate:String, determinant: String, total: String) -> NSDictionary{
        return ["isAssociated": isAssociated,"idAssociated":associateNumber,"dateAdmission":startDate, "determinant":determinant, "total":total]
    }
    
    func setParams(params:[String:String])
    {
        self.isAssociated = params["isAssociated"]
        self.idAssociated = params[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        self.dateAdmission = params[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
        self.determinant = params[NSLocalizedString("checkout.discount.determinant", comment:"")]
        self.total = params[NSLocalizedString("checkout.discount.total", comment:"")]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        
        self.callPOSTService(buildParams( self.isAssociated!,associateNumber: self.isAssociated!, startDate: self.dateAdmission!, determinant: self.determinant!,total: self.total!), successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}