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

    func buildParams(string:String) -> [String:AnyObject] {
        return ["storeId":"","expression":string,"departmentName":"","family":""] as [String:AnyObject]
    }
    
    func callService(params:NSDictionary, successBlock:(([AnyObject]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        print("PARAMS FOR GRProductBySearchService")
        self.jsonFromObject(params)
        self.getManager().POST(serviceUrl(), parameters: params,
            success: {(request:NSURLSessionDataTask!, json:AnyObject!) in
              
                self.printTimestamp("success GRLinesForSearchService")
                 self.jsonFromObject(json)
                
                    if let response = json as? [AnyObject] {
                        
                        self.buildResponse(response, successBuildBlock: { (dictionary:[String : AnyObject]) -> Void in
                            // var dictionary = self.buildResponse(response)
                            let values = [AnyObject](dictionary.values)
                            
//                            values.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//                                var deptoOne = objectOne as [String:AnyObject]
//                                var deptoTwo = objectTwo as [String:AnyObject]
//                                var nameOne = deptoOne["name"] as NSString
//                                var nameTwo = deptoTwo["name"] as NSString
//                                NSLog("Sorting")
//                                return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//                                
//                            }

                            //                    self.jsonFromObject(values)
                            successBlock?(values)
                            
                        })
                       
                        
                    }
                    else {
                        successBlock?([])
                    }
                
            },
            failure: {(request:NSURLSessionDataTask!, error:NSError!) in
                if error.code == -1005 {
                    print("Response Error : \(error) \n Response \(request.response)")
                    self.callService(params, successBlock:successBlock, errorBlock:errorBlock)
                    return
                }
                print("Response Error : \(error) \n Response \(request.response)")
                errorBlock!(error)
        })
    }

    func buildResponse(response:[AnyObject],successBuildBlock:(([String : AnyObject]) -> Void)?) {

        printTimestamp("buildResponse GRLinesForSearchService")
        
        //let service = GRCategoryService()
        //var categories = service.getCategoriesContent() as NSArray
        
        //var tmpArray : [[String:AnyObject]] = []
        
        var strInLines : String = ""
        for i in 0 ..< response.count {
            var responseObject = response[i] as! [String:AnyObject]
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
        
         var dictionary: [String:AnyObject] = [:]
        
        if strInLines == "" {
            return  successBuildBlock!(dictionary)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { ()->() in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                
                let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesIdLineQuery(idline: strInLines)
                if let rs = db.executeQuery(selectCategories, withArgumentsInArray:nil) {
                    //var keywords = Array<AnyObject>()
                    while rs.next() {
                        let idDepto = rs.stringForColumn("idDepto")
                        let idFamily = rs.stringForColumn("idFamily")
                        let idLine = rs.stringForColumn("idLine")
                        
                        let depName = rs.stringForColumn("departament")
                        let famName = rs.stringForColumn("family")
                        let linName = rs.stringForColumn("line")
                        
                        
                        var cdepto = dictionary[idDepto] as? [String:AnyObject]
                        if cdepto == nil {
                            cdepto = [
                                "name" : depName,
                                "id" : idDepto,
                                "responseType" : ResultObjectType.Groceries.rawValue,
                                "level" : NSNumber(integer: 0),
                                "parentId" : "",
                                "path" : idDepto,
                                "families" : NSMutableDictionary()]
                            dictionary[idDepto] = cdepto
                        }
                        
                        let families = cdepto!["families"] as! NSMutableDictionary
                        var cfamily = families[idFamily] as? NSDictionary
                        if cfamily == nil {
                            families[idFamily] = [
                                "id" : idFamily,
                                "name" : famName,
                                "responseType" : ResultObjectType.Groceries.rawValue,
                                "level" : NSNumber(integer: 1),
                                "parentId" : idDepto,
                                "path" : "\(idDepto)|\(idFamily)",
                                "lines" : NSMutableDictionary()]
                            cfamily = families[idFamily] as? NSDictionary
                        }
                        
                        let lines = cfamily!["lines"] as! NSMutableDictionary
                        
                        let cline = [
                            "id" : idLine,
                            "name" : (linName),
                            "level" : NSNumber(integer: 2),
                            "parentId" : idFamily,
                            "path" : "\(idDepto)|\(idFamily)|\(idLine!)",
                            "responseType" : ResultObjectType.Groceries.rawValue]
                        lines[idLine] = cline
                        
                        //keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
                    }// while rs.next() {
                    
                    rs.close()
                    rs.setParentDB(nil)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Success")
                        successBuildBlock?(dictionary)
                    })
                    
                }
                
            }
        })
        
    }
    
}
