//
//  GRUpdateListService.swift
//  WalMart
//
//  Created by neftali on 10/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUpdateListService: GRBaseService {
    
    func buildParams(_ name:String) -> [Any] {
        //{"newName":"PentonVillet30Mayo2014_Update"}
        //return ["newName":name]
        //{"CualquierOtroNombre"}
        return [name as AnyObject]
    }

    func callService(_ params:Any, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print(params)
        self.callPOSTService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
                //self.jsonFromObject(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }

}
