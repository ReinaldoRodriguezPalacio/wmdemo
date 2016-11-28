//
//  CategoryService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class CategoryService : BaseService {
    
    let fileName = "categories.json"
    let typeCategory = "categories"
   
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
                self.jsonFromObject(resultCall)
                self.saveDictionaryToFile(resultCall, fileName:self.fileName)
                successBlock?(resultCall)
                
                self.loadKeyFieldCategories(resultCall[JSON_KEY_RESPONSEARRAY] as! [[String:Any]], type: ResultObjectType.Mg.rawValue);
                
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    
    func getCategoriesContent() -> [[String:Any]] {
        var response : [[String:Any]] = []
        let values = self.getDataFromFile(fileName)
        if values != nil {
            response = values![JSON_KEY_RESPONSEARRAY] as! [[String:Any]]
             response = response.sort({ (obj1:[String : AnyObject], obj2:[String : AnyObject]) -> Bool in
                let firstString = obj1["description"] as! String?
                let secondString = obj2["description"] as! String?
                return firstString < secondString

            })
        }
        return response
    }
    
    
    
}
