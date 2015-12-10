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
        
        var isAssociatedSend = (isAssociated == "1" ? "true":"false")
        
        if associateNumber != "" && startDate != "" && determinant != "" {
            isAssociatedSend = "true"
        }
        
        return ["isAssociated": isAssociatedSend ,"idAssociated":associateNumber,"dateAdmission":startDate, "determinant":determinant, "total":total]
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
        
        self.jsonFromObject(params)
        self.callPOSTService(buildParams(self.isAssociated!,associateNumber: self.idAssociated ==  nil ? "" :self.idAssociated!,
            startDate: self.dateAdmission == nil ? "": self.dateAdmission!, determinant: self.determinant == nil ? "" : self.determinant!,total: self.total!), successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
}