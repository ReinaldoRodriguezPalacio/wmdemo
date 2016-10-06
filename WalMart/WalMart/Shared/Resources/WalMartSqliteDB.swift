//
//  WALMARTSqliteDB.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 09/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

let PRODUCT_KEYWORD_TABLE = "ProductKeywords"
let KEYWORD_TITLE_COLUMN = "title"
let KEYWORD_IDLINE_COLUMN = "idLine"
let CATEGORIES_KEYWORD_TABLE = "CategoriesKeywords"

class WalMartSqliteDB: NSObject {
    let DB_NAME = "keywords.sqlite"
   
    let CREATE_PRODUCT_TABLE_QUERY = "CREATE VIRTUAL TABLE IF NOT EXISTS \(PRODUCT_KEYWORD_TABLE) USING fts3(\(KEYWORD_TITLE_COLUMN) VARCHAR(256) NOT NULL , upc VARCHAR(10) NOT NULL, price VARCHAR(10) NOT NULL);"
 
    let CREATE_CATEGORIES_TABLE_QUERY = "CREATE VIRTUAL TABLE IF NOT EXISTS \(CATEGORIES_KEYWORD_TABLE) USING fts3(\(KEYWORD_TITLE_COLUMN) VARCHAR(256) NOT NULL , departament VARCHAR(50) NOT NULL, type VARCHAR(12) NOT NULL, idLine VARCHAR(20) not null, idFamily VARCHAR(20) not null, idDepto VARCHAR(20) not null,family VARCHAR(20) not null,line VARCHAR(20) not null );"
 
    
    lazy var dataBase: FMDatabaseQueue = {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray!
        var docPath = paths[0] as! NSString
        var dbPath = docPath.stringByAppendingPathComponent(self.DB_NAME)
        
        var error : NSError? = nil
        let todeletecloud =  NSURL(fileURLWithPath: docPath as String)
        do {
            try todeletecloud.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
        } catch var error1 as NSError {
            error = error1
        } catch {
            fatalError()
        }

        
        var queueDB: FMDatabaseQueue = FMDatabaseQueue.dbQueueWithPath(dbPath)
        queueDB.inDatabase({ (db:FMDatabase!) in
            
            if let rs = db.executeQuery(self.CREATE_PRODUCT_TABLE_QUERY, withArgumentsInArray:nil) {
                while rs.next() {
                    print(rs.resultDictionary())
                }
                rs.close()
                rs.setParentDB(nil)
            }
        
            if let rsCategories = db.executeQuery(self.CREATE_CATEGORIES_TABLE_QUERY, withArgumentsInArray:nil) {
                while rsCategories.next() {
                    print(rsCategories.resultDictionary())
                }
                rsCategories.close()
                rsCategories.setParentDB(nil)
            }

        })
        
        return queueDB
        }()
    
    struct Static {
        static var token : dispatch_once_t = 0
        static var instance : WalMartSqliteDB?
    }
    
    class var instance: WalMartSqliteDB {
    dispatch_once(&Static.token) {
        Static.instance = WalMartSqliteDB()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
        assert(Static.instance == nil, "Singleton already initialized!")
    }

    // MARK: - ProductQueries
    func buildInsertProductKeywordQuery(forUpc upc:String, andDescription desc:String, andPrice price:String) -> String {
        return "INSERT INTO \(PRODUCT_KEYWORD_TABLE) (upc, price ,\(KEYWORD_TITLE_COLUMN)) VALUES('\(upc)','\(price)','\(desc)');"
    }
    
    /*func buildInsertProductKeywordQuery(#description:String) -> String {
        return "INSERT INTO \(PRODUCT_KEYWORD_TABLE) (\(KEYWORD_TITLE_COLUMN)) VALUES(\"\(description)\");"
    }*/
    
    func buildFindProductKeywordQuery(description description:String, price:String) -> String {
        return "SELECT * FROM \(PRODUCT_KEYWORD_TABLE) WHERE \(KEYWORD_TITLE_COLUMN) = '\(description)\' and price = \'\(price)\';"
    }
    
    func buildSearchProductKeywordsQuery(keyword keyword:String) -> String {
        return "SELECT * FROM \(PRODUCT_KEYWORD_TABLE) WHERE \(KEYWORD_TITLE_COLUMN) MATCH \"\(keyword)*\"  ORDER BY \(KEYWORD_TITLE_COLUMN);"
    }

    // MARK: - CategoriesQueries
    func buildInsertCategoriesKeywordQuery(forCategorie categorie:String, andDepartament departament:String, andType type:String , andLine idLine:String, andFamily idFamily:String , andDepto idDepto:String,family:String,line:String ) -> String {
        return "INSERT INTO \(CATEGORIES_KEYWORD_TABLE) (departament , type  , idLine , idFamily, idDepto,  \(KEYWORD_TITLE_COLUMN) ,family,line) VALUES('\(departament)','\(type)','\(idLine)','\(idFamily)','\(idDepto)', '\(categorie)', '\(family)', '\(line)');"
    }
    
    func buildFindCategoriesKeywordQuery(categories categories:String, departament:String, type:String, idLine: String ) -> String {
         return "SELECT * FROM \(CATEGORIES_KEYWORD_TABLE) WHERE type=\'\(type)\' and idLine=\'\(idLine)\' ;"
    }
    
    func buildSearchCategoriesKeywordsQuery(keyword keyword:String) -> String {
        return "SELECT * FROM \(CATEGORIES_KEYWORD_TABLE) WHERE \(KEYWORD_TITLE_COLUMN) MATCH \"\(keyword)*\"  ORDER BY \(KEYWORD_TITLE_COLUMN);"
    }
    
    func buildSearchCategoriesIdLineQuery(idline idline:String) -> String {
        return "SELECT * FROM \(CATEGORIES_KEYWORD_TABLE) WHERE \(KEYWORD_IDLINE_COLUMN) IN(\(idline));"
    }
    
    func buildSearchCategoriesIdFamilyQuery(idFamily idFamily:String) -> String {
        return "SELECT * FROM \(CATEGORIES_KEYWORD_TABLE) WHERE idFamily IN('\(idFamily)');"
    }
    
    
    
}
