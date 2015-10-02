//
//  GRUpdateListService.swift
//  WalMart
//
//  Created by neftali on 10/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUpdateListService: GRBaseService {
    
    func buildParams(name:String) -> [AnyObject] {
        //{"newName":"PentonVillet30Mayo2014_Update"}
        //return ["newName":name]
        //{"CualquierOtroNombre"}
        return [name]
    }

    func callService(params:AnyObject, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print(params)
        self.callPOSTService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
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
