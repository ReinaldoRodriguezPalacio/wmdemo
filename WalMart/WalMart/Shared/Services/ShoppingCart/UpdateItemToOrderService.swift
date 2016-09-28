//
//  UpdateItemToOrderService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class UpdateItemToOrderService:GRBaseService {
    
    func buildParameter(catalogRefIds:String, productId:String,quantity:String,quantityWithFraction:String,orderedUOM:String,orderedQTYWeight:String) -> [String:AnyObject] {
        
        return ["catalogRefIds": catalogRefIds,"productId": productId,"quantity": quantity,"quantityWithFraction": quantityWithFraction,"orderedUOM": orderedUOM,"orderedQTYWeight": orderedQTYWeight,"action": ""]
    }
    
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }
    
    
}