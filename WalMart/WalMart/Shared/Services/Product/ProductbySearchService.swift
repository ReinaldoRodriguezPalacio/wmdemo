//
//  ProductbySearchService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 02/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductbySearchService : BaseService {
    var useSignals = false
    
    override init() {
        super.init()
    }
    
    init(dictionary:[String:Any]){
        super.init()
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    func buildParamsForSearch(text:String? , family idFamily:String?, line idLine:String?, sort idSort:String?,departament idDepartment:String?, start startOffSet:Int, maxResult max:Int) -> [String:Any]! {
        if useSignals {
            let channel = IS_IPAD ? "ipad" : "iphone"
            let searchText = text != nil ? text! : ""
            var parameter = ["q":searchText,"eventtype": "search","collection":"mg","channel": channel]
            if searchText == ""{
                parameter = ["category":idLine!,"eventtype": "categoryview","collection":"mg","channel": channel]
            }
            return [
                JSON_KEY_TEXT:(text != nil ? text! : ""),
                JSON_KEY_IDDEPARTMENT:(idDepartment != nil ? idDepartment! : ""),
                JSON_KEY_IDFAMILY:(idFamily != nil ? idFamily! : ""),
                JSON_KEY_IDLINE:(idLine != nil ? idLine! : ""),
                JSON_KEY_SORT:(idSort != nil ? idSort! : ""),
                JSON_KEY_STARTOFFSET:"\(startOffSet)",
                JSON_KEY_MAXRESULTS:"\(max)",
                "parameter":parameter] as [String:Any]
        }
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
    
    
    func callService(_ params:[String:Any], successBlock:(([[String:Any]],_ facet:[[String:Any]],_ resultDic:[String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print("PARAMS FOR ProductbySearchService")
        self.jsonFromObject(params as AnyObject!)
        self.callPOSTService(params,
            successBlock: { (resultJSON:[String:Any]) -> Void in
//                println("RESULT FOR ProductbySearchService")
//                self.jsonFromObject(resultJSON)
                if let error = self.validateCodeMessage(resultJSON) {
                    errorBlock?(error)
                    return
                }
                let priority = resultJSON["priority"] as? String ?? ""
                let suggestion:String = resultJSON["suggestion"] as? String ?? ""
                let alternativeCombination:String = resultJSON["alternativeCombination"]as? String ?? ""
                let landingPage = resultJSON["landingPage"] as? [String:Any] ?? [:]
                let dic: [String:Any] = ["suggestion":suggestion,"alternativeCombination":alternativeCombination,"landingPage":landingPage,"priority":priority]
                let arrayKey = (suggestion != "" ? JSON_KEY_RESPONSEARRAY_CORRECTION : (alternativeCombination != "" ? JSON_KEY_RESPONSEARRAY_ALTERNATIVE: JSON_KEY_RESPONSEARRAY))
                
                var newItemsArray = Array<[String:Any]>()
                if let items = resultJSON[arrayKey] as? [[String:Any]] {
                    //println(items)
                    self.saveKeywords(items) //Creating keywords
                    for idx in 0 ..< items.count {
                        var item = items[idx] 
                        item["type"] = ResultObjectType.Mg.rawValue
                        newItemsArray.append(item)
                    }
                }
                var facets = Array<[String:Any]>()
                if let itemsFacets = resultJSON["facet"] as? [[String:Any]] {
                    facets = itemsFacets
                }
                successBlock?(newItemsArray,facets,dic)
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock!(error)
            }
        )
    }
    
}
