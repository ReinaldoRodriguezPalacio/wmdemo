//
//  GRProductBySearchService.swift
//  WalMart
//
//  Created by neftali on 22/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class GRProductBySearchService: BaseService {
   var useSignals = false
    override init() {
        super.init()
        self.urlForSession = true
    }
    
    
    init(dictionary:[String:Any]){
        super.init()
        self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    
    /*func buildParamsForSearch(text:String?, family idFamily:String?, line idLine:String?, sort idSort:String?, departament idDepartment:String?, start startOffSet:Int, maxResult max:Int, brand:String?) -> [String:Any]! {
        if useSignals {
            let channel = IS_IPAD ? "ipad" : "iphone"
            let searchText = text != nil ? text! : ""
            var parameter = ["q":searchText,"eventtype": "search","collection":"dah","channel": channel] as [String:Any]
            if searchText == ""{
               parameter = ["category":idLine!,"eventtype": "categoryview","collection":"dah","channel": channel]
            }
            return [
                JSON_KEY_TEXT:searchText, //"pText"
                JSON_KEY_IDDEPARTMENT:(idDepartment != nil ? idDepartment! : ""), //"idDepartment"
                JSON_KEY_IDFAMILY:(idFamily != nil ? idFamily! : ""), //"idFamily"
                JSON_KEY_IDLINE:(idLine != nil ? idLine! : ""), //"idLine"
                JSON_KEY_SORT:(idSort != nil ? idSort! : ""), //"sort"
                JSON_KEY_STARTOFFSET:"\(startOffSet)", //startOffSet
                JSON_KEY_MAXRESULTS:"\(max)" //"maxResults"
                ,JSON_KEY_BRAND:(brand != nil ? brand! : "")//"brand"
                ,"parameter":parameter] as [String:Any]
        }
        return [
            JSON_KEY_TEXT:(text ?? ""), //"pText"
            JSON_KEY_IDDEPARTMENT:(idDepartment != nil ? idDepartment! : ""), //"idDepartment"
            JSON_KEY_IDFAMILY:(idFamily != nil ? idFamily! : ""), //"idFamily"
            JSON_KEY_IDLINE:(idLine != nil ? idLine! : ""), //"idLine"
            JSON_KEY_SORT:(idSort != nil ? idSort! : ""), //"sort"
            JSON_KEY_STARTOFFSET:"\(startOffSet)", //startOffSet
            JSON_KEY_MAXRESULTS:"\(max)" //"maxResults"
            ,JSON_KEY_BRAND:(brand != nil ? brand! : "")//"brand"
        ] as [String:Any]
    }*/
    
    func buildParamsForSearch(url:String?, text:String?, sort:String?, startOffSet:String?, maxResult:String?)  -> [String:String] {
        return  ["url":url!, "text":text!, "maxResults":maxResult!, "sort":sort!, "startOffSet":startOffSet!]
    }

    func callService(_ params:AnyObject, successBlock:(([[String:Any]],_ facet:NSMutableDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        //print("PARAMS FOR GRProductBySearchService walmartgroceries/login/getItemsBySearching")
        self.jsonFromObject(params as AnyObject!)
        self.callPOSTService(params,
                             successBlock: { (resultJSON:[String:Any]) -> Void in
                //print("RESULT FOR GRProductBySearchService walmartgroceries/login/getItemsBySearching")
                self.jsonFromObject(resultJSON as AnyObject!)
                
                if let error = self.validateCodeMessage(resultJSON as [String:Any]) {
                    errorBlock?(error)
                    return
                }
                
                var newItemsArray = Array<[String:Any]>()
                var facets : NSMutableDictionary =  [:]
                
                /*if let items = resultJSON[JSON_KEY_RESPONSEARRAY] as? [[String:Any]] {
                    self.saveKeywords(items) //Creating keywords
                    
                    //El atributo type en el JSON de producto ya existe. Por el momento se sobreescribe el valor para manejar la procedencia del mensaje.
                    var newItemsArray: [[String:Any]] = []
                    for idx in 0 ..< items.count {
                        var item = items[idx] as! [String:Any]
                        if let promodesc = item["promoDescription"] as? String{
                            if promodesc != "null" {
                                item["saving"] = promodesc as AnyObject?
                            }
                        }
                        item["pesable"] =  item["type"] as! NSString
                        item["type"] = ResultObjectType.Groceries.rawValue as AnyObject?
                        newItemsArray.append(item)
                    }
                    successBlock?(newItemsArray, facets)
                }
                
                //Search service Text
                if let responseObject = resultJSON[JSON_KEY_RESPONSEOBJECT] as? [String:Any] {
                    //Array facet
                    if let itemsFacets = responseObject["facet"] as? [[String:Any]] {
                        facets = itemsFacets
                    }
                    //Array items
                    if let items = responseObject["items"] as? [[String:Any]] {
                        for idx in 0 ..< items.count {
                            var item = items[idx] as! [String:Any]
                            if let promodesc = item["promoDescription"] as? String{
                                if promodesc != "null" {
                                    item["saving"] = promodesc as AnyObject?
                                }
                            }
                            newItemsArray.append(item)
                        }
                    }
                    
                    successBlock?(newItemsArray, facets)
                }*/
                                
                if let responseMainArea = resultJSON["mainArea"] as? NSArray {
                    let mainArea = responseMainArea[0] as! [String:Any]
                    
                    //facets
                    //left area and Sort Options
                    let sortOpt = mainArea["sortOptions"] as? NSArray
                    
                    if let itemsFacets = resultJSON["leftArea"] as? [[String:Any]] {
                        let navigation = itemsFacets[0] as? [String:Any]
                        
                        if sortOpt != nil && navigation!["navigation"] != nil {
                            facets = NSMutableDictionary(dictionary: [
                                "sortOptions":sortOpt!,
                                "leftArea":navigation!["navigation"] as! NSArray
                                ])
                        }
                    }
                    
                    //Array items
                    if let items = mainArea["records"] as? [[String:Any]] {
                        for idx in 0 ..< items.count {
                            let item = items[idx]
                            var attributes = item["attributes"] as? [String:Any]
                            if let promodesc = attributes?["promoDescription"] as? String{
                                if promodesc != "null" {
                                    attributes?["saving"] = promodesc as AnyObject?
                                }
                            }
                            if let totalNumRec = mainArea["totalNumRecs"] as? String{
                                if totalNumRec != "null" {
                                    attributes?["totalResults"] = totalNumRec as AnyObject?
                                }
                            }
                            newItemsArray.append(attributes!)
                        }
                    }
                    successBlock?(newItemsArray, facets)
                }
                                
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at search products in groceries \(error)")
                errorBlock?(error)
                return
            }
        )
    }
    
    
    override func needsToLoginCode() -> Int {
        return -101
    }
    

}
