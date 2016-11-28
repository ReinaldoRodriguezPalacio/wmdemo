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

    var isLoadingLists = false
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        if !isLoadingLists {
            isLoadingLists = false
            self.callGETService(params,
                successBlock: { (resultCall:[String:Any]) -> Void in
                    //self.jsonFromObject(resultCall)
                    if let list = resultCall["responseArray"] as? [AnyObject] {
                        self.manageListData(list)
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
    
    func mergeList(_ response:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        let notSyncList = self.retrieveNotSyncList()
        
        if notSyncList != nil && notSyncList!.count > 0 {
            let list = notSyncList!.first
            var listToMerge: [String:Any]? = nil

            let currentLists = response["responseArray"] as? [AnyObject]
            if currentLists != nil && currentLists!.count > 0 {
                for idx in 0 ..< currentLists!.count {
                    var innerList = currentLists![idx] as! [String:Any]
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
                list!.products.enumerateObjects({ (obj:AnyObject, flag:UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let product = obj as? Product {
                        let param = service.buildProductObject(upc: product.upc, quantity: product.quantity.intValue, image: product.img, description: product.desc, price: product.price as String, type: "\(product.type)")
                        items.append(param as AnyObject)
                    }
                } as! (Any, UnsafeMutablePointer<ObjCBool>) -> Void)

                service.callService(service.buildParams(list!.name, items: items),
                    successBlock: { (result:[String:Any]) -> Void in
                        self.managedContext!.delete(list!)
                        self.saveContext()
                        if notSyncList!.count == 0 {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadListFormUpdate"), object: self)
                        }
                        self.mergeList(response, successBlock: successBlock, errorBlock:errorBlock)
                        
                    },
                    errorBlock: { (error:NSError) -> Void in
                        print("Error at merge new list \(error)")
                        if error.code == -13 {
                            self.managedContext!.delete(list!)
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
                    let param = addItemService.buildProductObject(upc: product.upc, quantity: product.quantity.intValue,pesable:product.type.stringValue)
                    params.append(param as AnyObject)
                }
                
                addItemService.callService(addItemService.buildParams(idList: listId, upcs: params),
                    successBlock: { (result:[String:Any]) -> Void in
                        self.managedContext!.delete(list!)
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
    
    func manageListData(_ list:[AnyObject]) {
        let user = UserCurrentSession.sharedInstance().userSigned
        if user == nil {
            print("Se recibio respuesta del servicio GRUserListService sin tener usuario firmado.")
            return
        }

        let arryListLocal:NSMutableArray = []
        
        //Delete list deleting in other
        for serviceList in list {
            arryListLocal.add(serviceList["id"] as! String)
        }
        
        if let userList = self.retrieveUserList() {
            for entity in userList {
                var exist = false
                if entity.idList !=  nil {
                    if arryListLocal.contains(entity.idList!){
                        print("EXISTE")
                    }else{
                        print("NO EXISTE")
                        //self.removeNotificationsFromList(list.idList)
                        self.deleteItemInDB(entity.idList!)
                        self.managedContext!.delete(entity)
                    }
                }
                
                
                for serviceList in list {
                    let listId = serviceList["id"] as! String
                    if entity.idList == listId {
                        exist = true
                        break
                    }
                }
                if !exist {
                    //print("Remover lista::::")
                    //print(":::::::")
                    //self.removeNotificationsFromList(list.idList)
                   // self.managedContext!.deleteObject(entity)
                }
            }
        }
      
        
        

        for serviceList in list {
            let listId = serviceList["id"] as! String
            
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
                toUseList = NSEntityDescription.insertNewObject(forEntityName: "List", into: self.managedContext!) as? List
                
                toUseList!.idList = listId
                toUseList!.user = UserCurrentSession.sharedInstance().userSigned!
                toUseList!.registryDate = Date()
                //println("Creating user list \(listId)")
            }
            
            if let name = serviceList["name"] as? String {
                toUseList!.name = name
            }
            
            var updateDetailList = false
            if let countItems = serviceList["countItem"] as? NSNumber {
                toUseList!.countItem = countItems
                updateDetailList = countItems.intValue > 0
            }
            
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
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
                fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
                fetchRequest.predicate = NSPredicate(format: "list == %@", toUseList!)
                let result: [Product] = (try! self.managedContext!.fetch(fetchRequest)) as! [Product]
                if result.count > 0 {
                    for listDetail in result {
                        //println("Delete product list \(listDetail.upc)")
                        self.managedContext!.delete(listDetail)
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
                
                let detailService = GRUserListDetailService()
                detailService.buildParams(listId)
                detailService.callService([:],
                    successBlock: { (result:[String:Any]) -> Void in
                        if let items = result["items"] as? NSArray {
                            
                            let parentList = self.findListById(listId)
                            if parentList == nil {
                                print("User list not founded \(listId)")
                                return
                            }
                            
                            for idx in 0 ..< items.count {
                                var item = items[idx] as! [String:Any]
                                let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: self.managedContext!) as? Product
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
                                    detail!.quantity = NSNumber(value: Int(quantity)! as Int)
                                }
                                if let type = item["type"] as? String {
                                    detail!.type = NSNumber(value: Int(type)! as Int)
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
                    },
                    errorBlock: { (error:NSError) -> Void in
                        print("Error at retrieve list detail")
                    }
                )
            }
            
        }
        
    }
    
    /**
     Delete items from DB where list is delete in other place.
     
     - parameter toUseList: list id
     */
    func deleteItemInDB(_ toUseList:String){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "list == %@", toUseList)
        let result: [Product] = (try! self.managedContext!.fetch(fetchRequest)) as! [Product]
        if result.count > 0 {
            for listDetail in result {
                //println("Delete product list \(listDetail.upc)")
                self.managedContext!.delete(listDetail)
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: self.managedContext!)
        //fetchRequest.predicate = NSPredicate(format: "user == %@", user!)
        do{
            userList = try self.managedContext!.fetch(fetchRequest) as? [List]
        }catch{
            print("Error retrieveUserList")
        }
        return userList
    }
    
    func findListById(_ listId:String) -> List? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List" as NSString as String, in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == %@", listId)
        var result: [List] = (try! self.managedContext!.fetch(fetchRequest)) as! [List]
        var list: List? = nil
        if result.count > 0 {
            list = result[0]
        }
        return list
    }

    func retrieveNotSyncList() -> [List]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == nil")
        var result: [List]? = nil
        do{
            result = try self.managedContext!.fetch(fetchRequest) as? [List]
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

