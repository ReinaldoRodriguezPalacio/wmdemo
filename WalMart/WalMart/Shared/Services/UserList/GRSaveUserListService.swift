//
//  GRSaveUserListService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/13/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

//    {
//    "id" : "fdaefb72-f630-41b6-8d41-4681afd35665",
//    "codeMessage" : 0,
//    "items" : [ ],
//    "name" : "Okas",
//    "message" : "La lista se ha guardado correctamente."
//    }

class GRSaveUserListService : GRBaseService {
    
    func buildParams(name:String?) -> [String:AnyObject]! {
        //{"name":"PentonVillet30Mayo2014","items":[]}
        return ["name":name!, "items":[]]
    }

    func buildParams(name:String?, items:[AnyObject]) -> [String:AnyObject]! {
        return ["name":name!, "items":items]
    }

    func buildBaseProductObject(upc upc:String, quantity:Int) -> [String:AnyObject] {
        return ["upc":upc, "quantity":quantity]
    }
    
    func buildParamsMustang(name:String?) -> [String:AnyObject]! {
        return ["profileId":UserCurrentSession.hasLoggedUser() ?  UserCurrentSession.sharedInstance().userSigned!.idUser : "","name":name!,"description":"","comments":"","instructions":""]
    }
    
    
    func buildProductObject(upc upc:String, quantity:Int, image:String?, description:String?, price:String?, type:String?,nameLine:String?) -> [String:AnyObject] {
        //Este JSON de ejemplo es tomado del servicio de addItemToList
        //{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        //Los argumentos: image, description y price son usados solo localmente
        //los valores a ser enviados al servicio solo son upc y quantity
        var base: [String:AnyObject] = ["upc":upc, "quantity":quantity]
        if image != nil {
            base["imageUrl"] = image!
        }
        if description != nil {
            base["description"] = description!
        }
        if price != nil {
            base["price"] = price!
        }
        if type != nil {
            base["type"] = type!
        }
        if nameLine != nil {
            base["nameLine"] = nameLine
        }
        return base
    }

    func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        if  UserCurrentSession.hasLoggedUser() {
            print(params["name"] as! String)
            var cleaned:[String:AnyObject] = ["name":(params["name"] as! String)]
            //Se remueven atributos de los productos que sean innecesarios
            if let items = params["items"] as? [AnyObject] {
                var cleanedItems:[AnyObject] = []
                for idx in 0 ..< items.count {
                    var item = items[idx] as! [String:AnyObject]
                    item.removeValueForKey("imageUrl")
                    item.removeValueForKey("description")
                    item.removeValueForKey("price")
                    item.removeValueForKey("type")
                    cleanedItems.append(item)
                }
                cleaned["items"] = cleanedItems
            }
            
            self.callPOSTService(cleaned,
                successBlock: { (resultCall:NSDictionary) -> Void in
                    //self.jsonFromObject(resultCall)
                    // self.manageListData(resultCall) -  mustang
                    successBlock?(resultCall)
                    return
                },
                errorBlock: { (error:NSError) -> Void in
                    errorBlock?(error)
                    return
                }
            )
        }
        else {
            print("Saving list without user")
            if !self.includeListInDB(params as! [String:AnyObject]) {
                successBlock?([:])
            } else {
                let message = NSLocalizedString("gr.list.samename",  comment: "")
                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                errorBlock?(error)
            }
        }
    }
    
    func manageListData(list:NSDictionary)  {
        
        if  UserCurrentSession.sharedInstance().userSigned == nil {
            return
        }
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //let user = UserCurrentSession.sharedInstance().userSigned
        let listId = list["id"] as! String
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context) as? List
        entity!.registryDate = NSDate()
        entity!.idList = listId
        entity!.user = UserCurrentSession.sharedInstance().userSigned!
        entity!.name = list["name"] as! String
        entity!.countItem = NSNumber(integer: 0)
        
        if let items = list["items"] as? [AnyObject] {
            entity!.countItem = NSNumber(integer: items.count)
            for idx in 0 ..< items.count {
                var item = items[idx] as! [String:AnyObject]
                let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
                detail!.upc = item["upc"] as! String
                detail!.img = item["imageUrl"] as! String
                detail!.desc = item["description"] as! String
                if let quantity = item["quantity"] as? NSNumber {
                    detail!.quantity = quantity
                }
                else if let quantityTxt = item["quantity"] as? String {
                    detail!.quantity = NSNumber(integer: Int(quantityTxt)!)
                }
                if let price = item["price"] as? NSNumber {
                    detail!.price = "\(price)"
                }
                else if let price = item["price"] as? String {
                    detail!.price = price
                }
                if let type = item["type"] as? String {
                    detail!.type =  NSNumber(integer: Int(type)!)
                }
//                else if let type = item["type"] as? NSNumber {
//                    detail!.type = type
//                }
                detail!.list = entity!
            }
        }
        
        self.saveContext(context)
    }
    
    //MARK: - CoreData
    
    func includeListInDB(list:[String:AnyObject]) -> Bool {
        var existsList = false
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!

        let name = list["name"] as! String
        let items = list["items"] as? [AnyObject]
        var localList = self.retrieveListNotSync(name: name, inContext:context)
        if localList == nil {
            localList = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context) as? List
            localList!.name = name
            localList!.registryDate = NSDate()
        } else {
            existsList = true
        }
        var countItem: Int = 0
        if items != nil && items!.count > 0 {
            countItem = items!.count
            for idx in 0 ..< items!.count {
                var item = items![idx] as! [String:AnyObject]
                let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
                detail!.upc = item["upc"] as! String
                if let imageUrl = item["imageUrl"] as? String {
                    detail!.img = imageUrl
                }
                if let description = item["description"] as? String {
                    detail!.desc = description
                }
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
                    detail!.type = type == "false" ? 0 : 1 //NSNumber(integer: Int(type)!)
                }
//                else if let type = item["type"] as? NSNumber {
//                    detail!.type = type
//                }
                if let stock = item["stock"] as? Bool {
                    detail!.isActive = stock == true ? "true" : "false"
                }
               detail!.list = localList!
                
                if let nameLine = item["nameLine"] as? String {
                    detail!.nameLine = nameLine
                }
                
                
            }
            
            
        }
        localList!.countItem = NSNumber(integer: countItem)

        self.saveContext(context)
        return existsList

    }

    func retrieveListNotSync(name name:String, inContext context:NSManagedObjectContext) -> List? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: context)
        if UserCurrentSession.hasLoggedUser() {
            fetchRequest.predicate = NSPredicate(format: "name == %@ ", name)
        }else{
            fetchRequest.predicate = NSPredicate(format: "name == %@ && idList == nil", name)
        }
        var list: List? = nil
        do{
            let result: [List]? = try context.executeFetchRequest(fetchRequest) as? [List]
            if result != nil && result!.count > 0 {
                list = result!.first
            }
        }
        catch{
            print("retrieveListNotSync error")
        }
        return list
    }
    
    func saveContext(context:NSManagedObjectContext) {
        do {
            try context.save()
        } catch{
            print("error at delete details: saveContext")
        }
    }
}