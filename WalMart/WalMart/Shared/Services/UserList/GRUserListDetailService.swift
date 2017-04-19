//
//  GRUserListDetailService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class GRUserListDetailService: GRBaseService {
    var listId: String?
    
    func buildParams(_ listId:String?) {
        self.listId = listId
    }
    
    func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        super.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
                //self.jsonFromObject(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock:{ (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    override func serviceUrl() -> String {
        return super.serviceUrl() + "/"  + (self.listId == nil ? "" : self.listId!)
    }
    

    func callCoreDataService(listId:String, successBlock:((List?,[Product]?) -> Void)?, errorBlock:((NSError) -> Void)?) {
        
        let list = findListById(listId)
        let products = getProductsFor(list: list!)
        
        successBlock?(list,products)
    }
    
    
    func getProductsFor(list:List) -> [Product] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product" as String, in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "list == %@", list)
        let result: [Product] = (try! self.managedContext!.fetch(fetchRequest) as! [Product])
        
        return result
    }
    
    func findListById(_ listId:String) -> List? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List" as String, in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == %@", listId)
        var result: [List] = (try! self.managedContext!.fetch(fetchRequest)) as! [List]
        var list: List? = nil
        if result.count > 0 {
            list = result[0]
        }
        return list
    }

}
