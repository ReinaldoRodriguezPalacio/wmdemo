//
//  LineService.swift
//  WalMart
//
//  Created by Joel Juarez on 25/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class LineService : BaseService {
    
    override init() {
        super.init()
    }
    
    func buildParamsLine(_ familyId:String) -> [String:Any] {
        return ["id":familyId]
    }
    
    func callService(requestParams params:Any, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print("Call service :: ::LineService ")
        self.callPOSTService(buildParamsLine(params as! String), successBlock: { (resultCall:[String:Any]) -> Void in
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                print("Error LineService: \(error)")
                errorBlock!(error)
        }
    }
    
}
