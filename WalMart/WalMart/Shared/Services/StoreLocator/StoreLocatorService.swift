//
//  StoreLocatorService.swift
//  WalMart
//
//  Created by neftali on 03/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class StoreLocatorService: BaseService {

    func callService(_ successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let params: [String:Any] = [:]
        self.callGETService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
                if let values = resultCall["responseArray"] as? [Any] {
                    for idx in 0 ..< values.count {
                        if let item = values[idx] as? [String:Any] {
                            let storeID = item["storeID"] as? String
                            if storeID == nil {
                                continue
                            }
                            
                            var store = self.findStoreById(storeID)
                            if store == nil {
                                store = NSEntityDescription.insertNewObject(forEntityName: "Store", into: self.managedContext!) as? Store
                                store!.storeID = storeID
                            }
                            
                            store!.name = item["name"] as? String
                            store!.address = item["address"] as? String
                            store!.telephone = item["telephone"] as? String
                            store!.manager = item["manager"] as? String
                            store!.zipCode = item["zipCode"] as? String
                            store!.opens = item["opens"] as? String

                            if let latSpanTxt = item["latSpan"] as? NSString {
                                store!.latSpan = NSNumber(value: latSpanTxt.doubleValue)
                            }
                            if let lonSpanTxt = item["lonSpan"] as? NSString {
                                store!.lonSpan = NSNumber(value: lonSpanTxt.doubleValue)
                            }
                            if let latPointTxt = item["latPoint"] as? NSString {
                                store!.latitude = NSNumber(value: latPointTxt.doubleValue)
                            }
                            if let lonPointTxt = item["lonPoint"] as? NSString {
                                store!.longitude = NSNumber(value: lonPointTxt.doubleValue)
                            }

                        }
                    }
                    self.saveContext()
                }
                successBlock?(resultCall)
                return
            }, errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    // MARK: - DB
    
    func findStoreById(_ storeId:String?) -> Store? {
        var store: Store? = nil
        if storeId != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Store", in: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "storeID == %@", storeId!)
            var result: [Store] = (try! self.managedContext!.fetch(fetchRequest)) as! [Store]
            if result.count > 0 {
                store = result[0]
            }
        }
        return store
    }

    // MARK: - NSManagedObjectContext
    
}
