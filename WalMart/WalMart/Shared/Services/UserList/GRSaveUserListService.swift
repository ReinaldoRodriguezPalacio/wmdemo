//
//  GRSaveUserListService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/13/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


class GRSaveUserListService : BaseService {
    
    func buildParams(_ name:String?) -> [String:Any]! {
        //{"name":"PentonVillet30Mayo2014","items":[]}
        return ["name":name! as AnyObject, "items":[]]
    }

    func buildParams(_ name:String?, items:[Any]) -> [String:Any]! {
        return ["name":name! as AnyObject, "items":items as AnyObject]
    }

    func buildBaseProductObject(upc:String, quantity:Int) -> [String:Any] {
        return ["upc":upc as AnyObject, "quantity":quantity as AnyObject]
    }
    
    func buildParamsMustang(_ name:String?) -> [String:Any]! {
        return ["name":name! as AnyObject,"description":"" as AnyObject]
    }
    
    
    func buildProductObject(upc:String, quantity:Int, image:String?, description:String?, price:String?, type:String?,nameLine:String?) -> [String:Any] {
        //Este JSON de ejemplo es tomado del servicio de addItemToList
        //{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        //Los argumentos: image, description y price son usados solo localmente
        //los valores a ser enviados al servicio solo son upc y quantity
        var base: [String:Any] = ["upc":upc as AnyObject, "quantity":quantity as AnyObject]
        if image != nil {
            base["imageUrl"] = image! as AnyObject?
        }
        if description != nil {
            base["description"] = description! as AnyObject?
        }
        if price != nil {
            base["price"] = price! as AnyObject?
        }
        if type != nil {
            base["type"] = type! as AnyObject?
        }
        if nameLine != nil {
            base["nameLine"] = nameLine as AnyObject?
        }
        return base
    }

    func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        if  UserCurrentSession.hasLoggedUser() {
            print(params["name"] as! String)
            var cleaned:[String:Any] = ["name":(params["name"] as! String as AnyObject),"profileId":UserCurrentSession.sharedInstance.userSigned!.profile.idProfile]
            //Se remueven atributos de los productos que sean innecesarios
            if let items = params["items"] as? [Any] {
                var cleanedItems:[Any] = []
                for idx in 0 ..< items.count {
                    var item = items[idx] as! [String:Any]
                    item.removeValue(forKey: "imageUrl")
                    item.removeValue(forKey: "description")
                    item.removeValue(forKey: "price")
                    item.removeValue(forKey: "type")
                    cleanedItems.append(item as AnyObject)
                }
                cleaned["items"] = cleanedItems as AnyObject?
            }
            
            self.jsonFromObject(cleaned as AnyObject!)
            self.callPOSTService(cleaned,
                successBlock: { (resultCall:[String:Any]) -> Void in
                   
                    //self.manageListData(resultCall)//TODO aun no regresan id de la lista creada -  mustang
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
            if !self.includeListInDB(params) {
                successBlock?([:])
            } else {
                let message = NSLocalizedString("gr.list.samename",  comment: "")
                let error =  NSError(domain: ERROR_SERIVCE_DOMAIN, code:999, userInfo: [NSLocalizedDescriptionKey:message])
                errorBlock?(error)
            }
        }
    }
    
    func manageListData(_ list:[String:Any])  {
        
        if  UserCurrentSession.sharedInstance.userSigned == nil {
            return
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //let user = UserCurrentSession.sharedInstance.userSigned
        let listId = list["id"] as! String
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "List", into: context) as? List
        entity!.registryDate = Date()
        entity!.idList = listId
        entity!.user = UserCurrentSession.sharedInstance.userSigned!
        entity!.name = list["name"] as! String
        entity!.countItem = NSNumber(value: 0 as Int)
        
        if let items = list["items"] as? [Any] {
            entity!.countItem = NSNumber(value: items.count as Int)
            for idx in 0 ..< items.count {
                var item = items[idx] as! [String:Any]
                let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
                detail!.upc = item["upc"] as! String
                detail!.img = item["imageUrl"] as! String
                detail!.desc = item["description"] as! String
                if let quantity = item["quantity"] as? NSNumber {
                    detail!.quantity = quantity
                }
                else if let quantityTxt = item["quantity"] as? String {
                    detail!.quantity = NSNumber(value: Int(quantityTxt)! as Int)
                }
                if let price = item["price"] as? NSNumber {
                    detail!.price = "\(price)" as NSString
                }
                else if let price = item["price"] as? String {
                    detail!.price = price as NSString
                }
                if let type = item["type"] as? String {
                    detail!.type =  NSNumber(value: Int(type)! as Int)
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
    
    func includeListInDB(_ list:[String:Any]) -> Bool {
        var existsList = false
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!

        let name = list["name"] as! String
        let items = list["items"] as? [Any]
        var localList = self.retrieveListNotSync(name: name, inContext:context)
        if localList == nil {
            localList = NSEntityDescription.insertNewObject(forEntityName: "List", into: context) as? List
            localList!.name = name
            localList!.registryDate = Date()
        } else {
            existsList = true
        }
        var countItem: Int = 0
        if items != nil && items!.count > 0 {
            countItem = items!.count
            for idx in 0 ..< items!.count {
                var item = items![idx] as! [String:Any]
                let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
                detail!.upc = item["upc"] as! String
                if let imageUrl = item["imageUrl"] as? String {
                    detail!.img = imageUrl
                }
                if let description = item["description"] as? String {
                    detail!.desc = description
                }
                if let price = item["price"] as? NSNumber {
                    detail!.price = "\(price)" as NSString
                }
                else if let price = item["price"] as? String {
                    detail!.price = price as NSString
                }
                if let quantity = item["quantity"] as? NSNumber {
                    detail!.quantity = quantity
                }
                else if let quantity = item["quantity"] as? String {
                    detail!.quantity = NSNumber(value: Int(quantity)! as Int)
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
        localList!.countItem = NSNumber(value: countItem as Int)

        self.saveContext(context)
        return existsList

    }

    func retrieveListNotSync(name:String, inContext context:NSManagedObjectContext) -> List? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: context)
        if UserCurrentSession.hasLoggedUser() {
            fetchRequest.predicate = NSPredicate(format: "name == %@ ", name)
        }else{
            fetchRequest.predicate = NSPredicate(format: "name == %@ && idList == nil", name)
        }
        var list: List? = nil
        do{
            let result: [List]? = try context.fetch(fetchRequest) as? [List]
            if result != nil && result!.count > 0 {
                list = result!.first
            }
        }
        catch{
            print("retrieveListNotSync error")
        }
        return list
    }
    
    func saveContext(_ context:NSManagedObjectContext) {
        do {
            try context.save()
        } catch{
            print("error at delete details: saveContext")
        }
    }
}
