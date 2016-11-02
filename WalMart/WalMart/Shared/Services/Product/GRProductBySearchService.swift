//
//  GRProductBySearchService.swift
//  WalMart
//
//  Created by neftali on 22/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class GRProductBySearchService: GRBaseService {
   var useSignals = false
    override init() {
        super.init()
        self.urlForSession = true
    }
    
    
    init(dictionary:NSDictionary){
        super.init()
        self.urlForSession = true
        self.useSignalsServices = dictionary["signals"] as! Bool
        self.useSignals = self.useSignalsServices
    }
    
    
    func buildParamsForSearch(text:String?, family idFamily:String?, line idLine:String?, sort idSort:String?, departament idDepartment:String?, start startOffSet:Int, maxResult max:Int, brand:String?) -> [String:Any]! {
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
    }

    func callService(_ params:[String:Any], successBlock:(([AnyObject],_ facet:[AnyObject]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        //print("PARAMS FOR GRProductBySearchService walmartgroceries/login/getItemsBySearching")
        self.jsonFromObject(params as AnyObject!)
        self.callPOSTService(params,
                             successBlock: { (resultJSON:[String:Any]) -> Void in
                //print("RESULT FOR GRProductBySearchService walmartgroceries/login/getItemsBySearching")
                self.jsonFromObject(resultJSON as AnyObject!)
                
                if let error = self.validateCodeMessage(resultJSON as NSDictionary) {
                    errorBlock?(error)
                    return
                }
                
                var newItemsArray = Array<AnyObject>()
                var facets = Array<AnyObject>()
                
                if let items = resultJSON[JSON_KEY_RESPONSEARRAY] as? NSArray {
                    self.saveKeywords(items) //Creating keywords
                    
                    //El atributo type en el JSON de producto ya existe. Por el momento se sobreescribe el valor para manejar la procedencia del mensaje.
                    var newItemsArray: [AnyObject] = []
                    for idx in 0 ..< items.count {
                        var item = items[idx] as! [String:Any]
                        if let promodesc = item["promoDescription"] as? String{
                            if promodesc != "null" {
                                item["saving"] = promodesc as AnyObject?
                            }
                        }
                        item["pesable"] =  item["type"] as! NSString
                        item["type"] = ResultObjectType.Groceries.rawValue as AnyObject?
                        newItemsArray.append(item as AnyObject)
                    }
                    successBlock?(newItemsArray, facets)
                }
                
                //Search service Text
                if let responseObject = resultJSON[JSON_KEY_RESPONSEOBJECT] as? NSDictionary {
                    //Array facet
                    if let itemsFacets = responseObject["facet"] as? [AnyObject] {
                        facets = itemsFacets
                    }
                    //Array items
                    if let items = responseObject["items"] as? NSArray {
                        for idx in 0 ..< items.count {
                            var item = items[idx] as! [String:Any]
                            if let promodesc = item["promoDescription"] as? String{
                                if promodesc != "null" {
                                    item["saving"] = promodesc as AnyObject?
                                }
                            }
                            newItemsArray.append(item as AnyObject)
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
        return -100
    }
    

}
