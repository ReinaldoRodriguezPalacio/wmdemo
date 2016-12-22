//
//  GRUserListService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/13/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRUserListService : BaseService {

    var isLoadingLists = false
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        if !isLoadingLists {
            isLoadingLists = false
            self.callGETService(params,
                successBlock: { (resultCall:NSDictionary) -> Void in
                    //self.jsonFromObject(resultCall)
                    if let list = resultCall["responseArray"] as? [AnyObject] {
                        //self.manageListData(list)
                    }
                    
                    self.mergeList(resultCall, successBlock: successBlock, errorBlock: errorBlock)
                    self.isLoadingLists = false
                },
                errorBlock: { (error:NSError) -> Void in
                    if error.code == 1 { //"Listas no Encontradas"
                        self.mergeList([:], successBlock: successBlock, errorBlock: errorBlock)
                    }
                    else {
                        errorBlock?(error)
                    }
                     self.isLoadingLists = false
                    return
                }
            )
        }
    }
    
    //MARK: -
    
    func mergeList(response:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        let notSyncList = self.retrieveNotSyncList()
        
        if notSyncList != nil && notSyncList!.count > 0 {
            let list = notSyncList!.first
            var listToMerge: [String:AnyObject]? = nil

            let currentLists = response["responseArray"] as? [AnyObject]
            if currentLists != nil && currentLists!.count > 0 {
                for idx in 0 ..< currentLists!.count {
                    var innerList = currentLists![idx] as! [String:AnyObject]
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
                list!.products.enumerateObjectsUsingBlock({ (obj:AnyObject, flag:UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let product = obj as? Product {
                        let param = service.buildProductObject(upc: product.upc, quantity: product.quantity.integerValue, image: product.img, description: product.desc, price: product.price as String, type: "\(product.type)",nameLine: product.nameLine)
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
                        print("Error at merge new list \(error)")
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
                let listId = listToMerge!["id"] as! String
                //Con la invocacion del mismo servicio se puede hacer add/update del producto
                let array = list!.products.allObjects as! [Product]
                let addItemService = GRAddItemListService()
                var params:[AnyObject] = []
                for product in array {
                    //let param = addItemService.buildProductObject(upc: product.upc, quantity: product.quantity.integerValue,pesable:product.type.stringValue)
                    let param =  addItemService.buildItemMustang(product.upc, sku: "00750226892092_000897302", quantity: product.quantity.integerValue)
                    params.append(param)
                }
                
                addItemService.callService(addItemService.buildItemMustangObject(idList: listId, upcs: params),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.managedContext!.deleteObject(list!)
                        self.saveContext()
                        self.mergeList(response, successBlock: successBlock, errorBlock:errorBlock)
                    },
                    errorBlock: { (error:NSError) -> Void in
                        print("Error at merge list \(error)")
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
            print("Se recibio respuesta del servicio GRUserListService sin tener usuario firmado.")
            return
        }

        let arryListLocal:NSMutableArray = []
        
        //Delete list deleting in other
        for serviceList in list {
            arryListLocal.addObject(serviceList["repositoryId"] as! String)
        }
        
        if let userList = self.retrieveUserList() {
            for entity in userList {
                var exist = false
                if entity.idList != nil {
                    if arryListLocal.containsObject(entity.idList!){
                        print("EXISTE")
                    }else{
                        print("NO EXISTE")
                        //self.removeNotificationsFromList(list.idList)
                        self.deleteItemInDB(entity.idList!)
                        self.managedContext!.deleteObject(entity)
                    }
                }
                
                
                for serviceList in list {
                    let listId = serviceList["repositoryId"] as! String
                    if entity.idList == listId {
                        exist = true
                        break
                    }
                }
                if !exist {
                    //self.removeNotificationsFromList(list.idList)
                    // self.managedContext!.deleteObject(entity)
                }
            }
        }
      
        
        

        for serviceList in list {
            let listId = serviceList["repositoryId"] as! String
            
            var toUseList : List?  = nil
            if user!.lists != nil {
                let userLists : [List] = user!.lists!.allObjects as! [List]
                
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
            let countItems = serviceList["giftlistItems"] as? NSArray
            
            //if let countItems = countItems!.count {
                toUseList!.countItem = countItems!.count
                updateDetailList = countItems!.count > 0
            //}
            
            var error: NSError? = nil
            do {
                try self.managedContext!.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                print("error at save list: \(error!.localizedDescription)")
            }
            
            if(updateDetailList) {
                
                let fetchRequest = NSFetchRequest()
                fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
                fetchRequest.predicate = NSPredicate(format: "list == %@", toUseList!)
                let result: [Product] = (try! self.managedContext!.executeFetchRequest(fetchRequest)) as! [Product]
                if result.count > 0 {
                    for listDetail in result {
                        //println("Delete product list \(listDetail.upc)")
                        self.managedContext!.deleteObject(listDetail)
                    }
                    
                    var error: NSError? = nil
                    do {
                        try self.managedContext!.save()
                    } catch let error1 as NSError {
                        error = error1
                    }
                    if error != nil {
                        print("error at delete details: \(error!.localizedDescription)")
                    }
                }

                
                        if let items =  serviceList["giftlistItems"] as? NSArray{
                            
                            let parentList = self.findListById(listId)
                            if parentList == nil {
                                print("User list not founded \(listId)")
                                return
                            }
                            
                            for idx in 0 ..< items.count {
                                var item = items[idx] as! [String:AnyObject]
                                let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.managedContext!) as? Product
                                print("UPC:::")
                                print(item["upc"] as! String)
                                detail!.upc = item["upc"] as! String
                                detail!.img = item["imageUrl"] as! String
                                detail!.desc = item["description"] as! String
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
                                    detail!.quantity = NSNumber(integer: Int(quantity)!)
                                }
                                if let type = item["type"] as? String {
                                    detail!.type = NSNumber(integer: Int(type)!)
                                }
                                else if let type = item["type"] as? NSNumber {
                                    detail!.type = type
                                }
                                //
                                detail!.list = parentList!
                                
                                var error: NSError? = nil
                                do {
                                    try self.managedContext!.save()
                                } catch let error1 as NSError {
                                    error = error1
                                } catch {
                                    fatalError()
                                }
                                if error != nil {
                                    print("error at delete details: \(error!.localizedDescription)")
                                }
                            }
                        }

            }
            
        }
        
    }
    
    /**
     Delete items from DB where list is delete in other place.
     
     - parameter toUseList: list id
     */
    func deleteItemInDB(toUseList:String){
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "list == %@", toUseList)
        let result: [Product] = (try! self.managedContext!.executeFetchRequest(fetchRequest)) as! [Product]
        if result.count > 0 {
            for listDetail in result {
                //println("Delete product list \(listDetail.upc)")
                self.managedContext!.deleteObject(listDetail)
            }
            var error: NSError? = nil
            do {
                try self.managedContext!.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                print("error at delete details: \(error!.localizedDescription)")
            }
        }
    }
    
    //MARK: - DB
    
    func retrieveUserList() -> [List]? {
        var userList: [List]?
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: self.managedContext!)
        //fetchRequest.predicate = NSPredicate(format: "user == %@", user!)
        do{
            userList = try self.managedContext!.executeFetchRequest(fetchRequest) as? [List]
        }catch{
            print("Error retrieveUserList")
        }
        return userList
    }
    
    func findListById(listId:String) -> List? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List" as NSString as String, inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == %@", listId)
        var result: [List] = (try! self.managedContext!.executeFetchRequest(fetchRequest)) as! [List]
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
        var result: [List]? = nil
        do{
            result = try self.managedContext!.executeFetchRequest(fetchRequest) as? [List]
        }catch{
            print("Error retrieveUserList")
        }
        return result
    }

    func saveContext() {
        var error: NSError? = nil
        do {
            try self.managedContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("error at save context on UserListViewController: \(error!.localizedDescription)")
        }
    }

}

