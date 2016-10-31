//
//  CategoryService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



class CategoryService : BaseService {
    
    let fileName = "categories.json"
    let typeCategory = "categories"
   
    
    func callService(_ params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                
                self.jsonFromObject(resultCall)
                self.saveDictionaryToFile(resultCall, fileName:self.fileName)
                successBlock?(resultCall)
                
                self.loadKeyFieldCategories(resultCall[JSON_KEY_RESPONSEARRAY] as! [[String:AnyObject]], type: ResultObjectType.Mg.rawValue);
                
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    
    func getCategoriesContent(from type:String) -> [[String:AnyObject]] {
        var response : [[String:AnyObject]] = []
        var filterResponse : [[String:AnyObject]] = []
        let values = self.getDataFromFile(fileName)
        if values != nil {
            response = values![JSON_KEY_RESPONSEARRAY] as! [[String:AnyObject]]
            for category in response {
                if category["business"]  != nil {
                if category["business"] as! String == type{
                    filterResponse.append(category)
                }
                }
            }
            response = filterResponse
            
             response = response.sorted(by: { (obj1:[String : AnyObject], obj2:[String : AnyObject]) -> Bool in
                let firstString = obj1["DepartmentName"] as! String?
                let secondString = obj2["DepartmentName"] as! String?
                return firstString < secondString

            })
        }
        
        return response
    }
    
    
    
}
