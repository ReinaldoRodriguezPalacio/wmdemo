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

    var managedObjectContext: NSManagedObjectContext?

    func callService(_ successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        let params: NSDictionary = [:]
        self.callGETService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                if let values = resultCall["responseArray"] as? NSArray {
                    for idx in 0 ..< values.count {
                        if let item = values[idx] as? NSDictionary {
                            let storeID = item["storeID"] as? String
                            if storeID == nil {
                                continue
                            }
                            
                            var store = self.findStoreById(storeID)
                            if store == nil {
                                store = NSEntityDescription.insertNewObject(forEntityName: "Store", into: self.managedObjectContext!) as? Store
                                store!.storeID = storeID
                            }
                            
                            store!.name = item["name"] as? String
                            store!.address = item["address"] as? String
                            store!.telephone = item["telephone"] as? String
                            store!.manager = item["manager"] as? String
                            store!.zipCode = item["zipCode"] as? String
                            store!.opens = item["opens"] as? String

                            if let latSpanTxt = item["latSpan"] as? NSString {
                                store!.latSpan = NSNumber(value: latSpanTxt.doubleValue as Double)
                            }
                            if let lonSpanTxt = item["lonSpan"] as? NSString {
                                store!.lonSpan = NSNumber(value: lonSpanTxt.doubleValue as Double)
                            }
                            if let latPointTxt = item["latPoint"] as? NSString {
                                store!.latitude = NSNumber(value: latPointTxt.doubleValue as Double)
                            }
                            if let lonPointTxt = item["lonPoint"] as? NSString {
                                store!.longitude = NSNumber(value: lonPointTxt.doubleValue as Double)
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
            self.loadContext()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Store", in: self.managedObjectContext!)
            fetchRequest.predicate = NSPredicate(format: "storeID == %@", storeId!)
            var result: [Store] = (try! self.managedObjectContext!.fetch(fetchRequest)) as! [Store]
            if result.count > 0 {
                store = result[0]
            }
        }
        return store
    }

    // MARK: - NSManagedObjectContext
    
    func loadContext() {
        if self.managedObjectContext == nil {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            self.managedObjectContext = context
        }
    }
    
    func saveContext() {
        var error: NSError? = nil
        do {
            try self.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("")
        }
    }

}
