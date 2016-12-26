//
//  DetailedService.swift
//  WalMart
//
//  Created by Joel Juarez on 21/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class DetailedService: BaseService {

    
    func callService(requestParams params:AnyObject, succesBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?){
        let empty: [String:AnyObject] = [:]
        self.callGETService(empty as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            print("DetailedService:::")
            self.jsonFromObject(resultCall as AnyObject!)
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }



}
