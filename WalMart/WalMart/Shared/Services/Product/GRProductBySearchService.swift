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
    
    
    func buildParamsForSearch(text text:String?, family idFamily:String?, line idLine:String?, sort idSort:String?, departament idDepartment:String?, start startOffSet:Int, maxResult max:Int, brand:String?) -> [String:AnyObject]! {
        if useSignals {
            let channel = IS_IPAD ? "ipad" : "iphone"
            let searchText = text != nil ? text! : ""
            var parameter = ["q":searchText,"eventtype": "clickdetails","collection":"dah","channel": channel] as [String:AnyObject]
            if searchText == ""{
               parameter = ["category":idDepartment!,"eventtype": "categoryview","collection":"dah","channel": channel]
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
                ,"parameter":parameter] as [String:AnyObject]
        }
        return [
            JSON_KEY_TEXT:(text != nil ? text! : ""), //"pText"
            JSON_KEY_IDDEPARTMENT:(idDepartment != nil ? idDepartment! : ""), //"idDepartment"
            JSON_KEY_IDFAMILY:(idFamily != nil ? idFamily! : ""), //"idFamily"
            JSON_KEY_IDLINE:(idLine != nil ? idLine! : ""), //"idLine"
            JSON_KEY_SORT:(idSort != nil ? idSort! : ""), //"sort"
            JSON_KEY_STARTOFFSET:"\(startOffSet)", //startOffSet
            JSON_KEY_MAXRESULTS:"\(max)" //"maxResults"
            ,JSON_KEY_BRAND:(brand != nil ? brand! : "")//"brand"
        ] as [String:AnyObject]
    }

    func callService(params:NSDictionary, successBlock:((NSArray) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print("PARAMS FOR GRProductBySearchService")
        self.jsonFromObject(params)
        self.callPOSTService(params,
            successBlock: { (resultJSON:NSDictionary) -> Void in
//                println("RESULT FOR GRProductBySearchService")
//                self.jsonFromObject(resultJSON)
                
                if let error = self.validateCodeMessage(resultJSON) {
                    errorBlock?(error)
                    return
                }
                
                if let items = resultJSON[JSON_KEY_RESPONSEARRAY] as? NSArray {
                    self.saveKeywords(items) //Creating keywords
                    
                    //El atributo type en el JSON de producto ya existe. Por el momento se sobreescribe el valor para manejar la procedencia del mensaje.
                    var newItemsArray = Array<AnyObject>()
                    for var idx = 0; idx < items.count; idx++ {
                        var item = items[idx] as! [String:AnyObject]
                        if let promodesc = item["promoDescription"] as? String{
                            if promodesc != "null" {
                                item["saving"] = promodesc
                            }
                        }
                        item["pesable"] =  item["type"] as! NSString
                        item["type"] = ResultObjectType.Groceries.rawValue
                        newItemsArray.append(item)
                    }
                    
                    successBlock?(newItemsArray)
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
