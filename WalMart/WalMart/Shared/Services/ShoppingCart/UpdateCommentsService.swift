//  UpdateCommentsService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 19/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class UpdateCommentsService:BaseService {
    
    func buildParameterOrder(orderComent:String) -> [String:AnyObject] {
        return ["updateOrderComment":"true","orderComment":orderComent]
    }
    
    func buildParameterItem(itemComent:String,itemId:String) -> [String:AnyObject] {
        return ["commerceIds":itemId,"itemComment":itemComent,"updateOrderComment":"false"]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }


}