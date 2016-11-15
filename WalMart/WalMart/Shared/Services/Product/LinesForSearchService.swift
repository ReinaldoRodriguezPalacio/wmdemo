//
//  LinesForSearchService.swift
//  WalMart
//
//  Created by neftali on 23/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class LinesForSearchService: BaseService {

    func buildParams(_ string:String) -> [String:Any] {
        return ["id":string as AnyObject]
    }

    func callService(_ params:[String:Any], successBlock:(([Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        //println("PARAMS FOR LinesForSearchService" )
        printTimestamp("servicio LinesForSearchService")
        self.jsonFromObject(params)
        self.getManager().post(serviceUrl(), parameters: params,
            success: {(request:URLSessionDataTask!, json:AnyObject!) in
                self.jsonFromObject(json)
                self.printTimestamp("success LinesForSearchService")
                if let response = json["subCategories"] as? [Any] {
                    DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                        self.buildResponse(response, successBuildBlock: { (dictionary:[String : AnyObject]) -> Void in
                            let values = [Any](dictionary.values)
                            self.jsonFromObject(values)
                            DispatchQueue.main.async(execute: { () -> Void in
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
            failure: {(request:URLSessionDataTask!, error:NSError!) in
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
//        var values = [Any](dictionary.values)
//        values.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//            var deptoOne = objectOne as [String:Any]
//            var deptoTwo = objectTwo as [String:Any]
//            var nameOne = deptoOne["name"] as NSString
//            var nameTwo = deptoTwo["name"] as NSString
//            return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//        }
        
//        self.jsonFromObject(values)
 //       successBlock?(values)
        //~> End TEST
        
    }
    
    func buildResponse(_ response:[Any],successBuildBlock:(([String:Any]) -> Void)?) {
        
        printTimestamp("buildResponse LinesForSearchService")
        
        var strInLines : String = ""
        for i in 0 ..< response.count {
            var responseObject = response[i] as! [String:Any]
            let id = responseObject["subCategoryId"] as? String
            if id == nil {
                continue
            }
            if strInLines != "" {
                strInLines = "\(strInLines),\"\(id!)\""
            } else {
                strInLines = "\"\(id!)\""
            }
        }
        
        let dictionary: [String:Any] = [:]
        
        if strInLines == "" {
            return  successBuildBlock!(dictionary)
        }
        
        WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
            var dictionary: [String:Any] = [:]
            //NSLog("Ejecuta busqueda")
            let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesIdLineQuery(idline: strInLines)
            if let rs = db.executeQuery(selectCategories, withArgumentsIn:nil) {
                //var keywords = Array<AnyObject>()
                self.printTimestamp("query execute  LinesForSearchService")
                while rs.next() {
                    
                    let idDepto = rs.string(forColumn: "idDepto")
                    let idFamily = rs.string(forColumn: "idFamily")
                    let idLine = rs.string(forColumn: "idLine")
                    
                    let depName = rs.string(forColumn: "departament")
                    let famName = rs.string(forColumn: "family")
                    let linName = rs.string(forColumn: "line")
                    
                    
                    var cdepto = dictionary[idDepto] as? [String:Any]
                    if cdepto == nil {
                        cdepto = [
                            "name" : depName,
                            "id" : idDepto,
                            "responseType" : ResultObjectType.Mg.rawValue,
                            "level" : NSNumber(value: 0 as Int),
                            "parentId" : "",
                            "path" : idDepto,
                            "families" : NSMutableDictionary()]
                        dictionary[idDepto] = cdepto
                    }
                    
                    let families = cdepto!["families"] as! NSMutableDictionary
                    var cfamily = families[idFamily] as? [String:Any]
                    if cfamily == nil {
                        families[idFamily] = [
                            "id" : idFamily,
                            "name" : famName,
                            "responseType" : ResultObjectType.Mg.rawValue,
                            "level" : NSNumber(value: 1 as Int),
                            "parentId" : idDepto,
                            "path" : "\(idDepto)|\(idFamily)",
                            "lines" : NSMutableDictionary()]
                        cfamily = families[idFamily] as? [String:Any]
                    }
                    
                    let lines = cfamily!["lines"] as! NSMutableDictionary
                    
                    let cline = [
                        "id" : idLine,
                        "name" : (linName),
                        "level" : NSNumber(value: 2 as Int),
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
