//
//  LinesForSearchService.swift
//  WalMart
//
//  Created by neftali on 23/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class LinesForSearchService: BaseService {

    func buildParams(string:String) -> [String:AnyObject] {
        return ["pText":string]
    }

    func callService(params:NSDictionary, successBlock:(([AnyObject]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        //println("PARAMS FOR LinesForSearchService" )
        printTimestamp("servicio LinesForSearchService")
        self.jsonFromObject(params)
        self.getManager().POST(serviceUrl(), parameters: params,
            success: {(request:NSURLSessionDataTask!, json:AnyObject!) in
                print(json)
                self.jsonFromObject(json)
                self.printTimestamp("success LinesForSearchService")
                if let response = json["responseArray"] as? [AnyObject] {
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        self.buildResponse(response, successBuildBlock: { (dictionary:[String : AnyObject]) -> Void in
                            let values = [AnyObject](dictionary.values)
                            self.jsonFromObject(values)
                            dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                                print("")
                                successBlock?(values)
                            });
                        })
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
        
        //TEST: ->
        //var response = [
//            ["id":"l_autoasientos_convertibles", "name":"Autoasientos"],
//            ["id":"l_autoasientos_accesorios", "name":"Accesorios"],
//            ["id":"l_estimulacion_chupones", "name":"Mordederas y Chupones"],
//            ["id":"l_cuidadopersonal_depiladoras", "name":"Depilación"],
//            ["id":"l_cuidadopersonal_rasuradorashombre", "name":"Rasuradoras Hombre"],
//            ["id":"l_cuidadopersonal_basculas", "name":"Control de Peso"]
        //]
//        var dictionary = self.buildResponse(response)
//        var values = [AnyObject](dictionary.values)
//        values.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//            var deptoOne = objectOne as [String:AnyObject]
//            var deptoTwo = objectTwo as [String:AnyObject]
//            var nameOne = deptoOne["name"] as NSString
//            var nameTwo = deptoTwo["name"] as NSString
//            return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//        }
        
//        self.jsonFromObject(values)
 //       successBlock?(values)
        //~> End TEST
        
    }
    
    func buildResponse(response:[AnyObject],successBuildBlock:(([String:AnyObject]) -> Void)?) {
        
        printTimestamp("buildResponse LinesForSearchService")
        
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
        
        let dictionary: [String:AnyObject] = [:]
        
        if strInLines == "" {
            return  successBuildBlock!(dictionary)
        }
        
        WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
            var dictionary: [String:AnyObject] = [:]
            //NSLog("Ejecuta busqueda")
            let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesIdLineQuery(idline: strInLines)
            if let rs = db.executeQuery(selectCategories, withArgumentsInArray:nil) {
                //var keywords = Array<AnyObject>()
                self.printTimestamp("query execute  LinesForSearchService")
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
                            "responseType" : ResultObjectType.Mg.rawValue,
                            "level" : NSNumber(integer: 0),
                            "parentId" : "",
                            "path" : idDepto,
                            "families" : NSMutableDictionary()]
                        dictionary[idDepto] = cdepto
                    }
                    
                    let families = cdepto!["families"] as! NSMutableDictionary
                    var cfamily = families[idFamily] as? [String:AnyObject]
                    if cfamily == nil {
                        families[idFamily] = [
                            "id" : idFamily,
                            "name" : famName,
                            "responseType" : ResultObjectType.Mg.rawValue,
                            "level" : NSNumber(integer: 1),
                            "parentId" : idDepto,
                            "path" : "\(idDepto)|\(idFamily)",
                            "lines" : NSMutableDictionary()]
                        cfamily = families[idFamily] as? [String:AnyObject]
                    }
                    
                    let lines = cfamily!["lines"] as! NSMutableDictionary
                    
                    let cline = [
                        "id" : idLine,
                        "name" : (linName),
                        "level" : NSNumber(integer: 2),
                        "parentId" : idFamily,
                        "path" : "\(idDepto)|\(idFamily)|\(idLine!)",
                        "responseType" : ResultObjectType.Mg.rawValue]
                    lines[idLine] = cline
                    
                    //keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
                }// while rs.next() {
                rs.close()
                rs.setParentDB(nil)
                //println(dictionary)
                
                //NSLog("Despues de busqueda")
                self.printTimestamp("end dictionary LinesForSearchService")

                successBuildBlock?(dictionary)
            }
        }
        
    }
    
    
    
}
