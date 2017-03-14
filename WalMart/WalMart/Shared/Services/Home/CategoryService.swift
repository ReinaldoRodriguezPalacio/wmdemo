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
   
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callGETService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
                
                self.jsonFromObject(resultCall as AnyObject!)
                self.saveDictionaryToFile(resultCall, fileName:self.fileName)
                
                successBlock?(resultCall)
                
                let items = resultCall["contents"] as! [[String:Any]]
                let DepG = items[0] as? NSDictionary
                
                self.loadKeyFieldCategories(items: DepG, type: ResultObjectType.Mg.rawValue); //resultCall["contents"] as! [[String:Any]] as AnyObject!
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    
    func getCategoriesContent(from type:String) -> [[String:Any]] {
        var response : [[String:Any]] = []
        var filterResponse : [[String:Any]] = []
        let values = self.getDataFromFile(fileName as NSString)
        if values != nil {
            let items = values!["contents"] as! [[String:Any]]
            let DepG = items[0] as? NSDictionary
            response = DepG!["departmentGroup"] as! [[String:Any]]
            for category in response {
                if category["business"]  != nil {
                if category["business"] as! String == type{
                    filterResponse.append(category)
                }
                }
            }
            response = filterResponse
            
             response = response.sorted(by: { (obj1:[String:Any], obj2:[String:Any]) -> Bool in
                let firstString = obj1["DepartmentName"] as! String?
                let secondString = obj2["DepartmentName"] as! String?
                return firstString < secondString

            })
        }
        
        return response
    }
    
    
    
}
