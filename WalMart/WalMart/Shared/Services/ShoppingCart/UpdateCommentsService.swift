//  UpdateCommentsService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 19/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class UpdateCommentsService:GRBaseService {
    
    func buildParameterOrder(_ orderComent:String) -> [String:Any] {
        return ["updateOrderComment":"true" as AnyObject,"orderComment":orderComent as AnyObject]
    }
    
    func buildParameterItem(_ itemComent:String,itemId:String) -> [String:Any] {
        return ["commerceIds":itemId as AnyObject,"itemComment":itemComent as AnyObject,"updateOrderComment":"false" as AnyObject]
    }
    
    func callService(requestParams params:AnyObject, succesBlock:(([String : Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callPOSTService(params, successBlock: { (resultCall:[String : Any]) -> Void in
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }


}
