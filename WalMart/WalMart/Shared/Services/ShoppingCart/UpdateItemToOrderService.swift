//
//  UpdateItemToOrderService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class UpdateItemToOrderService:GRBaseService {
    
    func buildParameter(_ catalogRefIds:String, productId:String,quantity:String,quantityWithFraction:String,orderedUOM:String,orderedQTYWeight:String) -> [String:Any] {
        
        return ["catalogRefIds": catalogRefIds as AnyObject,"productId": productId as AnyObject,"quantity": quantity as AnyObject,"quantityWithFraction": quantityWithFraction as AnyObject,"orderedUOM": orderedUOM as AnyObject,"orderedQTYWeight": orderedQTYWeight as AnyObject,"action": "" as AnyObject]
    }
    
    
    func callService(requestParams params:AnyObject, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
    
}
