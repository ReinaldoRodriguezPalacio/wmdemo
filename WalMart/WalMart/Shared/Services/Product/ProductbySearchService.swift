//
//  ProductbySearchService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 02/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductbySearchService : BaseService {
    
    func buildParamsForSearch(#text:String? , family idFamily:String?, line idLine:String?, sort idSort:String?,departament idDepartment:String?, start startOffSet:Int, maxResult max:Int) -> [String:AnyObject]! {
        return [
            JSON_KEY_TEXT:(text != nil ? text! : ""),
            JSON_KEY_IDDEPARTMENT:(idDepartment != nil ? idDepartment! : ""),
            JSON_KEY_IDFAMILY:(idFamily != nil ? idFamily! : ""),
            JSON_KEY_IDLINE:(idLine != nil ? idLine! : ""),
            JSON_KEY_SORT:(idSort != nil ? idSort! : ""),
            JSON_KEY_STARTOFFSET:"\(startOffSet)",
            JSON_KEY_MAXRESULTS:"\(max)",
        ]
    }
    
    
    func callService(params:NSDictionary, successBlock:((NSArray,facet:NSArray) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        println("PARAMS FOR ProductbySearchService")
        self.jsonFromObject(params)
        self.callPOSTService(params,
            successBlock: { (resultJSON:NSDictionary) -> Void in
//                println("RESULT FOR ProductbySearchService")
//                self.jsonFromObject(resultJSON)
                if let error = self.validateCodeMessage(resultJSON) {
                    errorBlock?(error)
                    return
                }
                let itemObjectResult = resultJSON[JSON_KEY_RESPONSEOBJECT] as! NSDictionary
                var newItemsArray = Array<AnyObject>()
                if let items = itemObjectResult["items"] as? NSArray {
                    //println(items)
                    self.saveKeywords(items) //Creating keywords
                    for var idx = 0; idx < items.count; idx++ {
                        var item = items[idx] as! [String:AnyObject]
                        item["type"] = ResultObjectType.Mg.rawValue
                        newItemsArray.append(item)
                    }
                }
                var facets = Array<AnyObject>()
                if let itemsFacets = itemObjectResult["facet"] as? [AnyObject] {
                    facets = itemsFacets
                }
                successBlock?(newItemsArray,facet: facets)
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
            }
        )
    }
    
}
