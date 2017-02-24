//
//  GRDeleteUserListService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class GRDeleteUserListService: GRBaseService {

    var listId: String?

    func buildParams(_ idList:String?) {
        self.listId = idList
    }
    
    func callService(_ params:[String:Any]?, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callGETService([:],
            successBlock: { (resultCall:[String:Any]) -> Void in
                successBlock?(resultCall)
                return
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    /**
     create query to delete list fromid list in db
     
     - parameter idList: id list
     */
    func deleteListInDB(_ idList:String){

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == %@", idList)
        
        let result: [List] = (try! self.managedContext!.fetch(fetchRequest)) as! [List]
        if result.count > 0 {
            for listDetail in result {
                self.managedContext!.delete(listDetail)
            }
        }
        self.saveContext()
    }

    override func serviceUrl() -> String {
        return super.serviceUrl() + "/"  + self.listId!
    }

}
