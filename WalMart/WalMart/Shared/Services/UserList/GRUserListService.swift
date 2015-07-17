//
//  GRUserListService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/13/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRUserListService : GRBaseService {

    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callGETService(params,
            successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                if let list = resultCall["responseArray"] as? [AnyObject] {
                    self.manageListData(list)
                }

                self.mergeList(resultCall, successBlock: successBlock, errorBlock: errorBlock)
            },
            errorBlock: { (error:NSError) -> Void in
                if error.code == 1 { //"Listas no Encontradas"
                    self.mergeList([:], successBlock: successBlock, errorBlock: errorBlock)
                }
                else {
                    errorBlock?(error)
                }
                return
            }
        )
    }
    
    //MARK: -
    
    func mergeList(response:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        var notSyncList = self.retrieveNotSyncList()
        if notSyncList != nil && notSyncList!.count > 0 {
            var list = notSyncList!.first
            var listToMerge: [String:AnyObject]? = nil

            let currentLists = response["responseArray"] as? [AnyObject]
            if currentLists != nil && currentLists!.count > 0 {
                for var idx = 0; idx < currentLists!.count; idx++ {
                    var innerList = currentLists![idx] as [String:AnyObject]
                    if let name = innerList["name"] as? String {
                        if name == list!.name {
                            listToMerge = innerList
                            break
                        }
                    }
                }
            }
            
            if listToMerge == nil {
                let service = GRSaveUserListService()
                
                var items:[AnyObject] = []
                list!.products.enumerateObjectsUsingBlock({ (obj:AnyObject!, flag:UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let product = obj as? Product {
                        var param = service.buildProductObject(upc: product.upc, quantity: product.quantity.integerValue, image: product.img, description: product.desc, price: product.price, type: "\(product.type)")
                        items.append(param)
                    }
                })

                service.callService(service.buildParams(list!.name, items: items),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.managedContext!.deleteObject(list!)
                        self.saveContext()
                        if notSyncList!.count == 0 {
                            NSNotificationCenter.defaultCenter().postNotificationName("ReloadListFormUpdate", object: self)
                        }
                        self.mergeList(response, successBlock: successBlock, errorBlock:errorBlock)
                        
                    },
                    errorBlock: { (error:NSError) -> Void in
                        println("Error at merge new list \(error)")
                        if error.code == -13 {
                            self.managedContext!.deleteObject(list!)
                            self.saveContext()
                            self.mergeList(response, successBlock: successBlock, errorBlock:errorBlock)
                            return
                        }
                        errorBlock?(error)
                    }
                )
            }
            else {
                var listId = listToMerge!["id"] as String
                //Con la invocacion del mismo servicio se puede hacer add/update del producto
                var array = list!.products.allObjects as [Product]
                var addItemService = GRAddItemListService()
                var params:[AnyObject] = []
                for product in array {
                    var param = addItemService.buildProductObject(upc: product.upc, quantity: product.quantity.integerValue,pesable:product.type.stringValue)
                    params.append(param)
                }
                
                addItemService.callService(addItemService.buildParams(idList: listId, upcs: params),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.managedContext!.deleteObject(list!)
                        self.saveContext()
                        self.mergeList(response, successBlock: successBlock, errorBlock:errorBlock)
                    },
                    errorBlock: { (error:NSError) -> Void in
                        println("Error at merge list \(error)")
                        errorBlock?(error)
                    }
                )
                
            }
        }
        else {
            
            successBlock?(response)
        }
    }
    
    
    //MARK: -
    
    func manageListData(list:[AnyObject]) {
        let user = UserCurrentSession.sharedInstance().userSigned
        if user == nil {
            println("Se recibio respuesta del servicio GRUserListService sin tener usuario firmado.")
            return
        }

        if let userList = self.retrieveUserList() {
            for entity in userList {
                var exist = false
                for serviceList in list {
                    let listId = serviceList["id"] as String
                    if entity.idList == listId {
                        exist = true
                        break
                    }
                }
                if !exist {
                    //self.removeNotificationsFromList(list.idList)
                    self.managedContext!.deleteObject(entity)
                }
            }
        }

        for serviceList in list {
            let listId = serviceList["id"] as String
            
            var toUseList : List?  = nil
            if user!.lists != nil {
                var userLists : [List] = user!.lists!.allObjects as [List]
                
                let resultLists = userLists.filter({ (list:List) -> Bool in
                    return list.idList == listId
                })
                if resultLists.count > 0 {
                    toUseList = resultLists[0]
                }
            }
            if toUseList == nil {
                toUseList = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedContext!) as? List
                
                toUseList!.idList = listId
                toUseList!.user = UserCurrentSession.sharedInstance().userSigned!
                toUseList!.registryDate = NSDate()
                //println("Creating user list \(listId)")
            }
            
            if let name = serviceList["name"] as? String {
                toUseList!.name = name
            }
            
            var updateDetailList = false
            if let countItems = serviceList["countItem"] as? NSNumber {
                toUseList!.countItem = countItems
                updateDetailList = countItems.integerValue > 0
            }
            
            var error: NSError? = nil
            self.managedContext!.save(&error)
            if error != nil {
                println("error at save list: \(error!.localizedDescription)")
            }
            
            if(updateDetailList) {
                
                let fetchRequest = NSFetchRequest()
                fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
                fetchRequest.predicate = NSPredicate(format: "list == %@", toUseList!)
                var error: NSError? = nil
                var result: [Product] = self.managedContext!.executeFetchRequest(fetchRequest, error: &error) as [Product]
                if result.count > 0 {
                    for listDetail in result {
                        //println("Delete product list \(listDetail.upc)")
                        self.managedContext!.deleteObject(listDetail)
                    }
                    
                    var error: NSError? = nil
                    self.managedContext!.save(&error)
                    if error != nil {
                        println("error at delete details: \(error!.localizedDescription)")
                    }
                }
                
                let detailService = GRUserListDetailService()
                detailService.buildParams(listId)
                detailService.callService([:],
                    successBlock: { (result:NSDictionary) -> Void in
                        if let items = result["items"] as? NSArray {
                            
                            var parentList = self.findListById(listId)
                            if parentList == nil {
                                println("User list not founded \(listId)")
                                return
                            }
                            
                            for var idx = 0; idx < items.count; idx++ {
                                var item = items[idx] as [String:AnyObject]
                                var detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.managedContext!) as? Product
                                detail!.upc = item["upc"] as String
                                detail!.img = item["imageUrl"] as String
                                detail!.desc = item["description"] as String
                                if let price = item["price"] as? NSNumber {
                                    detail!.price = "\(price)"
                                }
                                else if let price = item["price"] as? String {
                                    detail!.price = price
                                }
                                if let quantity = item["quantity"] as? NSNumber {
                                    detail!.quantity = quantity
                                }
                                else if let quantity = item["quantity"] as? String {
                                    detail!.quantity = NSNumber(integer: quantity.toInt()!)
                                }
                                if let type = item["type"] as? String {
                                    detail!.type = NSNumber(integer: type.toInt()!)
                                }
                                else if let type = item["type"] as? NSNumber {
                                    detail!.type = type
                                }
                                //
                                detail!.list = parentList!
                                
                                var error: NSError? = nil
                                self.managedContext!.save(&error)
                                if error != nil {
                                    println("error at delete details: \(error!.localizedDescription)")
                                }
                            }
                        }
                    },
                    errorBlock: { (error:NSError) -> Void in
                        println("Error at retrieve list detail")
                    }
                )
            }
            
        }
        
    }
    
    //MARK: - DB
    
    func retrieveUserList() -> [List]? {
        var userList: [List]?
        var user = UserCurrentSession.sharedInstance().userSigned
        if user != nil {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("List" as NSString, inManagedObjectContext: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "user == %@", user!)
            var error: NSError? = nil
            userList = self.managedContext!.executeFetchRequest(fetchRequest, error: &error) as? [List]
        }
        return userList
    }
    
    func findListById(listId:String) -> List? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List" as NSString, inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == %@", listId)
        var error: NSError? = nil
        var result: [List] = self.managedContext!.executeFetchRequest(fetchRequest, error: &error) as [List]
        var list: List? = nil
        if result.count > 0 {
            list = result[0]
        }
        return list
    }

    func retrieveNotSyncList() -> [List]? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == nil")
        var error: NSError? = nil
        var result: [List]? = self.managedContext!.executeFetchRequest(fetchRequest, error: &error) as [List]?
        return result
    }

    func saveContext() {
        var error: NSError? = nil
        self.managedContext!.save(&error)
        if error != nil {
            println("error at save context on UserListViewController: \(error!.localizedDescription)")
        }
    }

}

