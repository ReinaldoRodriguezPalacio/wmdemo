//
//  ProviderDetailService.swift
//  WalMart
//
//  Created by Daniel V on 02/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProviderDetailService : BaseService {
  
  func buildParams(_ idProvider:String) -> [String:Any] {
    return ["offerId":idProvider]
  }
  
  func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
    self.jsonFromObject(params as AnyObject!)
    self.getManager().post(serviceUrl(), parameters: params,progress:nil, success: {(request:URLSessionDataTask, json:Any?) in
            //self.printTimestamp("success LinesForSearchService")
            let jsonResponce = json as! [String:Any]
            successBlock?(jsonResponce) },
                           
                          failure: {(request:URLSessionDataTask?, error:Error) in
                            if (error as NSError).code == -1005 {
                              print("Response Error : \(error) \n")
                              self.callService(params, successBlock:successBlock, errorBlock:errorBlock)
                              return
                            }
                            print("Response Error : \(error) \n ")
                            errorBlock!(error as NSError)
    })
  }
  
}
