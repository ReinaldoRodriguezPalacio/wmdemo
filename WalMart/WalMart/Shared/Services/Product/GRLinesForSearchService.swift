//
//  GRLinesForSearchService.swift
//  WalMart
//
//  Created by neftali on 18/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRLinesForSearchService: GRBaseService {

    override init() {
        super.init()
        self.urlForSession = true
    }

    func buildParams(_ string:String) -> [String:Any] {
        return ["storeId":"","expression":string,"departmentName":"","family":""] as [String:Any]
    }
    
    func callService(_ params:[String:Any], successBlock:(([[String:Any]]) -> Void)?, errorBlock:((NSError) -> Void)?) {
//        println("PARAMS FOR GRProductBySearchService")
        //self.jsonFromObject(params)
        self.getManager().post(serviceUrl(), parameters: params, progress: nil
            ,success: {(request:URLSessionDataTask, json:Any?) in
               //self.jsonFromObject(json)
                self.printTimestamp("success GRLinesForSearchService")
                
                    if let response = json as? [Any] {
                        
                        self.buildResponse(response, successBuildBlock: { (dictionary:[String : Any]) -> Void in
                            // var dictionary = self.buildResponse(response)
                            let values =  [Any](dictionary.values)
                            
//                            values.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//                                var deptoOne = objectOne as [String:Any]
//                                var deptoTwo = objectTwo as [String:Any]
//                                var nameOne = deptoOne["name"] as NSString
//                                var nameTwo = deptoTwo["name"] as NSString
//                                NSLog("Sorting")
//                                return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//                                
//                            }

                            //                    self.jsonFromObject(values)
                            successBlock?(values as! [[String : Any]])
                            
                        })
                       
                        
                    }
                    else {
                        successBlock?([])
                    }
                
            },
            failure: {(request:URLSessionDataTask?, error:Error) in
                if (error as NSError).code == -1005 {
                    print("Response Error : \(error) \n Response \(request!.response)")
                    self.callService(params, successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error) \n Response \(request!.response)")
                errorBlock!(error as NSError)
        })
    }

    func buildResponse(_ response:[Any],successBuildBlock:(([String : Any]) -> Void)?) {

        printTimestamp("buildResponse GRLinesForSearchService")
        
        //let service = GRCategoryService()
        //var categories = service.getCategoriesContent() as [Any]
        
        //var tmpArray : [[String:Any]] = []
        
        var strInLines : String = ""
        for i in 0 ..< response.count {
            var responseObject = response[i] as! [String:Any]
            let id = responseObject["id"] as? String
            if id == nil {
                continue
            }
            if strInLines != "" {
                strInLines = "\(strInLines),\"\(id!)\""
            } else {
                strInLines = "\"\(id!)\""
            }
        }
        
         var dictionary: [String:Any] = [:]
        
        if strInLines == "" {
            return  successBuildBlock!(dictionary as [String : Any])
        }
        DispatchQueue.global(qos: .background).async(execute: { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase?) -> Void in
                
                let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesIdLineQuery(idline: strInLines)
                if let rs = db?.executeQuery(selectCategories, withArgumentsIn:nil) {
                    //var keywords = Array<AnyObject>()
                    while rs.next() {
                        let idDepto = rs.string(forColumn: "idDepto")
                        let idFamily = rs.string(forColumn: "idFamily")
                        let idLine = rs.string(forColumn: "idLine")
                        
                        let depName = rs.string(forColumn: "departament")
                        let famName = rs.string(forColumn: "family")
                        let linName = rs.string(forColumn: "line")
                        
                        
                        var cdepto = dictionary[idDepto!] as? [String:Any]
                        if cdepto == nil {
                            cdepto = [
                                "name" : depName!,
                                "id" : idDepto!,
                                "responseType" : ResultObjectType.Groceries.rawValue,
                                "level" : NSNumber(value: 0 as Int),
                                "parentId" : "",
                                "path" : idDepto!,
                                "families" : [String:Any]()]
                            dictionary[idDepto!] = cdepto
                        }
                        
                        var families = cdepto!["families"] as! [String:Any]
                        var cfamily = families[idFamily!] as? [String:Any]
                        if cfamily == nil {
                            families[idFamily!] = [
                                "id" : idFamily!,
                                "name" : famName!,
                                "responseType" : ResultObjectType.Groceries.rawValue,
                                "level" : NSNumber(value: 1 as Int),
                                "parentId" : idDepto!,
                                "path" : "\(idDepto)|\(idFamily)",
                                "lines" : [String:Any]()]
                            cfamily = families[idFamily!] as? [String:Any]
                        }
                        
                        var lines = cfamily!["lines"] as! [String:Any]
                        
                        let cline = [
                            "id" : idLine!,
                            "name" : (linName)!,
                            "level" : NSNumber(value: 2 as Int),
                            "parentId" : idFamily!,
                            "path" : "\(idDepto)|\(idFamily)|\(idLine!)",
                            "responseType" : ResultObjectType.Groceries.rawValue] as [String : Any]
                        lines[idLine!] = cline
                        
                        //keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
                    }// while rs.next() {
                    
                    rs.close()
                    rs.setParentDB(nil)
                    
                    DispatchQueue.main.async(execute: {
                        print("Success")
                        successBuildBlock?(dictionary)
                    })
                    
                }
                
            }
        })
        
    }
    
    //MARK: 
    func buildResponseFamily(_ idFamilies:[String],successBuildBlock:(([String : Any]) -> Void)?) {
        
        
        var dictionary: [String:Any] = [:]
        var idFamilyQuery :String = ""
        for index in 0 ..< idFamilies.count {
            idFamilyQuery += index == (idFamilies.count - 1)  ? "'\(idFamilies[index])'" : "'\(idFamilies[index])',"
        }
        

        DispatchQueue.global(qos: .background).async(execute: { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase?) -> Void in
                
                let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesIdFamilyQuery(idFamily: idFamilyQuery as String)
                if let rs = db?.executeQuery(selectCategories, withArgumentsIn:nil) {
                    //var keywords = Array<AnyObject>()
                    while rs.next() {
                        let idDepto = rs.string(forColumn: "idDepto")
                        let idFamily = rs.string(forColumn: "idFamily")
                        let idLine = rs.string(forColumn: "idLine")
                        
                        let depName = rs.string(forColumn: "departament")
                        let linName = rs.string(forColumn: "line")
                        
                        
                        var cdepto = dictionary[idDepto!] as? [String:Any]
                        if cdepto == nil {
                            cdepto = [
                                "name" : depName!,
                                "id" : idDepto!,
                                "families" : [String:Any]()]
                            dictionary[idDepto!] = cdepto
                        }
                        
                        var families = cdepto!["families"] as! [String:Any]
                        var cfamily = families[idFamily!] as? [String:Any]
                        if cfamily == nil {
                            families[idFamily!] = [
                                "id" : idFamily!,
                                "lines" : [String:Any]()
                            ]
                            cfamily = families[idFamily!] as? [String:Any]
                        }
                        
                        var lines = cfamily!["lines"] as! [String:Any]
                        
                        let cline = [
                            "id" : idLine,
                            "name" : (linName),
                          
                        ]
                        lines[idLine!] = cline
                      
                    }// while rs.next() {
                    
                    rs.close()
                    rs.setParentDB(nil)
                    
                    DispatchQueue.main.async(execute: {
                        print("Success")
                        successBuildBlock?(dictionary)
                    })
                    
                }
                
            }
        })
        
    }

    
}
