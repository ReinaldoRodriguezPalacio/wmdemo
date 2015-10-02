//
//  GRAddItemListService.swift
//  WalMart
//
//  Created by neftali on 22/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class GRAddItemListService: GRBaseService {
    
    func buildParams(idList idList:String, upcs:[AnyObject]?) -> [String:AnyObject]! {
        //{"idList":"26e50bc7-3644-48d8-a51c-73d7536ab30d","itemArrImp":[{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}]}
        return ["idList":idList, "itemArrImp":upcs!]
    }
    
    func buildProductObject(upc upc:String, quantity:Int,pesable:String,active:Bool) -> [String:AnyObject] {
        //{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        return ["longDescription" : "", "quantity" : quantity, "upc" : upc, "pesable" : pesable, "equivalenceByPiece" : "", "promoDescription" : "", "productIsInStores" : "","isActive":active]
    }
    
    func buildProductObject(upc upc:String, quantity:Int,pesable:String) -> [String:AnyObject] {
        // {"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        return ["longDescription" : "", "quantity" : quantity, "upc" : upc, "pesable" : pesable, "equivalenceByPiece" : "", "promoDescription" : "", "productIsInStores" : ""]
    }
    
    func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        var toSneditem : [String:AnyObject] = [:]
        let arrayItems = params["itemArrImp"] as! NSArray
        var arrayToSend : [[String:AnyObject]] = []
        for item in arrayItems {
            let paramUpc = item["upc"] as! String
            let paramQuantity = item["quantity"] as! Int
            let paramPesable = item["pesable"] as! String
            let toSendUPC = buildProductObject(upc: paramUpc, quantity: paramQuantity, pesable: paramPesable)
            arrayToSend.append(toSendUPC)
        }
        toSneditem["idList"] = params["idList"] as! String
        toSneditem["itemArrImp"] = arrayToSend
        
        self.callPOSTService(toSneditem,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                self.manageList(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
        
        
    }
    
    func manageList(list:NSDictionary) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if  let listId = list["id"] as? String {
            
            let user = UserCurrentSession.sharedInstance().userSigned
            var entity : List?  = nil
            if user!.lists != nil {
                let userLists : [List] = user!.lists!.allObjects as! [List]
                
                let resultLists = userLists.filter({ (list:List) -> Bool in
                    return list.idList == listId
                })
                if resultLists.count > 0 {
                    entity = resultLists[0]
                }
            }
            if entity == nil {
                entity = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context) as? List
                entity!.idList = listId
                entity!.user = UserCurrentSession.sharedInstance().userSigned!
                entity!.registryDate = NSDate()
                entity!.name = list["name"] as! String
                //println("Creating user list \(listId)")
                
                var error: NSError? = nil
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    print("error at save list: \(error!.localizedDescription)")
                }
            }
            else {
                let fetchRequest = NSFetchRequest()
                fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)
                fetchRequest.predicate = NSPredicate(format: "list == %@", entity!)
                let result: [Product] = (try! context.executeFetchRequest(fetchRequest)) as! [Product]
                if result.count > 0 {
                    for listDetail in result {
                        //println("Delete product list \(listDetail.upc)")
                        context.deleteObject(listDetail)
                    }
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        print("error at delete details: \(error1.localizedDescription)")
                    }
                }
            }
            
            if let items = list["items"] as? [AnyObject] {
                entity!.countItem = NSNumber(integer: items.count)
                
                for var idx = 0; idx < items.count; idx++ {
                    var item = items[idx] as! [String:AnyObject]
                    let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
                    detail!.upc = item["upc"] as! String
                    detail!.img = item["imageUrl"] as! String
                    detail!.desc = item["description"] as! String
                    if let active = item["isActive"] as? Bool {
                        detail!.isActive = active ? "true" : "false"
                    }
                    
                    if let price = item["price"] as? NSNumber {
                        detail!.price = "\(price)"
                    }
                    else if let price = item["price"] as? String {
                        detail!.price = price
                    }
                    detail!.list = entity!
                }
                
                var error: NSError? = nil
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    print("error at delete details: \(error!.localizedDescription)")
                }
                
            }
        }
        
    }
}
