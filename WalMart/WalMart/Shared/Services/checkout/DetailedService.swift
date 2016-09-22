//
//  DetailedService.swift
//  WalMart
//
//  Created by Joel Juarez on 21/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class DetailedService: GRBaseService {

    
    func callService(requestParams params:AnyObject, succesBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?){
        self.callGETService([], successBlock: { (resultCall:NSDictionary) -> Void in
            print("DetailedService:::")
            self.jsonFromObject(resultCall)
            succesBlock!(resultCall)
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
        })
    }



}