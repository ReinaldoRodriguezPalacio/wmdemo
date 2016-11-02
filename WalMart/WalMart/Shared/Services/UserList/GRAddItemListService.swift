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
    
    func buildParams(idList:String, upcs:[Any]?) -> [String:Any]! {
        //{"idList":"26e50bc7-3644-48d8-a51c-73d7536ab30d","itemArrImp":[{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}]}
        return ["idList":idList as AnyObject, "itemArrImp":upcs! as AnyObject]
    }
    
    func buildProductObject(upc:String, quantity:Int,pesable:String,active:Bool) -> [String:Any] {
        //{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        return ["longDescription" : "" as AnyObject, "quantity" : quantity as AnyObject, "upc" : upc as AnyObject, "pesable" : pesable as AnyObject, "equivalenceByPiece" : "" as AnyObject, "promoDescription" : "" as AnyObject, "productIsInStores" : "" as AnyObject,"isActive":active]
    }
    
    func buildProductObject(upc:String, quantity:Int,pesable:String) -> [String:Any] {
        // {"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        return ["longDescription" : "" as AnyObject, "quantity" : quantity as AnyObject, "upc" : upc as AnyObject, "pesable" : pesable as AnyObject, "equivalenceByPiece" : "" as AnyObject, "promoDescription" : "" as AnyObject, "productIsInStores" : "" as AnyObject]
    }
    
    func buildItemMustang(_ upc:String,sku:String,quantity:Int) -> NSDictionary {
        return ["upc":upc,"skuId":sku,"quantity":quantity]
    
    }
    
    func buildItemMustangObject(idList:String, upcs:[Any]?) -> NSDictionary {
        return ["idList":idList,"items":upcs!]
    }
    
    
    func callService(_ params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        /*var toSneditem : [String:Any] = [:]
        let arrayItems = params["itemArrImp"] as! NSArray
        var arrayToSend : [[String:Any]] = []
        for item in arrayItems {
            let paramUpc = item["upc"] as! String
            let paramQuantity = item["quantity"] as! Int
            let paramPesable = item["pesable"] as! String
            let toSendUPC = buildProductObject(upc: paramUpc, quantity: paramQuantity, pesable: paramPesable)
            arrayToSend.append(toSendUPC)
        }
        toSneditem["idList"] = params["idList"] as! String
        toSneditem["itemArrImp"] = arrayToSend*/
        self.jsonFromObject(params)
        self.callPOSTService(params,
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
    
    func manageList(_ list:NSDictionary) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if  let listId = list["id"] as? String {
            
            let user = UserCurrentSession.sharedInstance.userSigned
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
                entity = NSEntityDescription.insertNewObject(forEntityName: "List", into: context) as? List
                entity!.idList = listId
                entity!.user = UserCurrentSession.sharedInstance.userSigned!
                entity!.registryDate = Date()
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
                fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
                fetchRequest.predicate = NSPredicate(format: "list == %@", entity!)
                let result: [Product] = (try! context.fetch(fetchRequest)) as! [Product]
                if result.count > 0 {
                    for listDetail in result {
                        //println("Delete product list \(listDetail.upc)")
                        context.delete(listDetail)
                    }
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        print("error at delete details: \(error1.localizedDescription)")
                    }
                }
            }
            
            if let items = list["items"] as? [Any] {
                entity!.countItem = NSNumber(value: items.count as Int)
                
                for idx in 0 ..< items.count {
                    var item = items[idx] as! [String:Any]
                    let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
                    detail!.upc = item["upc"] as! String
                    detail!.img = item["imageUrl"] as! String
                    detail!.desc = item["description"] as! String
                    if let active = item["isActive"] as? Bool {
                        detail!.isActive = active ? "true" : "false"
                    }
                    
                    if let price = item["price"] as? NSNumber {
                        detail!.price = "\(price)" as NSString
                    }
                    else if let price = item["price"] as? String {
                        detail!.price = price as NSString
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
